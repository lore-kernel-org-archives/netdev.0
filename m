From: "=?ISO-8859-1?Q?Oliver_Pinter_(Pint=E9r_Oliv=E9r)?="
	<oliver.pntr@gmail.com>
Subject: [BUG] skge 0000:02:05: read data parity error
Date: Mon, 14 Jan 2008 20:57:49 +0100
Message-ID: <6101e8c40801141157j1ce7d3f0if2e4eb2344b6c844@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	oliver.pntr@gmail.com
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:65085 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751745AbYANT5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 14:57:51 -0500
Received: by fg-out-1718.google.com with SMTP id e21so2378456fga.17
        for <netdev@vger.kernel.org>; Mon, 14 Jan 2008 11:57:49 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All!

It is fully reproductable under 2.6.22.15, 2.6.23.13 (all tainted and
not tainted [4 different kernel] ) and 2 different PC:

[BUG] skge 0000:02:05: read data parity error
[BUG] skge 0000:02:05: read data parity error

steps:
1. login as root
2. start mc
3. cd /sys/bus/pci/drivers/skge/0000:02:05.0
4. press F3 (mcview) on resource0
5. the system hang up, without panic or bug ... only this message
printed 2x: [BUG] skge 0000:02:05: read data parity error

when I used cat for show what is in file , then bocome this message:
 cat: resource0: Input/output error
but the permissions is:
 -rw------- 1 root root 16384 2008-01-14 20:36 resource0

when I used mcview for show whats in file, then the system hang up,
and not reagiert neither for SysRQ-s, only for hard reset.

-----------

PC1.:
00:00.0 Host bridge [0600]: Intel Corporation 945G/GZ/P/PL Express
Memory Controller Hub [8086:2770] (rev 02)
00:01.0 PCI bridge [0604]: Intel Corporation 945G/GZ/P/PL Express PCI
Express Root Port [8086:2771] (rev 02)
00:1b.0 Audio device [0403]: Intel Corporation 82801G (ICH7 Family)
High Definition Audio Controller [8086:27d8] (rev 01)
00:1d.0 USB Controller [0c03]: Intel Corporation 82801G (ICH7 Family)
USB UHCI #1 [8086:27c8] (rev 01)
00:1d.1 USB Controller [0c03]: Intel Corporation 82801G (ICH7 Family)
USB UHCI #2 [8086:27c9] (rev 01)
00:1d.2 USB Controller [0c03]: Intel Corporation 82801G (ICH7 Family)
USB UHCI #3 [8086:27ca] (rev 01)
00:1d.3 USB Controller [0c03]: Intel Corporation 82801G (ICH7 Family)
USB UHCI #4 [8086:27cb] (rev 01)
00:1d.7 USB Controller [0c03]: Intel Corporation 82801G (ICH7 Family)
USB2 EHCI Controller [8086:27cc] (rev 01)
00:1e.0 PCI bridge [0604]: Intel Corporation 82801 PCI Bridge
[8086:244e] (rev e1)
00:1f.0 ISA bridge [0601]: Intel Corporation 82801GB/GR (ICH7 Family)
LPC Interface Bridge [8086:27b8] (rev 01)
00:1f.2 IDE interface [0101]: Intel Corporation 82801GB/GR/GH (ICH7
Family) Serial ATA Storage Controller IDE [8086:27c0] (rev 01)
00:1f.3 SMBus [0c05]: Intel Corporation 82801G (ICH7 Family) SMBus
Controller [8086:27da] (rev 01)
01:00.0 VGA compatible controller [0300]: nVidia Corporation GeForce
7300 GS [10de:01df] (rev a1)
02:01.0 Ethernet controller [0200]: Atheros Communications, Inc.
AR5212 802.11abg NIC [168c:0013] (rev 01)
02:05.0 Ethernet controller [0200]: Marvell Technology Group Ltd.
88E8001 Gigabit Ethernet Controller [11ab:4320] (rev 13)

PC2:
00:00.0 Host bridge [0600]: Intel Corporation 82875P/E7210 Memory
Controller Hub [8086:2578] (rev 02)
00:01.0 PCI bridge [0604]: Intel Corporation 82875P Processor to AGP
Controller [8086:2579] (rev 02)
00:06.0 System peripheral [0880]: Intel Corporation 82875P/E7210
Processor to I/O Memory Interface [8086:257e] (rev 02)
00:1d.0 USB Controller [0c03]: Intel Corporation 82801EB/ER
(ICH5/ICH5R) USB UHCI Controller #1 [8086:24d2] (rev 02)
00:1d.1 USB Controller [0c03]: Intel Corporation 82801EB/ER
(ICH5/ICH5R) USB UHCI Controller #2 [8086:24d4] (rev 02)
00:1d.7 USB Controller [0c03]: Intel Corporation 82801EB/ER
(ICH5/ICH5R) USB2 EHCI Controller [8086:24dd] (rev 02)
00:1e.0 PCI bridge [0604]: Intel Corporation 82801 PCI Bridge
[8086:244e] (rev c2)
00:1f.0 ISA bridge [0601]: Intel Corporation 82801EB/ER (ICH5/ICH5R)
LPC Interface Bridge [8086:24d0] (rev 02)
00:1f.1 IDE interface [0101]: Intel Corporation 82801EB/ER
(ICH5/ICH5R) IDE Controller [8086:24db] (rev 02)
00:1f.2 RAID bus controller [0104]: Intel Corporation 82801ER (ICH5R)
SATA Controller [8086:24df] (rev 02)
00:1f.3 SMBus [0c05]: Intel Corporation 82801EB/ER (ICH5/ICH5R) SMBus
Controller [8086:24d3] (rev 02)
00:1f.5 Multimedia audio controller [0401]: Intel Corporation
82801EB/ER (ICH5/ICH5R) AC'97 Audio Controller [8086:24d5] (rev 02)
01:00.0 VGA compatible controller [0300]: ATI Technologies Inc RV350
AP [Radeon 9600] [1002:4150]
01:00.1 Display controller [0380]: ATI Technologies Inc RV350 AP
[Radeon 9600] (Secondary) [1002:4170]
02:05.0 Ethernet controller [0200]: 3Com Corporation 3c940
10/100/1000Base-T [Marvell] [10b7:1700] (rev 12)
02:0a.0 Ethernet controller [0200]: Atheros Communications, Inc.
AR5212/AR5213 Multiprotocol MAC/baseband processor [168c:0013] (rev
01)
-- 
Thanks,
Oliver
