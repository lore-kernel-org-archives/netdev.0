From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: tx queue hashing hot-spots and poor performance (multiq, ixgbe)
Date: Fri, 1 May 2009 12:20:12 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0905011206510.10383@ask.diku.dk>
References: <606676310904291600u40e44187g4cfc104007b24fce@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Dickinson <andrew@whydna.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:44969 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752926AbZEAKUS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 May 2009 06:20:18 -0400
In-Reply-To: <606676310904291600u40e44187g4cfc104007b24fce@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Interesting thread Andrew.  I'm also doing some 10G routing performance 
testing, but using Sun Neptune (niu) and SMC's 10G XFP (sfc) NICs.

I'm using pktgen for testing, but it sounds interesting that you got a 
Ixia testing equipment, nice.

On Wed, 29 Apr 2009, Andrew Dickinson wrote:

> I'm trying to evaluate a new system for routing performance for some
> custom packet modification that we do.  To start, I'm trying to get a
> high-water mark of routing performance without our custom cruft in the
> middle.  The hardware setup is a dual-package Nehalem box (X5550,
> Hyper-Threading disabled) with a dual 10G intel card (pci-id:
> 8086:10fb).  Because this NIC is freakishly new, I'm running the
> latest torvalds kernel in order to get the ixgbe driver to identify it
> (<sigh>).

Is that the Intel 82599 10GbE chip?
Where did you get/buy that NIC?


> Interrupts...
> I've disabled irqbalance and I'm explicitly pinning interrupts, one
> per core, as follows:

I'm doing the same...
I find that keeping the RX and TX queue pinned to the same CPU, is 
essential, together with patch that control the mapping between RX and TX 
queues.  But with Eric's patch it looks like I can drop my own patch :-)

If I don't do RX to TX mapping, then Oprofile shows that we use too much 
time freeing the skb's, naturally due to cache bounces.


> -bash-3.2# for x in 57 65; do for i in `seq 0 7`; do echo $i | awk
> '{printf("%X", (2^$1));}' > /proc/irq/$(($i + $x))/smp_affinity; done;
> done

Keep up the good work!

Hilsen
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
