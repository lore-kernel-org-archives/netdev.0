From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: r8169 mac reading/writing broken
Date: Sat, 27 Mar 2010 12:28:07 +0200
Message-ID: <4BADDDB7.4010005@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Francois Romieu <romieu@fr.zoreil.com>,
	Ivan Vecera <ivecera@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:20851 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878Ab0C0K2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 06:28:08 -0400
Received: by ey-out-2122.google.com with SMTP id d26so1021539eyd.19
        for <netdev@vger.kernel.org>; Sat, 27 Mar 2010 03:28:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems that my r8169 mac address is lost when r8169 module is reloaded,
or system is soft rebooted. Hard power reset recovers the mac address again.
The commit cc098dc705895f6b0109b7e8e026ac2b8ae1c0a1 (r8169: restore mac addr
in rtl8169_remove_one and rtl_shutdown) seems to have broken it. The first four
bytes of mac address go zeroes because of this.

I did some more testing, and added debugging info to rtl_rar_set(). It would
appear that even if I write any mac address (with ifconfig) and reread the
MAC0..MAC5 register, the first four bytes get zeroed. So it would sounds like
the hardware is faulty, or that the rtl_rar_set function is buggy.

Any suggestions to fix this?

The hardware in question is a 3-in-1 NIC. Each three PCI devices shows up as
something like:

00:09.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd. RTL-8110SC/8169SC Gigabit Ethernet [10ec:8167] (rev 10)
	Subsystem: Jetway Information Co., Ltd. Device [16f3:10ec]
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64 (8000ns min, 16000ns max), Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 18
	Region 0: I/O ports at f200 [size=256]
	Region 1: Memory at fdfff000 (32-bit, non-prefetchable) [size=256]
	[virtual] Expansion ROM at 3c000000 [disabled] [size=128K]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0-,D1+,D2+,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: r8169

And the kernel drivers prints the following at startup:

r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
r8169 0000:00:09.0: PCI->APIC IRQ transform: INT A -> IRQ 18
r8169 0000:00:09.0: no PCI Express capability
eth0: RTL8169sc/8110sc at 0xf81ae000, 00:30:18:a6:2b:6c, XID 18000000 IRQ 18
r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
r8169 0000:00:0b.0: PCI->APIC IRQ transform: INT A -> IRQ 19
r8169 0000:00:0b.0: no PCI Express capability
eth1: RTL8169sc/8110sc at 0xf81b2000, 00:30:18:a6:2b:6d, XID 18000000 IRQ 19
r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
r8169 0000:00:0c.0: PCI->APIC IRQ transform: INT A -> IRQ 16
r8169 0000:00:0c.0: no PCI Express capability
eth2: RTL8169sc/8110sc at 0xf81b6000, 00:30:18:a6:2b:6e, XID 18000000 IRQ 16

- Timo
