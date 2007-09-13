From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [BUG] tg3 cannot do PXE (loses MAC address) after soft
 reboot
Date: Thu, 13 Sep 2007 08:15:10 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC002AABA5B@nt-irva-0751.brcm.ad.broadcom.com>
References: <20070913083918.GA5386@xanadu.blop.info>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: "Lucas Nussbaum" <lucas.nussbaum@imag.fr>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3317 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755573AbXIMPPg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2007 11:15:36 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070913083918.GA5386@xanadu.blop.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lucas Nussbaum wrote:

> This used to work, and broke between 2.6.16 and 2.6.17. Using 
> git bissect,
> I could trace this back to that commit:
> commit bc1c756741b065cfebf850e4164c0e2aae9d527f
> Author: Michael Chan <mchan@broadcom.com>
> Date:   Mon Mar 20 17:48:03 2006 -0800
>     [TG3]: Support shutdown WoL.

This may be caused by bugs in early versions of bootcode or
PXE code.  When tg3 powers down the PHY during shutdown, the
MAC address will become zero in the MAC address register.  The
PXE code or bootcode needs to fetch the MAC address again from
The NVRAM.

Can you also send me ethtool -i eth0 which will provide the
bootcode version?  What machine are you using?  Thanks.

> 
> During boot, the following messages are displayed:
> Broadcom NetXtreme Gigabit Ethernet Boot Agent v2.2.8
> [...]
> Broadcom UNDI, PXE-2.1 (build 082) v2.2.8
> [...]
> CLIENT MAC ADDR: 00 10 18 01 E5 2F GUID: 44454C4C 4800 1052 8032
> B9C04F53304A
> 
> After a soft reboot, the last line is changed to:
> CLIENT MAC ADDR: 00 00 00 00 00 00 GUID: 44454C4C 4800 1052 8032
> B9C04F53304A
> 
> lspci -v for the card:
> 02:02.0 Ethernet controller: Broadcom Corporation NetXtreme 
> BCM5703X Gigabit Ethernet (rev 02)
>         Subsystem: Broadcom Corporation NetXtreme BCM5703 1000Base-T
>         Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 177
>         Memory at fcf00000 (64-bit, non-prefetchable) [size=64K]
>         Capabilities: [40] PCI-X non-bridge device
>         Capabilities: [48] Power Management version 2
>         Capabilities: [50] Vital Product Data
>         Capabilities: [58] Message Signalled Interrupts: 
> Mask- 64bit+ Queue=0/3 Enable-
> 
> Thank you,
> -- 
> | Lucas Nussbaum                        PhD student |
> | lucas.nussbaum@imag.fr        LIG / Projet MESCAL |
> | jabber: lucas@nussbaum.fr    +33 (0)6 64 71 41 65 |
> | homepage:        http://www-id.imag.fr/~nussbaum/ |
> 
> 

