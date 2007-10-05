From: NetArt - Grzegorz Nosek <grzegorz.nosek@netart.pl>
Subject: (2.6.18.8) tg3: eth0: The system may be re-ordering memory-mapped I/O cycles to the network device, attempting to recover.
Date: Fri, 5 Oct 2007 11:57:22 +0200
Message-ID: <20071005095722.GA23224@tech.serwery.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tech.netart.pl ([85.128.128.114]:42827 "EHLO tech.serwery.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751999AbXJEKf2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Oct 2007 06:35:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I have encountered an error which looks tg3-related. Upon adding some
htb queue rules (which I don't have handy ATM but can provide if
needed), after some time we get such messages in the kernel log:

Oct 3 17:04:04 sbd kernel: [ 1941.584154] tg3: eth0: The system may be re-ordering memory-mapped I/O cycles to the network device, attempting to recover. Please report the problem to the driver maintainer and include system chipset information.
Oct 3 17:04:04 sbd kernel: [ 1941.686114] tg3: tg3_stop_block timed out, ofs=1400 enable_bit=2
Oct 3 17:04:04 sbd kernel: [ 1941.750691] tg3: eth0: Link is down.
Oct 3 17:04:08 sbd kernel: [ 1945.300166] tg3: eth0: Link is up at 1000 Mbps, full duplex.
Oct 3 17:04:08 sbd kernel: [ 1945.300196] tg3: eth0: Flow control is on for TX and on for RX.

After that, the machine is pretty much dead. It doesn't crash hard
(the messages reached syslog) but the network no longer works, so
a reboot is neccessary anyway.

The machine is a Dell PE860 with two tg3 controllers (the second one
is not used at all):

0000:04:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5721 Gigabit Ethernet PCI Express (rev 11)
        Subsystem: Dell: Unknown device 01e6
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 0, Cache Line Size: 0x10 (64 bytes)
        Interrupt: pin A routed to IRQ 16
        Region 0: Memory at fe8f0000 (64-bit, non-prefetchable) [size=64K]
        Capabilities: [48] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [50] Vital Product Data
        Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=0/3 Enable-
                Address: 042401610720cc0c  Data: 02a0
        Capabilities: [d0] #10 [0001]

0000:05:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5721 Gigabit Ethernet PCI Express (rev 11)
        Subsystem: Dell: Unknown device 01e6
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 0, Cache Line Size: 0x10 (64 bytes)
        Interrupt: pin A routed to IRQ 21
        Region 0: Memory at fe6f0000 (64-bit, non-prefetchable) [size=64K]
        Capabilities: [48] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [50] Vital Product Data
        Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=0/3 Enable-
                Address: 7b3ec2551b8528bc  Data: b274
        Capabilities: [d0] #10 [0001]

lspci output (merged with -n for PCI ids):
0000:00:00.0 0600: 8086:2778 Host bridge: Intel Corp.: Unknown device 2778
0000:00:01.0 0604: 8086:2779 PCI bridge: Intel Corp.: Unknown device 2779
0000:00:1c.0 0604: 8086:27d0 PCI bridge: Intel Corp.: Unknown device 27d0 (rev 01)
0000:00:1c.4 0604: 8086:27e0 PCI bridge: Intel Corp.: Unknown device 27e0 (rev 01)
0000:00:1c.5 0604: 8086:27e2 PCI bridge: Intel Corp.: Unknown device 27e2 (rev 01)
0000:00:1d.0 0c03: 8086:27c8 USB Controller: Intel Corp.: Unknown device 27c8 (rev 01)
0000:00:1d.1 0c03: 8086:27c9 USB Controller: Intel Corp.: Unknown device 27c9 (rev 01)
0000:00:1d.2 0c03: 8086:27ca USB Controller: Intel Corp.: Unknown device 27ca (rev 01)
0000:00:1d.7 0c03: 8086:27cc USB Controller: Intel Corp.: Unknown device 27cc (rev 01)
0000:00:1e.0 0604: 8086:244e PCI bridge: Intel Corp. 82801 PCI Bridge (rev e1)
0000:00:1f.0 0601: 8086:27b8 ISA bridge: Intel Corp.: Unknown device 27b8 (rev 01)
0000:00:1f.1 0101: 8086:27df IDE interface: Intel Corp.: Unknown device 27df (rev 01)
0000:00:1f.2 0101: 8086:27c0 IDE interface: Intel Corp.: Unknown device 27c0 (rev 01)
0000:00:1f.3 0c05: 8086:27da SMBus: Intel Corp.: Unknown device 27da (rev 01)
0000:02:00.0 0604: 8086:032c PCI bridge: Intel Corp. PCI Bridge Hub (rev 09)
0000:04:00.0 0200: 14e4:1659 Ethernet controller: Broadcom Corporation NetXtreme BCM5721 Gigabit Ethernet PCI Express (rev 11)
0000:05:00.0 0200: 14e4:1659 Ethernet controller: Broadcom Corporation NetXtreme BCM5721 Gigabit Ethernet PCI Express (rev 11)
0000:06:05.0 0300: 1002:515e VGA compatible controller: ATI Technologies Inc: Unknown device 515e (rev 02)

We are running several racks of those exact same machines with this
exact same kernel and quite more complicated HTB queues without
problems (except for netconsole crashing networking too, but we can
live without it if need be... it's another story).

I'd suspect hardware issues but this problem reliably occurs with HTB
queues, and reliably does not occur without them. OTOH, all the other
machines work just fine.

If you need any more information, feel free to ask. Please keep me
CC'd as I'm not subscribed to netdev.

Best regards,
 Grzegorz Nosek

