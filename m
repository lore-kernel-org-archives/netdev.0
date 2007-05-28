From: "Andrew Paprocki" <andrew@ishiboo.com>
Subject: r8169 in 2.6.18 silently corrupting data, 2.6.22-rc3 link not detected at all
Date: Mon, 28 May 2007 14:10:44 -0400
Message-ID: <76366b180705281110j472671a1h6ff5ed5fa711c45e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andrew@ishiboo.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.236]:40359 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751253AbXE1SKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 May 2007 14:10:45 -0400
Received: by wr-out-0506.google.com with SMTP id 76so500213wra
        for <netdev@vger.kernel.org>; Mon, 28 May 2007 11:10:44 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've installed a Debian lenny test DVD onto a system with two r8169
devices, and the default 2.6.18 kernel that comes with the install DVD
causes silent data corruption! The network appears to be working fine,
but if you attempt to transfer any sizable amount of data (a 10meg
file of /dev/zero, for instance), you get data corruption. In the
/dev/zero case, I found 3 points in the file which were corrupted with
the same exact data each time:
000c 76ae b516 0016

This struck me as strange, so I checked and it is directly connected
to the MAC addr of the ethernet card: 00:0c:76:ae:b5:16

I figured that a newer kernel might fix this issue, so I built
2.6.22-rc3 and under that kernel the r8169 device doesn't work at all.
It never detects a valid link. I insmod'd the driver with debug=16 and
all I see it printing is "eth0: PHY reset until link up" on a timer.

I see some patches flying around for r8169.c, but I'm not sure if
either of these two cases are known/fixed. Also, this is a gigabit NIC
on a gig-e switched network, yet mii-tool only reports 10mb-hd speed..
?

Thanks -Andrew

I'll dump some info:

(under the stock Debian installed 2.6.18 kernel)
Linux lx900 2.6.18-4-486 #1 Mon Mar 26 16:39:10 UTC 2007 i586 GNU/Linux

r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
eth0: RTL8169sc/8110sc at 0xd0014000, 00:0c:76:ae:b5:16, IRQ 5
r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
eth1: RTL8169sc/8110sc at 0xd0030000, 00:0c:76:ae:b5:17, IRQ 11

# lspci -vv -s 0d.0
00:0d.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169
Gigabit Ethernet (rev 10)
        Subsystem: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 32 (8000ns min, 16000ns max), Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 5
        Region 0: I/O ports at f600 [size=256]
        Region 1: Memory at effff000 (32-bit, non-prefetchable) [size=256]
        [virtual] Expansion ROM at 10080000 [disabled] [size=128K]
        Capabilities: [dc] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
PME(D0-,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-

# mii-tool -vv eth0
Using SIOCGMIIPHY=0x8947
eth0: 10 Mbit, half duplex, link ok
  registers for MII PHY 32:
    0000 794d 001c c912 0de1 0020 0004 2001
    0000 0300 0000 0000 1007 f880 0000 3000
    0060 0c00 0000 0000 1060 0000 080e 2108
    2740 8c00 0040 801a 8426 8000 0123 0000
  product info: vendor 00:07:32, model 17 rev 2
  basic mode:   10 Mbit, half duplex
  basic status: link ok
  capabilities: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
  advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-control
  link partner: 10baseT-HD

# ethtool -S eth0
NIC statistics:
     tx_packets: 4397
     rx_packets: 6701
     tx_errors: 1
     rx_errors: 999
     rx_missed: 0
     align_errors: 25770
     tx_single_collisions: 532
     tx_multi_collisions: 313
     unicast: 6514
     broadcast: 187
     multicast: 0
     tx_aborted: 0
     tx_underrun: 0
