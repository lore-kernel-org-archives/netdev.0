From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: How fast can your 10G go?
Date: Thu, 21 May 2009 10:35:55 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0905211018480.20475@ask.diku.dk>
References: <4A12D8D4.2070303@candelatech.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-511516320-860067882-1242894955=:20475"
Cc: NetDev <netdev@vger.kernel.org>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:42392 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751200AbZEUIhP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2009 04:37:15 -0400
In-Reply-To: <4A12D8D4.2070303@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---511516320-860067882-1242894955=:20475
Content-Type: TEXT/PLAIN; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT

On Tue, 19 May 2009, Ben Greear wrote:

> I've been running some tests on a new Nehalem based system
> with a 2 port pci-e x8 10G NIC (ixgbe driver).
>
> When using pktgen, max I can get is about 5.6Gbps tx + rx on both ports. 
> This is about 22Gbps across the backplane, so I don't mean to complain :)
>
> However, I'm curious if anyone has gotten any better performance on
> some other system?

Robert Olsson (and Olof Hagsand and Bengt Gördén) got some better results 
using that exact hardware Intel 82598 chips (and Sun neptune NICs).  They 
made an article called: "Open-source routing at 10Gb/s"

  https://www.iis.se/docs/10G-OS-router_2_.pdf


> In particular, it seems that my system is bound by
> the bus and/or the NIC.  Would I need to find something like a x16 slot
> to have a chance at 10Gbps bi-directional on 2 ports?

Are you doing a single flow bandwidth test?

These NICs designed for multiflow performance. They have hardware RX and 
TX queues to facilitate this, often call multiqueue NICs.  This is also 
what helps us do real parallel processing across CPUs in the network stack 
(since DaveMs multiqueue changes, although not all drivers uses this 
correctly yet...).

Try doing a multi-flow network test, I bet you will see better results. 
(Normally you also need to adjust smp-affinity, but with large frames on 
my Core i7 system its fast enough for 9.5 Gbit/s without tuning, small 
frames is another case)

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
---511516320-860067882-1242894955=:20475--
