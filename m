From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2]: pkt_sched: Convert CBQ to tasklet_hrtimer.
Date: Sun, 23 Aug 2009 18:54:56 -0700 (PDT)
Message-ID: <20090823.185456.25552109.davem@davemloft.net>
References: <alpine.LFD.2.00.0908221041290.1769@localhost.localdomain>
	<20090822.180836.34851176.davem@davemloft.net>
	<alpine.LFD.2.00.0908230919420.1769@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tglx@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60867
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750830AbZHXByn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2009 21:54:43 -0400
In-Reply-To: <alpine.LFD.2.00.0908230919420.1769@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Gleixner <tglx@linutronix.de>
Date: Sun, 23 Aug 2009 09:22:48 +0200 (CEST)

> B1;2005;0cOn Sat, 22 Aug 2009, David Miller wrote:
>> I'm not convinced either way, the code logic here has been like
>> this since at least 2.2.x, where it reads:
>> 
>> 	if (!cl->delayed) {
>> 		unsigned long sched = jiffies;
>>  ...
>> 		if (delay > 0) {
>> 			sched += PSCHED_US2JIFFIE(delay) + cl->penalty;
>>  ...
>> 			if (del_timer(&q->delay_timer) &&
>> 			    (long)(q->delay_timer.expires - sched) > 0)
>> 				q->delay_timer.expires = sched;
>> 			add_timer(&q->delay_timer);
> 
> That does not make more sense than the hrtimer version :)

Sure it does, at least to me.

It says: When 'delay > 0', either the timer fires immediately
('jiffies') or at some point in the future ('jiffies + delay +
penalty' or existing expiration, whichever is sooner).

The intention of the code seems very clear.

>> So please review my patch in the context of a straight conversion to
>> tasklet_hrtimer, and let's deal with the timer offset logic here
>> seperately (and in -next, not 2.6.31-rcX)
> 
> The straight conversion looks fine. Add my Acked-by.

Thanks.
