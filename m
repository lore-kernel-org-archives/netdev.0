From: "Benjamin S." <sbenni@gmx.de>
Subject: r8169 not advertising 1000mbit after suspend anymore
Date: Sun, 19 Jul 2009 19:09:37 +0200
Message-ID: <20090719190937.7393ea99@pluto-lenny.milky.way>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:55652 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754493AbZGSRGu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jul 2009 13:06:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello,

I have a Gigabyte GA-MA78G-DS3H mainboard with a RTL8111/8168B Realtek 
Gigabit Ethernet Controller. Until first suspend everything works as 
expected, but after suspend only 100mbit are used instead of 1000.


Interesting part of lspci -v:
02:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 02)
	Subsystem: Giga-byte Technology Device e000
	Flags: bus master, fast devsel, latency 0, IRQ 26
	I/O ports at de00 [size=256]
	Memory at fdaff000 (64-bit, prefetchable) [size=4K]
	Memory at fdae0000 (64-bit, prefetchable) [size=64K]
	[virtual] Expansion ROM at fda00000 [disabled] [size=64K]
	Capabilities: [40] Power Management version 3
	Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+ Queue=0/1 Enable+
	Capabilities: [70] Express Endpoint, MSI 01
	Capabilities: [b0] MSI-X: Enable- Mask- TabSize=2
	Capabilities: [d0] Vital Product Data <?>
	Capabilities: [100] Advanced Error Reporting <?>
	Capabilities: [140] Virtual Channel <?>
	Capabilities: [160] Device Serial Number 78-56-34-12-78-56-34-12
	Kernel driver in use: r8169
	Kernel modules: r8169

mii-tool after suspend:
eth0: negotiated 100baseTx-FD flow-control, link ok
  product info: vendor 00:07:32, model 17 rev 2
  basic mode:   autonegotiation enabled
  basic status: autonegotiation complete, link ok
  capabilities: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
  advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-control
  link partner: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-control

mii-tool after setting speed to 1000 with "ethtool -s eth0 speed 1000":
eth0: negotiated 1000baseT-FD flow-control, link ok
  product info: vendor 00:07:32, model 17 rev 2
  basic mode:   autonegotiation enabled
  basic status: autonegotiation complete, link ok
  capabilities: 1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
  advertising:  1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-control
  link partner: 1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-control


I did not knew if the Switch could be the problem and thus I connected the 
card to my laptop which also has a gigabit controller, but the result was 
the same as above.


regards,
Benjamin
