From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 1/2] bpf: don't enable preemption twice in
 smap_do_verdict
Date: Thu, 17 Aug 2017 09:10:39 -0700
Message-ID: <1082320a-d273-8316-9dc6-2dcd06749f5c@fb.com>
References: <cover.1502983087.git.daniel@iogearbox.net>
 <d90eed71c2a723edd75f19fb1b921fec74d8a514.1502983087.git.daniel@iogearbox.net>
 <5995BE4D.10503@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: John Fastabend <john.fastabend@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:33461 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751107AbdHQQLN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 12:11:13 -0400
In-Reply-To: <5995BE4D.10503@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/17/17 9:03 AM, John Fastabend wrote:
> On 08/17/2017 08:22 AM, Daniel Borkmann wrote:
>> In smap_do_verdict(), the fall-through branch leads to call
>> preempt_enable() twice for the SK_REDIRECT, which creates an
>> imbalance. Only enable it for all remaining cases again.
>>
>> Fixes: 174a79ff9515 ("bpf: sockmap with sk redirect support")
>> Reported-by: Alexei Starovoitov <ast@kernel.org>
>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>> ---
>>  kernel/bpf/sockmap.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/kernel/bpf/sockmap.c b/kernel/bpf/sockmap.c
>> index f7e5e6c..39de541 100644
>> --- a/kernel/bpf/sockmap.c
>> +++ b/kernel/bpf/sockmap.c
>> @@ -135,7 +135,8 @@ static void smap_do_verdict(struct smap_psock *psock, struct sk_buff *skb)
>>  	/* Fall through and free skb otherwise */
>>  	case SK_DROP:
>>  	default:
>> -		preempt_enable();
>> +		if (rc != SK_REDIRECT)
>> +			preempt_enable();
>>  		kfree_skb(skb);
>>  	}
>>  }
>>
>
> Yep looks good, nice catch Alexei. Thanks! I'll add a selftests entry
> in test_maps to catch this fall through case. Looks like we don't hit
> this case during selftests at the moment.
>
> Acked-by: John Fastabend <john.fastabend@gmail.com>
>

Acked-by: Alexei Starovoitov <ast@kernel.org>
