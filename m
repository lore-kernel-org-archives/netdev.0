From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Route cache performance
Date: Fri, 16 Sep 2005 21:57:31 +0200
Message-ID: <17195.9131.491717.442214@robur.slu.se>
References: <17167.29239.469711.847951@robur.slu.se>
	<20050906235700.GA31820@netnation.com>
	<17182.64751.340488.996748@robur.slu.se>
	<20050907162854.GB24735@netnation.com>
	<20050907195911.GA8382@yakov.inr.ac.ru>
	<20050913221448.GD15704@netnation.com>
	<20050915210432.GD28925@yakov.inr.ac.ru>
	<17193.59406.200787.819069@robur.slu.se>
	<20050915222102.GA30387@yakov.inr.ac.ru>
	<17194.47097.607795.141059@robur.slu.se>
	<20050916190404.GA11012@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, Simon Kirby <sim@netnation.com>,
        Eric Dumazet <dada1@cosmosbay.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20050916190404.GA11012@yakov.inr.ac.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Alexey Kuznetsov writes:

 > Most likely, something is broken in the e1000 driver. Otherwise, no ideas.

 No it's hard to guess. Simon will hopefully bring some more data.

 > I do not see _why_. Apparently some overhead is present but I do not
 > understand why it is so large. Is it just because 300 redundant entries
 > pollute cache a little more? I do not see another reasons.

 Yes when RX softirq is done. RCU tasklet has to take over and probably
 reload cache with some the entries to complete the deletion. It might be 
 worth a profile...

 > Maybe it makes sense to compare this effect with the effect of increment
 > gc_elasticity by 1. If it is due to cache pollution, effect of increment
 > of gc_elasticity, which increses size of cache by rhash_size should be
 > even worse.

 Something like that yes :) but if we increase gc_elasticity we also add 
 more spinning in hash chains. So we need to sort out if the expected 
 performance drop comes from extra hash spinning or are cache effects from 
 the increased hash.

 Cheers.
					--ro
