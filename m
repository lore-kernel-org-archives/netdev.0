From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root.
	Now=15 size=11 bits
Date: Thu, 2 Jul 2009 21:06:26 +0200
Message-ID: <20090702190626.GA2737@ami.dom.local>
References: <20090701063651.GA4876@ff.dom.local> <20090701072409.GA12592@ff.dom.local> <4A4B2FA8.3040007@itcare.pl> <20090701101333.GB12715@ff.dom.local> <20090701110407.GC12715@ff.dom.local> <4A4BE06F.3090608@itcare.pl> <20090702053216.GA4954@ff.dom.local> <4A4C48FD.7040002@itcare.pl> <20090702060011.GB4954@ff.dom.local> <19020.53998.330803.83554@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: Robert Olsson <robert@herjulf.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:45263 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750946AbZGBTGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 15:06:48 -0400
Received: by bwz25 with SMTP id 25so1423511bwz.37
        for <netdev@vger.kernel.org>; Thu, 02 Jul 2009 12:06:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <19020.53998.330803.83554@gargle.gargle.HOWL>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 02, 2009 at 05:31:58PM +0200, Robert Olsson wrote:
> 
> Jarek Poplawski writes:
> 
>  > Yes, it looks like we can't free memory so simple because of such huge
>  > latencies.  
> 
>  Controlling RCU seems crucial. Insertion of the full BGP table increased
>  from 2 seconds to > 20 min with one synchronize_rcu patches.

I wish I knew this a few days before. I could imagine a slow down,
but it looked like it was stuck. Since these last changes weren't
tested on SMP + PREEMPT I thought there is still something broken.
(I was mainly interested in this synchronize_rcu at the moment as
a preemption test.)  

>  And fib_trie "worst case" wrt memory is the root node. So maybe we should 
>  monitor changes in root node and use this to control synchronize_rcu.
> 
>  Didn't Paul suggest something like this?

Sure, and it needs testing, but we should send some safe preemption
fix for -stable first, don't we?

>  And with don't find any decent solution we have to add an option for 
>  a fixed and pre-allocated root-nod typically for BGP-routers.

Probably you're right; I'd prefer to see the test results showing
a difference vs. simply less aggressive root thresholds. But of
course, even if not convinced, I'll respect your choice as the author
and maintainer, so feel free to NAK my proposals - I won't get it
personally.;-)

Cheers,
Jarek P.
