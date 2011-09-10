From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Memory leak in ip_dst_cache
Date: Sat, 10 Sep 2011 09:04:16 -0400
Message-ID: <20110910130416.GA2005@neilslaptop.think-freely.org>
References: <1315544674.20226.YahooMailNeo@web113902.mail.gq1.yahoo.com>
 <1315546223.5410.23.camel@edumazet-laptop>
 <1315593553.98279.YahooMailNeo@web113904.mail.gq1.yahoo.com>
 <1315596786.2606.3.camel@edumazet-laptop>
 <1315601283.91185.YahooMailNeo@web113908.mail.gq1.yahoo.com>
 <1315604820.2606.13.camel@edumazet-laptop>
 <1315605497.25052.YahooMailNeo@web113916.mail.gq1.yahoo.com>
 <1315606125.2606.19.camel@edumazet-laptop>
 <1315608825.98066.YahooMailNeo@web113914.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Kumar S <ps2kumar@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45939 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759273Ab1IJNE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Sep 2011 09:04:27 -0400
Content-Disposition: inline
In-Reply-To: <1315608825.98066.YahooMailNeo@web113914.mail.gq1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 09, 2011 at 03:53:45PM -0700, Kumar S wrote:
> Yes Eric, this command doesn't work on 2.6.24. Which timer are you suspecting?
> 
He means that the timer that starts the the workqueue which calls dst_gc_task is
either delayed indefinately, or otherwise not run, which means that the route
cache will never be scanned for old entries.  The implication being that, while
the dst entries aren't leaked per-se, but never expired, so they just sit
around.  You can check this by instrumenting gc_dst_task with a printk or two
and watch to see if it ever pops up.

If you only have 512Mb of ram and want to really restrict you're cache size, you
should definately consider backporting the route cache rebuild patch to disable
the route cache usage entirely.  It shouldn't be too hard to do.
Neil

> 
