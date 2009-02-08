From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: accelerated vlan gives pcap tagged packets untagged
Date: Mon, 9 Feb 2009 00:26:55 +0100
Message-ID: <20090208232655.GA12756@electric-eye.fr.zoreil.com>
References: <20090208123735.15d9ea4b@mjolnir.drzeus.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Pierre Ossman <drzeus-list@drzeus.cx>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:40949 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751819AbZBHXYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2009 18:24:48 -0500
Content-Disposition: inline
In-Reply-To: <20090208123735.15d9ea4b@mjolnir.drzeus.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pierre Ossman <drzeus-list@drzeus.cx> :
[...]
> I assume this is because the hardware supports vlans and handles all
> the tag stripping.

Partly.

> (I've confirmed with tcpdump that the packets lack tags when they are
> presented to userspace)
> 
> From what I can tell, I cannot fix this without rebuilding the kernel
> and removing the acceleration support from the r8169 driver. Is there
> some method I've overlooked?
>
> Preferably, I'd like the kernel to expose to pcap what's on the wire
> (i.e. accelerated vs non-accelerated looks the same from userspace). If
> that means too much processing to be desirable, the next best thing
> would be to simply not show tagged packets on the raw interface.

Your issue seems to be related to the commit below:

commit bc1d0411b804ad190cdadabac48a10067f17b9e6
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Jul 14 22:49:30 2008 -0700

    vlan: deliver packets received with VLAN acceleration to network taps
    
    When VLAN header stripping is used, packets currently bypass packet
    sockets (and other network taps) completely. For locally existing
    VLANs, they appear directly on the VLAN device, for unknown VLANs
    they are silently dropped.
    
    Add a new function netif_nit_deliver() to deliver incoming packets
    to all network interface taps and use it in __vlan_hwaccel_rx() to
    make VLAN packets visible on the underlying device.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>
    Signed-off-by: David S. Miller <davem@davemloft.net>

I have no idea what could be the right solution. Patrick ?

-- 
Ueimor
