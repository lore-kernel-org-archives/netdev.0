From: David Miller <davem@davemloft.net>
Subject: Re: tg3 bad performance, lots of hardware interrupts
Date: Thu, 27 Mar 2008 14:49:25 -0700 (PDT)
Message-ID: <20080327.144925.196529669.davem@davemloft.net>
References: <alpine.DEB.1.00.0803271532570.30549@penti.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	mchan@broadcom.com
To: harald@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41221
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756601AbYC0VtZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 17:49:25 -0400
In-Reply-To: <alpine.DEB.1.00.0803271532570.30549@penti.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harald Hannelius <harald@iki.fi>
Date: Thu, 27 Mar 2008 15:53:56 +0200 (EET)

You'll have better luck if you report this to the networking
developer list (netdev) and the tg3 driver maintainer (Michael
Chan), who are both now CC:'d.

> I experience a lot of hardware interrupts with a BCM5751 PCI-express NIC 
> (tg3). modprobe tg3, ifconfig ethX up and friends makes the system 
> unresponsive. Just having the interface up makes the system sluggish.
> 
> Onboard forcedeth works fine (with the same cable).
> 
> iperf gives me just 2Mbps on a 1Gbps ethernet. Load average near 1.0. top 
> reports 40-50%hi (hardware interrupts) when generating traffic over that 
> interface.
> 
> The system is a Supermicro H8SMI-2 motherboard, HP EA833AA BROADCOM 
> NETXTREME PCI-express NIC, 2GB RAM, Dual-Core opteron 2.8GHz.
> 
> All of our other servers with broadcom NIC's work fine with tg3, but they 
> aren't PCI-express.
> 
> I have tried booting with pci=nomsi and pci=routeirq (BIOS with or without 
> "pnp OS" defined). Ubuntu 7.10 live-cd same result. Haven't tried other 
> OS'es.
> 
> irq_balancing enabled.
> 
> Kernel conf: http://www.iki.fi/~harald/kernconf.gz (9kB).
> 
> Any hints on what to check for? Hardware or tg3 driverproblem?
> 
> 
> I would be glad to report more info, if needed. I have profiling support 
> but I have never profiled a kernel before. I haven't got any other PCI-e 
> NIC's to test with, yet.
> 
> 
> # uname -r
> 2.6.24.4
> 
> # dmesg|grep tg
> tg3.c:v3.86 (November 9, 2007)
> 
> # lspci -vvv
> 07:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5751 Gigabit Ethernet PCI Express (rev 21)
>  	Subsystem: Broadcom Corporation NetXtreme BCM5751 Gigabit Ethernet PCI Express
>  	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
>  	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>  	Latency: 0, Cache Line Size: 64 bytes
>  	Interrupt: pin A routed to IRQ 216
>  	Region 0: Memory at febf0000 (64-bit, non-prefetchable) [size=64K]
>  	Expansion ROM at febe0000 [disabled] [size=64K]
>  	Capabilities: [48] Power Management version 2
>  		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
>  		Status: D0 PME-Enable+ DSel=0 DScale=1 PME-
>  	Capabilities: [50] Vital Product Data
>  	Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ Queue=0/3 Enable+
>  		Address: 00000000fee0300c  Data: 4142
>  	Capabilities: [d0] Express Endpoint IRQ 0
>  		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag+
>  		Device: Latency L0s <4us, L1 unlimited
>  		Device: AtnBtn- AtnInd- PwrInd-
>  		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
>  		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>  		Device: MaxPayload 128 bytes, MaxReadReq 4096 bytes
>  		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 0
>  		Link: Latency L0s <4us, L1 <64us
>  		Link: ASPM L0s L1 Enabled RCB 64 bytes CommClk+ ExtSynch-
>  		Link: Speed 2.5Gb/s, Width x1
> 
> 
> -- 
> A: Top Posters!                                      |  s/y Charlotta |
> Q: What is the most annoying thing on mailing lists? |    FIN-2674    |
>    http://www.fe83.org/ Finn Express Purjehtijat ry   |  ============= |
> Harald H Hannelius | harald (At) iki (dot) fi | GSM +358 50 594 1020
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
