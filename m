From: Mike Isely <isely@isely.net>
Subject: Re: [PATCH 11/12] r8169: align the IP header when there is no DMA
 constraint
Date: Thu, 26 Apr 2007 23:45:10 -0500 (CDT)
Message-ID: <Pine.LNX.4.64.0704262332330.16942@cnc.isely.net>
References: <20070426205714.GA12701@electric-eye.fr.zoreil.com>
 <20070426214929.GL7344@electric-eye.fr.zoreil.com>
Reply-To: Mike Isely <isely@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Philip Craig <philipc@snapgear.com>,
	Mike Isely at pobox <isely@pobox.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnc.isely.net ([64.81.146.143]:41105 "EHLO cnc.isely.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755302AbXD0EuT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2007 00:50:19 -0400
In-Reply-To: <20070426214929.GL7344@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thu, 26 Apr 2007, Francois Romieu wrote:

> Align the IP header when the chipset can DMA at any location (plain 0x8169).
> Otherwise (0x8136/0x8168) obey the constraint imposed by the hardware.
> 
> This patch complements the previous alignment rework done for copybreak.
> 
> Original idea from Philip Craig <philipc@snapgear.com>
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Philip Craig <philipc@snapgear.com>
> Cc: Mike Isely <isely@pobox.com>
> ---

   [...]


Francois:

I just tried this.  It worked fine here (and a test with rsync shows 
bandwidth to be about where I'd expect).  Some more detail...

I grabbed the following:

http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.21-rc7/r8169-20070416.tar.bz2

That appears to also include the patch below (I could not successfully 
just apply the one piece).  I then applied the entire series to the 
r8169 driver from the newly minted vanilla 2.6.21 kernel, replaced that 
module and tested.  No ill effects.  Everything looks good here.  To 
refresh your memory, my system is an Intel Core2 Duo system built around 
a Gigabyte GA-945GM-S2 mainboard.  And of course it has an r8169 class 
chip.  Here's the relevant output from "lspci -vvnn":

<CUT>
02:00.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet controller [10ec:8168] (rev 01)
	Subsystem: Giga-byte Technology Unknown device [1458:e000]
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 221
	Region 0: I/O ports at a000 [size=256]
	Region 2: Memory at e1000000 (64-bit, non-prefetchable) [size=4K]
	[virtual] Expansion ROM at 80000000 [disabled] [size=64K]
	Capabilities: [40] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0-,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [48] Vital Product Data
	Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+ Queue=0/1 Enable+
		Address: 00000000fee0100c  Data: 41e1
	Capabilities: [60] Express Endpoint IRQ 0
		Device: Supported: MaxPayload 1024 bytes, PhantFunc 0, ExtTag+
		Device: Latency L0s unlimited, L1 unlimited
		Device: AtnBtn+ AtnInd+ PwrInd+
		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
		Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
		Device: MaxPayload 128 bytes, MaxReadReq 4096 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s, Port 0
		Link: Latency L0s unlimited, L1 unlimited
		Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x1
	Capabilities: [84] Vendor Specific Information
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [12c] Virtual Channel
	Capabilities: [148] Device Serial Number 68-81-ec-10-00-00-00-25
	Capabilities: [154] Power Budgeting
</CUT>

Everything looks good here.

  -Mike



-- 
                        |         Mike Isely          |     PGP fingerprint
     Spammers Die!!     |                             | 03 54 43 4D 75 E5 CC 92
                        |   isely @ pobox (dot) com   | 71 16 01 E2 B5 F5 C1 E8
                        |                             |
