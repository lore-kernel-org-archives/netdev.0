From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 3/9] bpf: pre-allocate hash map elements
Date: Mon, 7 Mar 2016 10:29:06 -0800
Message-ID: <56DDC872.5010001@fb.com>
References: <1457315917-1970307-1-git-send-email-ast@fb.com>
 <1457315917-1970307-4-git-send-email-ast@fb.com>
 <56DD6118.7090608@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Martin KaFai Lau <kafai@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: Daniel Borkmann <daniel@iogearbox.net>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:4091 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752607AbcCGSaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 13:30:06 -0500
In-Reply-To: <56DD6118.7090608@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/7/16 3:08 AM, Daniel Borkmann wrote:
> On 03/07/2016 02:58 AM, Alexei Starovoitov wrote:
> [...]
>> ---
>>   include/linux/bpf.h      |   1 +
>>   include/uapi/linux/bpf.h |   3 +
>>   kernel/bpf/hashtab.c     | 264
>> ++++++++++++++++++++++++++++++++++-------------
>>   kernel/bpf/syscall.c     |   2 +-
>>   4 files changed, 196 insertions(+), 74 deletions(-)
>
> Shouldn't all other map types (like array) need something like this as
> well to
> reserve this for their future flags?
>
>    if (attr->map_flags)
>      return ERR_PTR(-EINVAL);

yeah. good point. will add another patch for that.

>> diff --git a/include/linux/bpf.h b/include/linux/bpf.h
>> index 4b070827200d..c81efb10bbb5 100644
>> --- a/include/linux/bpf.h
>> +++ b/include/linux/bpf.h
>> @@ -37,6 +37,7 @@ struct bpf_map {
>>       u32 key_size;
>>       u32 value_size;
>>       u32 max_entries;
>> +    u32 map_flags;
>
> Just naming this 'flags' doesn't work due to the anonymous struct inside
> that
> union, right? :/

yep. exactly. there is already 'flags' member there.

>>
>> +#define BPF_F_NO_PREALLOC    (1ULL << 0)
>
> Nit: Should better be (1U << 0) as map_flags are of __u32.

right. will do.
