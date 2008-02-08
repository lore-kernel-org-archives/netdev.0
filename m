From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: Broadcom 5708 taking a few seconds to get link-up
Date: Fri, 08 Feb 2008 11:42:50 -0800
Message-ID: <1202499770.17235.16.camel@dell>
References: <47ACADA1.1090809@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "Brian Haley" <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3733 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761002AbYBHTlj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Feb 2008 14:41:39 -0500
In-Reply-To: <47ACADA1.1090809@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-02-08 at 14:29 -0500, Brian Haley wrote:
> Hi Michael,
> 
> I'm working on a system that has two on-board 5708's.  We've noticed 
> that it takes about 3 seconds for the link to come up - is this 
> considered normal?  I've tried this with the latest davem tree with 
> similar results to older kernels/drivers.

Yes, 2 - 3 seconds are normal for autoneg to link up on
10/100/1000baseT.  Sometimes it can take even longer, but generally less
than 5 seconds.  SerDes is much faster.

> 
> # uname -r
> 2.6.24
> 
> # ethtool -i eth3
> driver: bnx2
> version: 1.7.3
> firmware-version: 1.9.3
> bus-info: 0000:42:00.0
> 
> # lspci -v
> 42:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708 
> Gigabit Ethernet (rev 11)
>          Subsystem: Hewlett-Packard Company Unknown device 7038
>          Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 34
>          Memory at fa000000 (64-bit, non-prefetchable) [size=32M]
>          Capabilities: [40] PCI-X non-bridge device
>          Capabilities: [48] Power Management version 2
>          Capabilities: [50] Vital Product Data
>          Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ 
> Queue=0/0 Enable-
> 
> # ip link set eth3 up; mii-tool eth3; sleep 1; mii-tool eth3; sleep 1; 
> mii-tool eth3; sleep 1; mii-tool eth3
> eth3: no link
> eth3: no link
> eth3: no link
> eth3: negotiated 100baseTx-FD, link ok
> 
> Other drivers I've tried - e1000 and tg3, get up in < 1 second.  I'm 
> asking becuase any packet I try to transmit out this interface before 
> link-up never gets out.
> 

In BNX2 and TG3, we always reset the PHY when we bring up the device,
causing the link to drop and to renegotiate.  The link-up time for TG3
should be about the same (2 - 3 seconds).  Other drivers may not reset
the PHY and so the link may be able to come up instantly.

