From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net/core: Delay neighbor only if it has been used after
 confirmed
Date: Tue, 15 Sep 2009 03:13:50 -0700 (PDT)
Message-ID: <20090915.031350.61645231.davem@davemloft.net>
References: <4A9E639B.20907@linux-ipv6.org>
	<1252599707.5980.13.camel@fnki-nb00130>
	<1253009246.8352.10.camel@fnki-nb00130>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: jens@mcbone.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35931
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752417AbZIOKNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 06:13:33 -0400
In-Reply-To: <1253009246.8352.10.camel@fnki-nb00130>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jens Rosenboom <jens@mcbone.net>
Date: Tue, 15 Sep 2009 12:07:26 +0200

> On Thu, 2009-09-10 at 18:21 +0200, Jens Rosenboom wrote:
>> On Wed, 2009-09-02 at 21:22 +0900, YOSHIFUJI Hideaki wrote:
>> [...]
>> > And, this "if" for REACHABLE->DELAY may be completely needless.
>> > Timer in REACHABLE is only for state transition for toward REACHABLE
>> > or STALE.
>> 
>> I did some testing with the following patch, which works fine for me, so
>> I propose this one now instead of my previous one. I still have no real
>> idea about the non-IPv6 implications of this, though.
>> 
>> ---
>> 
>> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
>> index e587e68..f61926f 100644
>> --- a/net/core/neighbour.c
>> +++ b/net/core/neighbour.c
>> @@ -819,13 +819,6 @@ static void neigh_timer_handler(unsigned long arg)
>>  				   neigh->confirmed + neigh->parms->reachable_time)) {
>>  			NEIGH_PRINTK2("neigh %p is still alive.\n", neigh);
>>  			next = neigh->confirmed + neigh->parms->reachable_time;
>> -		} else if (time_before_eq(now,
>> -					  neigh->used + neigh->parms->delay_probe_time)) {
>> -			NEIGH_PRINTK2("neigh %p is delayed.\n", neigh);
>> -			neigh->nud_state = NUD_DELAY;
>> -			neigh->updated = jiffies;
>> -			neigh_suspect(neigh);
>> -			next = now + neigh->parms->delay_probe_time;
>>  		} else {
>>  			NEIGH_PRINTK2("neigh %p is suspected.\n", neigh);
>>  			neigh->nud_state = NUD_STALE;
>> 
> 
> Hi David, what are your thoughts on this one? There is IMHO a real bug
> to fix, namely sending tons of repeated neighbor solicitations when
> there is no actual traffic to be sent, so this should qualify to go into
> 2.6.32. Do you want to wait for further comments or should I submit this
> for net-2.6 so it can get some testing?

I'm waiting for Yoshifuji's feedback to your latest patch.
