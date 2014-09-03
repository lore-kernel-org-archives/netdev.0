From: Denis Kirjanov <kirjanov@gmail.com>
Subject: Re: [PATCH] net: export pkt_type_offset() helper
Date: Wed, 3 Sep 2014 12:53:48 +0400
Message-ID: <CAHj3AVmY1cL6r78LjEs-fwYzz+dvy5BJCCcAedcMd4KsYt0nCQ@mail.gmail.com>
References: <1409688238-3152-1-git-send-email-kda@linux-powerpc.org>
	<20140902225926.GA14635@its-macbook-pro.plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Denis Kirjanov <kda@linux-powerpc.org>, netdev@vger.kernel.org,
	Markos Chandras <markos.chandras@imgtec.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Daniel Borkmann <dborkman@redhat.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:34803 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753230AbaICIxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 04:53:49 -0400
Received: by mail-oi0-f50.google.com with SMTP id u20so5256536oif.37
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 01:53:49 -0700 (PDT)
In-Reply-To: <20140902225926.GA14635@its-macbook-pro.plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/3/14, Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
> On Wed, Sep 03, 2014 at 12:03:58AM +0400, Denis Kirjanov wrote:
>> Currently we have 2 pkt_type_offset functions doing
>> the same thing and spread across the architecture files.
>> Let's use the generic helper routine.
>
> that would be good cleanup.
> Please tag your subject as '[PATCH net-next]...'
>
>> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
>> Cc: Markos Chandras <markos.chandras@imgtec.com>
>> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
>> Cc: Daniel Borkmann <dborkman@redhat.com>
>> ---
>>  arch/mips/net/bpf_jit.c      | 21 ---------------------
>>  arch/s390/net/bpf_jit_comp.c | 38 ++++----------------------------------
>>  include/linux/filter.h       |  7 +++++++
>>  net/core/filter.c            |  7 +------
>>  4 files changed, 12 insertions(+), 61 deletions(-)
>>
>> diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
>> -#define PKT_TYPE_MAX 0xe0
>> -static int pkt_type_offset;
> ...
>> -}
>> -device_initcall(bpf_pkt_type_offset_init);
>
> may be make sense to optimize common case via initcall() as well
> instead of dropping it for s390?

Yeah, it's a better option.
>
>> diff --git a/include/linux/filter.h b/include/linux/filter.h
>> index a5227ab..97e0549 100644
>> --- a/include/linux/filter.h
>> +++ b/include/linux/filter.h
>> @@ -424,6 +424,13 @@ static inline void *bpf_load_pointer(const struct
>> sk_buff *skb, int k,
>>  	return bpf_internal_load_pointer_neg_helper(skb, k, size);
>>  }
>>
>> +#ifdef __BIG_ENDIAN_BITFIELD
>> +#define PKT_TYPE_MAX	(7 << 5)
>> +#else
>> +#define PKT_TYPE_MAX    7
>> +#endif
>
> these defines don't need to move. keep them in filter.c

I'll respin. Thanks!
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
Regards,
Denis
