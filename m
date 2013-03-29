From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [PATCH net-next] core: simplify the getting percpu of flow_cache
Date: Fri, 29 Mar 2013 09:07:17 +0800
Message-ID: <CAJFZqHy4+1kMdjBmZGx-SgtM0naMAHC4wjD=W+EyLKXcrQtH_A@mail.gmail.com>
References: <1364473451-3640-1-git-send-email-roy.qing.li@gmail.com>
	<1364476527.15753.38.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Christoph Lameter <cl@linux.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f178.google.com ([209.85.220.178]:50802 "EHLO
	mail-vc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754146Ab3C2BHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 21:07:19 -0400
Received: by mail-vc0-f178.google.com with SMTP id hz11so123634vcb.9
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 18:07:17 -0700 (PDT)
In-Reply-To: <1364476527.15753.38.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/3/28 Eric Dumazet <eric.dumazet@gmail.com>:
> On Thu, 2013-03-28 at 20:24 +0800, roy.qing.li@gmail.com wrote:
>> From: Li RongQing <roy.qing.li@gmail.com>
>>
>> replace per_cpu with per_cpu_ptr to save conversion between address and pointer
>>
>> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
>> ---
>>  net/core/flow.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/core/flow.c b/net/core/flow.c
>> index 7fae135..707fb7b 100644
>> --- a/net/core/flow.c
>> +++ b/net/core/flow.c
>> @@ -334,7 +334,7 @@ static int flow_cache_percpu_empty(struct flow_cache *fc, int cpu)
>>       struct flow_cache_percpu *fcp;
>>       int i;
>>
>> -     fcp = &per_cpu(*fc->percpu, cpu);
>> +     fcp = per_cpu_ptr(fc->percpu, cpu);
>>       for (i = 0; i < flow_cache_hash_size(fc); i++)
>>               if (!hlist_empty(&fcp->hash_table[i]))
>>                       return 0;
>
>
> This makes no difference at all, at least on x86
>
> Care to elaborate ?
>
I think it seems to be same as per_cpu, but it makes the codes easy to read,
by ignore & before per_cpu() and * beore fc->percpu, and other places in flow.c
are using  per_cpu_ptr(fc->percpu, cpu)

-Roy
