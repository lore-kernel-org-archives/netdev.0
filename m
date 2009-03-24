From: Andrew Lutomirski <amluto@gmail.com>
Subject: e1000e incorrectly reports a carrier until I plug in and unplug the
	cable
Date: Tue, 24 Mar 2009 16:30:20 -0400
Message-ID: <cb0375e10903241330q212270f8gc664809a4e5d8ae8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: e1000-devel@lists.sourceforge.net,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:34224 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756182AbZCXUaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 16:30:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is on a Lenovo x200s, and I have this bug on both 2.6.29 and
2.6.28.8.  I haven't tried any other kernels on this machine.

When I boot the system without an ethernet cable plugged in, ip link
does not show NO-CARRIER until I've plugged in and unplugged my
ethernet cable.  Oddly enough, ethtool shows the correct status the
whole time.  This confuses me and NetworkManager.

dmesg says:

[    2.338427] 0000:00:19.0: eth0: (PCI Express:2.5GB/s:Width x1)
xx:xx:xx:xx:xx:xx
[    2.338489] 0000:00:19.0: eth0: Intel(R) PRO/1000 Network Connection
[    2.338565] 0000:00:19.0: eth0: MAC: 6, PHY: 8, PBA No: 1008ff-0ff

...

[   35.806117] ADDRCONF(NETDEV_UP): eth0: link is not ready

ip link says (incorrectly, I believe):

2: eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast state
UNKNOWN qlen 1000
    link/ether xx:xx:xx:xx:xx:xx brd ff:ff:ff:ff:ff:ff

ethtool eth0 says (at the end):

	Link detected: no

Now I plug in an ethernet cable and unplug it again (with eth0 up and
NetworkManager stopped).  dmesg says:

[  763.091333] ADDRCONF(NETDEV_UP): eth0: link is not ready
[  766.224944] 0000:00:19.0: eth0: Link is Up 1000 Mbps Full Duplex,
Flow Control: RX/TX
[  766.226690] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[  769.436269] 0000:00:19.0: eth0: Link is Down
[  776.672111] eth0: no IPv6 routers present

ip link says:

2: eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast
state DOWN qlen 1000
    link/ether xx:xx:xx:xx:xx:xx brd ff:ff:ff:ff:ff:ff

Setting eth0 down and back up again does not re-break it.

lspci -vvvvvvvvvxxxxxxxxxxxx says:

00:19.0 Ethernet controller: Intel Corporation 82567LM Gigabit Network
Connection (rev 03)
        Subsystem: Lenovo Device 20ee
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0
        Interrupt: pin A routed to IRQ 27
        Region 0: Memory at f2600000 (32-bit, non-prefetchable) [size=128K]
        Region 1: Memory at f2625000 (32-bit, non-prefetchable) [size=4K]
        Region 2: I/O ports at 1840 [size=32]
        Capabilities: <access denied>
        Kernel driver in use: e1000e
00: 86 80 f5 10 07 05 10 00 03 00 00 02 00 00 00 00
10: 00 00 60 f2 00 50 62 f2 41 18 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 aa 17 ee 20
30: 00 00 00 00 c8 00 00 00 00 00 00 00 0b 01 00 00

--Andy
