From: Mikael Pettersson <mikpe@it.uu.se>
Subject: [BUG] 2.6.29-rc7 broke r8169 MAC on Thecus n2100 ARM board
Date: Mon, 9 Mar 2009 21:29:01 +0100 (MET)
Message-ID: <200903092029.n29KT1DS004531@harpo.it.uu.se>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aun.it.uu.se ([130.238.12.36]:65341 "EHLO aun.it.uu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752785AbZCIU3J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2009 16:29:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the 2.6.29-rc7 kernel I'm unable to 'ifup' eth0 on my ARM-based
Thecus n2100 NAS box, which has an RTL8169 NIC (10ec:8169 (rev 10)).
A diff of the kernel logs from 2.6.29-rc6 and -rc7 shows that -rc7
first mangles and then zaps the MAC addresses:

--- dmesg-2.6.29-rc6	2009-03-09 20:27:49.000000000 +0100
+++ dmesg-2.6.29-rc7	2009-03-09 20:25:54.000000000 +0100
@@ -145,11 +145,13 @@
 r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
 r8169 0000:00:01.0: enabling Mem-Wr-Inval
 r8169 0000:00:01.0: no PCI Express capability
-eth0: RTL8169sb/8110sb at 0xe080c200, 00:14:fd:30:11:78, XID 10000000 IRQ 27
+r8169 0000:00:01.0: MAC address found in EEPROM: 00:14:fd:10:00:00
+eth0: RTL8169sb/8110sb at 0xe080c200, 00:00:00:00:00:00, XID 10000000 IRQ 27
 r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
 r8169 0000:00:02.0: enabling Mem-Wr-Inval
 r8169 0000:00:02.0: no PCI Express capability
-eth1: RTL8169sb/8110sb at 0xe0810300, 00:14:fd:30:11:79, XID 10000000 IRQ 30
+r8169 0000:00:02.0: MAC address found in EEPROM: 00:14:fd:10:00:00
+eth1: RTL8169sb/8110sb at 0xe0810300, 00:00:00:00:00:00, XID 10000000 IRQ 30
 Driver 'sd' needs updating - please use bus_type methods
 sata_sil 0000:00:03.0: version 2.4
 sata_sil 0000:00:03.0: Applying R_ERR on DMA activate FIS errata fix
@@ -242,6 +244,4 @@
 EXT3 FS on sda5, internal journal
 EXT3-fs: mounted filesystem with ordered data mode.
 Adding 2008116k swap on /dev/sda3.  Priority:-1 extents:1 across:2008116k 
-r8169: eth0: link up
-r8169: eth0: link up
 warning: `dbus-daemon' uses 32-bit capabilities (legacy support in use)

Reverting 6709fe9a27e43a4931938fe0d7f2cc5edef31386
"r8169: read MAC address from EEPROM on init (2nd attempt)"
fixes the problem on this machine.

/Mikael
