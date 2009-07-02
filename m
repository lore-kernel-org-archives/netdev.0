From: Robert Olsson <robert@herjulf.net>
Subject: Re: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root.
	Now=15 size=11 bits
Date: Thu, 2 Jul 2009 23:32:26 +0200
Message-ID: <19021.10090.995805.740700@gargle.gargle.HOWL>
References: <20090701063651.GA4876@ff.dom.local>
	<20090701072409.GA12592@ff.dom.local>
	<4A4B2FA8.3040007@itcare.pl>
	<20090701101333.GB12715@ff.dom.local>
	<20090701110407.GC12715@ff.dom.local>
	<4A4BE06F.3090608@itcare.pl>
	<20090702053216.GA4954@ff.dom.local>
	<4A4C48FD.7040002@itcare.pl>
	<20090702060011.GB4954@ff.dom.local>
	<19020.53998.330803.83554@gargle.gargle.HOWL>
	<20090702190626.GA2737@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <robert@herjulf.net>,
	=?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from av9-1-sn3.vrr.skanova.net ([81.228.9.185]:52672 "EHLO
	av9-1-sn3.vrr.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756571AbZGBVbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 17:31:46 -0400
In-Reply-To: <20090702190626.GA2737@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jarek Poplawski writes:

 > >  Controlling RCU seems crucial. Insertion of the full BGP table increased
 > >  from 2 seconds to > 20 min with one synchronize_rcu patches.
 > 
 > I wish I knew this a few days before. I could imagine a slow down,
 > but it looked like it was stuck. Since these last changes weren't
 > tested on SMP + PREEMPT I thought there is still something broken.
 > (I was mainly interested in this synchronize_rcu at the moment as
 > a preemption test.)  


 Honestly this huge slowdown was surprise for me too. I think I sent 
 you a script so you could insert the full table yourself.

 > >  And fib_trie "worst case" wrt memory is the root node. So maybe we should 
 > >  monitor changes in root node and use this to control synchronize_rcu.
 > > 
 > >  Didn't Paul suggest something like this?
 > 
 > Sure, and it needs testing, but we should send some safe preemption
 > fix for -stable first, don't we?
 
 Yes my hope was that we could combine them... personally I'll need 
 to understand who we can preeemted better in the different configs
 and most of that this can be handled by "standard" RCU.

 > >  And with don't find any decent solution we have to add an option for 
 > >  a fixed and pre-allocated root-nod typically for BGP-routers.
 > 
 > Probably you're right; I'd prefer to see the test results showing
 > a difference vs. simply less aggressive root thresholds. But of
 > course, even if not convinced, I'll respect your choice as the author
 > and maintainer, so feel free to NAK my proposals - I won't get it
 > personally.;-)

 Thresholds we can change no problem... but very soon I'll people 
 will start routing without the route cache this at least in close
 to Internet core ,we will need all fib_look performance we can get.

 fib_trie was designed for classical RCU and no preempt you see the
 names i file... so this new and very challenging work to all of us.
 
 First week of vacation and have to fix the roof of the house...
 it's hot and dirty. 

 Cheers.
					--ro
