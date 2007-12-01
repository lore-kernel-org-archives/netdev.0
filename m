From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: sky2: eth0: hung mac 7:69 fifo 0 (165:176)
Date: Fri, 30 Nov 2007 16:55:34 -0800
Message-ID: <20071130165534.01782425@freepuppy.rosehill>
References: <873av03c0f.fsf@burly.wgtn.ondioline.org>
	<4749E832.1060800@linux-foundation.org>
	<200711251657.42821.el@prans.net>
	<200711300848.15424.el@prans.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Paul Collins <paul@burly.ondioline.org>, netdev@vger.kernel.org
To: Elvis Pranskevichus <el@prans.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59399 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752357AbXLAA4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2007 19:56:21 -0500
In-Reply-To: <200711300848.15424.el@prans.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 30 Nov 2007 08:48:15 -0500
Elvis Pranskevichus <el@prans.net> wrote:

> On Sun November 25 2007 04:57:42 pm Elvis Pranskevichus wrote:
> > On Sunday November 25 2007 04:25:06 pm Stephen Hemminger wrote:
> > > Two important bits of data:
> > >
> > > 1) What is hardware (output of lspci and dmesg) would be useful to know
> > > which type
> > > of board is involved.
> >
> > uname -srvm:
> >
> > Linux 2.6.24-rc3 #1 SMP PREEMPT Sat Nov 17 00:26:41 EST 2007 x86_64
> >
> > CONFIG_NO_HZ=y
> >
> > lscpi -vvvv:
> >
> > 03:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053 PCI-E
> > Gigabit Ethernet Controller (rev 22) Subsystem: Giga-byte Technology
> > Marvell 88E8053 Gigabit Ethernet Controller (Gigabyte) Control: I/O+ Mem+
> > BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
> > DisINTx+ Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> > <TAbort- <MAbort- >SERR- <PERR- INTx- Latency: 0, Cache Line Size: 32 bytes
> >         Interrupt: pin A routed to IRQ 315
> >         Region 0: Memory at f1000000 (64-bit, non-prefetchable) [size=16K]
> >         Region 2: I/O ports at a000 [size=256]
> >         [virtual] Expansion ROM at f0000000 [disabled] [size=128K]
> >         Capabilities: [48] Power Management version 2
> >                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA
> > PME(D0+,D1+,D2+,D3hot+,D3cold+) Status: D0 PME-Enable- DSel=0 DScale=1 PME-
> >         Capabilities: [50] Vital Product Data
> >         Capabilities: [5c] Message Signalled Interrupts: Mask- 64bit+
> > Queue=0/1 Enable+ Address: 00000000fee0300c  Data: 4199
> >         Capabilities: [e0] Express (v1) Legacy Endpoint, MSI 00
> >                 DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s
> > unlimited, L1 unlimited ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
> > DevCtl: Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+ RlxdOrd-
> > ExtTag- PhantFunc- AuxPwr- NoSnoop- MaxPayload 128 bytes, MaxReadReq 512
> > bytes DevSta: CorrErr+ UncorrErr+ FatalErr- UnsuppReq+ AuxPwr+ TransPend-
> > LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s, Latency L0 <256ns, L1
> > unlimited ClockPM- Suprise- LLActRep- BwNot-
> >                 LnkCtl: ASPM Disabled; RCB 128 bytes Disabled- Retrain-
> > CommClk- ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt- LnkSta: Speed
> > 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
> > Capabilities: [100] Advanced Error Reporting
> >
> > dmesg | grep sky2:
> >
> > sky2 0000:03:00.0: v1.20 addr 0xf1000000 irq 16 Yukon-EC (0xb6) rev 2
> > sky2 eth0: addr 00:16:e6:84:58:5d
> > sky2 eth0: enabling interface
> > sky2 eth0: Link is up at 100 Mbps, full duplex, flow control both
> >
> > Error related part:
> >
> > sky2 eth0: hung mac 123:3 fifo 194 (150:144)
> > sky2 eth0: receiver hang detected
> > sky2 eth0: disabling interface
> > NETDEV WATCHDOG: eth0: transmit timed out
> > sky2 eth0: tx timeout
> > sky2 eth0: transmit ring 178 .. 188 report=178 done=178
> > NETDEV WATCHDOG: eth0: transmit timed out
> > sky2 eth0: tx timeout
> > sky2 eth0: transmit ring 178 .. 188 report=178 done=178
> > ...
> > <repeats endlessly>
> >
> > > 2) Is this a regression, or always the case.  Does 2.6.23 work okay?
> >
> > 2.6.23 works okay in terms of restarting the controller properly,
> > i.e sky2_watchdog() actually works. While in 2.6.24 I only see that
> > sky2_down() is called and never gets to sky2_up(). Moreover, the entire
> > box becomes unresponsive to events (e.g the keyboard doesn't work etc).
> >
> > > The problems with FIFO in the past, have been limited to Yukon-EC
> > > without flow control.
> > > The hardware has bugs where if the FIFO gets exactly filled it hangs.
> > > Flow control avoids
> > > the problem.
> >
> > Yeah, unfortunately it's Yukon-EC.
> >
> >
> > Thanks,
> 
> Hi Stephen,
> 
> I was able to investigate this issue a little further by adding a bunch of 
> printks in the problem area. What I discovered was that when the card hangs 
> and sky2_watchdog() kicks in, the sky2_restart() process stucks at 
> napi_synchronize() in sky2_down().
> 
> @@ -1699,6 +1695,9 @@ static int sky2_down(struct net_device *dev)
>         ctrl &= ~(GM_GPCR_TX_ENA | GM_GPCR_RX_ENA);
>         gma_write16(hw, port, GM_GP_CTRL, ctrl);
> 
>         /* Make sure no packets are pending */
> -->     napi_synchronize(&hw->napi);
> 
> This was introduced by commit 6de16237c78a9d: sky2: shutdown cleanup.
> 
> My guess is that napi still tries hard to send some packets even though at 
> that point the card is not capable of sending anything, thus the loop inside 
> napi_synchronize() becomes an infinite one.
> 
> I've removed this line for now to see if it helps on the next hang =)
> 
> Thanks,

Does this fix it?

--- a/drivers/net/sky2.c	2007-11-30 16:51:50.000000000 -0800
+++ b/drivers/net/sky2.c	2007-11-30 16:54:52.000000000 -0800
@@ -2906,16 +2906,14 @@ static void sky2_restart(struct work_str
 	int i, err;
 
 	rtnl_lock();
-	sky2_write32(hw, B0_IMSK, 0);
-	sky2_read32(hw, B0_IMSK);
-	napi_disable(&hw->napi);
-
 	for (i = 0; i < hw->ports; i++) {
 		dev = hw->dev[i];
 		if (netif_running(dev))
 			sky2_down(dev);
 	}
 
+	napi_disable(&hw->napi);
+	sky2_write32(hw, B0_IMSK, 0);
 	sky2_reset(hw);
 	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
 	napi_enable(&hw->napi);
