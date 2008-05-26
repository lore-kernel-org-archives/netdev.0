From: Mikael Pettersson <mikpe@it.uu.se>
Subject: Re: sky2 oops in 2.6.26-rc3
Date: Mon, 26 May 2008 09:11:22 +0200
Message-ID: <18490.25242.790320.257467@harpo.it.uu.se>
References: <200805251727.m4PHRTIi024468@harpo.it.uu.se>
	<20080525115644.21076a48@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Mikael Pettersson <mikpe@it.uu.se>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aun.it.uu.se ([130.238.12.36]:35213 "EHLO aun.it.uu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752861AbYEZHMF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 May 2008 03:12:05 -0400
In-Reply-To: <20080525115644.21076a48@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger writes:
 > On Sun, 25 May 2008 19:27:29 +0200 (MEST)
 > Mikael Pettersson <mikpe@it.uu.se> wrote:
 > 
 > > Shortly after booting 2.6.26-rc3 on my ASUS P5B-E Plus
 > > today, the kernel oopsed in sky2_mac_intr, leaving the
 > > system totally dead. I had to copy the oops manually:
 > > 
 > > Call trace:
 > >   sky2_hw_error
 > >   sky2_poll
 > >   run_rebalance_domains
 > >   net_rx_action
 > >   __do_softirq
 > >   smp_apic_timer_interrupt
 > >   mwait_idle
 > >   apic_timer_interrupt
 > >   mwait_idle
 > >   mwait_idle
 > >   cpu_idle
 > > EIP: sky2_mac_intr+0x32
 > > 
 > > lspci -vvxxx on the sky2 chip shows:
 > > 
 > > 02:00.0 Ethernet controller: Marvell Technology Group Ltd. Unknown device 4364 (rev 12)
 > > 	Subsystem: ASUSTeK Computer Inc. Unknown device 81f8
 > > 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
 > > 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
 > > 	Latency: 0, Cache Line Size: 32 bytes
 > > 	Interrupt: pin A routed to IRQ 17
 > > 	Region 0: Memory at ff9fc000 (64-bit, non-prefetchable) [size=16K]
 > > 	Region 2: I/O ports at c800 [size=256]
 > > 	Expansion ROM at ff9c0000 [disabled] [size=128K]
 > > 	Capabilities: [48] Power Management version 3
 > > 		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
 > > 		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
 > > 	Capabilities: [50] Vital Product Data
 > > 	Capabilities: [5c] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
 > > 		Address: 0000000000000000  Data: 0000
 > > 	Capabilities: [e0] Express Legacy Endpoint IRQ 0
 > > 		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
 > > 		Device: Latency L0s unlimited, L1 unlimited
 > > 		Device: AtnBtn- AtnInd- PwrInd-
 > > 		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
 > > 		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
 > > 		Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
 > > 		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 0
 > > 		Link: Latency L0s <256ns, L1 unlimited
 > > 		Link: ASPM Disabled RCB 128 bytes CommClk+ ExtSynch-
 > > 		Link: Speed 2.5Gb/s, Width x1
 > > 	Capabilities: [100] Advanced Error Reporting
 > > 00: ab 11 64 43 07 00 10 00 12 00 00 02 08 00 00 00
 > > 10: 04 c0 9f ff 00 00 00 00 01 c8 00 00 00 00 00 00
 > > 20: 00 00 00 00 00 00 00 00 00 00 00 00 43 10 f8 81
 > > 30: 00 00 9c ff 48 00 00 00 00 00 00 00 0a 01 00 00
 > > 40: 00 00 f0 01 00 80 a0 01 01 50 03 fe 00 20 00 13
 > > 50: 03 5c 00 80 00 00 00 01 00 00 00 01 05 e0 80 00
 > > 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 > > 70: 00 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 > > 80: 00 00 00 00 00 70 00 00 00 00 00 00 82 a8 e8 00
 > > 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 > > a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 > > b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 > > c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 > > d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 > > e0: 10 00 11 00 c0 8f 00 00 00 20 19 00 11 ac 07 00
 > > f0: 48 00 11 10 00 00 00 00 00 00 00 00 00 00 00 00
 > > 
 > > This is the first time I've seen this problem.
 > > 
 > > I do have a recurring problem where the sky2 chip sometimes
 > > isn't detected on a cold boot. A reboot typically solves that.
 > > 
 > > /Mikael
 > 
 > sky2_hw_error prints information in log so dmesg output would be helpful.

Like I wrote, the box died when this happened, which is why I had
to copy the oops text manually. I did check /var/log/messages after
the reboot, but nothing got logged there.

 > But it means the hardware is sick (like bad DMA), so there isn't much
 > you can do.  If possible, see if either the vendor sk98lin driver or windows
 > works on this hardware.

Well, W2KPROSP4 works, but that's not the issue. The Linux sky2 driver
works like 99% of the time, it's just occasional cold boot detection
failures and now this one indicent.

I'll try to debug it a little more next time it fails on a cold boot.
