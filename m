From: Chris Stromsoe <cbs@cts.ucla.edu>
Subject: skge- "soft lockup on CPU#0" with mtu=9000 (2.6.20.1 + web100 patch)
Date: Thu, 8 Mar 2007 11:20:40 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0703081101390.21717@potato.cts.ucla.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-1.smtp.ucla.edu ([169.232.46.136]:47856 "EHLO
	smtp-1.smtp.ucla.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933099AbXCHTUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 14:20:44 -0500
Received: from potato.cts.ucla.edu (potato.cts.ucla.edu [128.97.128.80])
	by smtp-1.smtp.ucla.edu (8.13.8/8.13.8) with ESMTP id l28JKeF6030311
	for <netdev@vger.kernel.org>; Thu, 8 Mar 2007 11:20:40 -0800
Received: from potato.cts.ucla.edu (localhost [127.0.0.1])
	by potato.cts.ucla.edu (8.13.4/8.13.4/Debian-3sarge3) with ESMTP id l28JKeLW023395
	for <netdev@vger.kernel.org>; Thu, 8 Mar 2007 11:20:40 -0800
Received: from localhost (cbs@localhost)
	by potato.cts.ucla.edu (8.13.4/8.13.4/Submit) with ESMTP id l28JKeRq023392
	for <netdev@vger.kernel.org>; Thu, 8 Mar 2007 11:20:40 -0800
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Within 2 or 3 minutes after issuing

ip link set bond1 mtu 9000

I get one "NETDEV WATCHDOG: eth2: transmit timed out" to the console, and 
then this starts to repeat:

BUG: soft lockup detected on CPU#0!
  [<c0103667>] show_trace_log_lvl+0x19/0x2e
  [<c010368e>] show_trace+0x12/0x14
  [<c010377a>] dump_stack+0x14/0x16
  [<c0134964>] softlockup_tick+0x9f/0xae
  [<c0120f38>] run_local_timers+0x12/0x14
  [<c0120d89>] update_process_times+0x3e/0x63
  [<c010ceb0>] smp_apic_timer_interrupt+0x6f/0x7e
  [<c010337c>] apic_timer_interrupt+0x28/0x30
  [<d088d5b3>] skge_tx_clean+0x1d/0x87 [skge]
  [<d088d663>] skge_tx_timeout+0x46/0x4c [skge]
  [<c02b0854>] dev_watchdog+0x79/0xb9
  [<c0120ec9>] run_timer_softirq+0x10e/0x16b
  [<c011cebb>] __do_softirq+0x65/0xc3
  [<c0104d55>] do_softirq+0x54/0xbb
  =======================

Once the soft lockups start, the machine becomes unresponsive and has to 
be power cycled.

bond1 is a dual-port syskonnect sk-98xx with both ports bonded in 
active-backup mode.

kernel is 2.6.20.1 with the web100 kernel patches from http://web100.org/. 
I'm building a plain 2.6.20.1 without the patches right now and will test 
when it finishes compiling.

lspci for the card shows:

fresno:~ # lspci -vv -s 02:01.0
0000:02:01.0 Ethernet controller: Syskonnect (Schneider & Koch) SK-98xx Gigabit Ethernet Server Adapter (rev 11)
         Subsystem: Syskonnect (Schneider & Koch) SK-9844 Gigabit Ethernet Server Adapter (SK-NET GE-SX dual link)
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B-
         Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Latency: 64 (5750ns min, 7750ns max), Cache Line Size: 0x08 (32 bytes)
         Interrupt: pin A routed to IRQ 22
         Region 0: Memory at febfc000 (32-bit, non-prefetchable) [size=16K]
         Region 1: I/O ports at e800 [size=256]
         Expansion ROM at febc0000 [disabled] [size=128K]
         Capabilities: [48] Power Management version 1
                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
                 Status: D0 PME-Enable- DSel=0 DScale=1 PME-
         Capabilities: [50] Vital Product Data




-Chris
