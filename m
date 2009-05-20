From: Bill Fink <billfink@mindspring.com>
Subject: Re: How fast can your 10G go?
Date: Wed, 20 May 2009 02:41:00 -0400
Message-ID: <20090520024100.ceba4aca.billfink@mindspring.com>
References: <4A12D8D4.2070303@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-dupuy.atl.sa.earthlink.net ([209.86.89.62]:35746 "EHLO
	elasmtp-dupuy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751269AbZETGlC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 02:41:02 -0400
In-Reply-To: <4A12D8D4.2070303@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 19 May 2009, Ben Greear wrote:

> I've been running some tests on a new Nehalem based system
> with a 2 port pci-e x8 10G NIC (ixgbe driver).
> 
> When using pktgen, max I can get is about 5.6Gbps tx + rx on both ports.  This is
> about 22Gbps across the backplane, so I don't mean to complain :)
> 
> However, I'm curious if anyone has gotten any better performance on
> some other system?  In particular, it seems that my system is bound by
> the bus and/or the NIC.  Would I need to find something like a x16 slot
> to have a chance at 10Gbps bi-directional on 2 ports?

We have achieved bidirectional 20-Gbps line rate traffic between a pair
of Nehalem i7 quad-core servers, each with a dual-port 10-GigE Myricom
PCI-E 2.0 x8 SFP+ NIC.  Here's a unidirectional 10-second nuttcp TCP
test (using 9000 byte jumbo frames):

[root@i7raid-1 ~]# ./nuttcp-6.2.6 -N2 -w10m /192.168.101.2/192.168.102.2
23627.0625 MB /  10.01 sec = 19792.4891 Mbps 53 %TX 57 %RX 0.11 msRTT

Your results sound about right for a PCI-E 1.0 x8 slot, which has
16 Gbps full-duplex usable bandwidth, and then subtracting about 25%
PCI-E overhead leaves about 12 Gbps full-duplex or 24 Gbps total
available bandwidth for TCP|UDP data transfers.

						-Bill
