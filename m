From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Patch 6/6] per task delay accounting taskstats interface: fix clone skbs for each listener
Date: Tue, 11 Jul 2006 20:28:50 +1000
Message-ID: <E1G0FU2-0002oE-00@gondolin.me.apana.org.au>
References: <20060711030524.39abc3d5.akpm@osdl.org>
Cc: nagar@watson.ibm.com, linux-kernel@vger.kernel.org, jlan@sgi.com,
	csturtiv@sgi.com, pj@sgi.com, balbir@in.ibm.com,
	sekharan@us.ibm.com, hadi@cyberus.ca, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:64272 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750955AbWGKK3c
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 06:29:32 -0400
To: akpm@osdl.org (Andrew Morton)
In-Reply-To: <20060711030524.39abc3d5.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@osdl.org> wrote:
> On Tue, 11 Jul 2006 00:36:39 -0400
> Shailabh Nagar <nagar@watson.ibm.com> wrote:
> 
>>       down_write(&listeners->sem);
>>       list_for_each_entry_safe(s, tmp, &listeners->list, list) {
>> -             ret = genlmsg_unicast(skb, s->pid);
>> +             skb_next = NULL;
>> +             if (!list_islast(&s->list, &listeners->list)) {
>> +                     skb_next = skb_clone(skb_cur, GFP_KERNEL);
> 
> If we do a GFP_KERNEL allocation with this semaphore held, and the
> oom-killer tries to kill something to satisfy the allocation, and the
> killed task gets stuck on that semaphore, I wonder of the box locks up.

We do GFP_KERNEL inside semaphores/mutexes in lots of places.  So if this
can deadlock with the oom-killer we probably should fix that, preferably
by having GFP_KERNEL fail in that case.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
