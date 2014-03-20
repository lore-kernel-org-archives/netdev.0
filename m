From: Thomas Gleixner <tglx@linutronix.de>
Subject: i217-LM boot wreckage
Date: Thu, 20 Mar 2014 13:58:45 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1403201332400.18573@ionos.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: todd.fujinaka@intel.com, e1000-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:41573 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754924AbaCTM6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 08:58:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On a Lenovo ThinkCentre M93z I have the following issue:

When the network cable is not connected at power on time and plugged
in later, then the driver does not receive any packets. The DHCP TX
packets are received by the DHCP server, but the answer gets lost in
the 217-LM.

If I plug the network cable before power on, the chip works perfectly
fine.

I'm running latest mainline. ethtool -i output is:

driver: e1000e
version: 2.3.2-k
firmware-version: 0.12-4
bus-info: 0000:00:19:0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: no

ethtool -S shows all counters 0 except tx_packets, tx_bytes and
tx_multicast in the bad case

lspci for the device:

00:19.0 Ethernet controller: Intel Corporation Ethernet Connection I217-LM (rev 04)
	Subsystem: Lenovo Device 309b
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 42
	Region 0: Memory at f7f00000 (32-bit, non-prefetchable) [size=128K]
	Region 1: Memory at f7f3d000 (32-bit, non-prefetchable) [size=4K]
	Region 2: I/O ports at f080 [size=32]
	Capabilities: [c8] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0f00c  Data: 4182
	Capabilities: [e0] PCI Advanced Features
		AFCap: TP+ FLR+
		AFCtrl: FLR-
		AFStatus: TP-
	Kernel driver in use: e1000e

The output is identical for the good and the bad case except for the
MSI interrupt number, but thats related to the init ordering and not a
functional issue. The bios does not give out the MSI irq numbers.

[    1.885503] e1000e: Intel(R) PRO/1000 Network Driver - 2.3.2-k
[    1.885506] e1000e: Copyright(c) 1999 - 2013 Intel Corporation.
[    1.888762] e1000e 0000:00:19.0: Interrupt Throttling Rate (ints/sec) set to dynamic conservative mode
[    1.888781] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[    2.062745] e1000e 0000:00:19.0 eth0: registered PHC clock
[    2.062748] e1000e 0000:00:19.0 eth0: (PCI Express:2.5GT/s:Width x1) fc:4d:d4:41:a9:aa
[    2.062750] e1000e 0000:00:19.0 eth0: Intel(R) PRO/1000 Network Connection
[    2.062795] e1000e 0000:00:19.0 eth0: MAC: 11, PHY: 12, PBA No: FFFFFF-0FF
[   14.709709] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[   14.813686] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[   18.364687] e1000e: eth1 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None

dmesg is identical as well.

So it looks like the BIOS is setting something up, when the cable is
plugged at power on time, which is not visible through our debug
output.

Anything else you want me to try?

Thanks,

	tglx
