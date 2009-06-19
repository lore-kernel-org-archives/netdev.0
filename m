From: Mikael Pettersson <mikpe@it.uu.se>
Subject: Re: 3rd attempt to initialize MAC address on r8169
Date: Fri, 19 Jun 2009 13:30:32 +0200
Message-ID: <19003.30424.111356.179256@pilspetsen.it.uu.se>
References: <200903092029.n29KT1DS004531@harpo.it.uu.se>
	<20090313201511.GA27827@electric-eye.fr.zoreil.com>
	<9e246b4d0903131921k6fba9b04ge945c2902d4117d0@mail.gmail.com>
	<18875.38673.270977.133982@pilspetsen.it.uu.se>
	<20090315100953.GA16632@electric-eye.fr.zoreil.com>
	<4A3B3C75.5090200@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Mikael Pettersson <mikpe@it.uu.se>,
	Tim Durack <tdurack@gmail.com>, netdev@vger.kernel.org
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aun.it.uu.se ([130.238.12.36]:52869 "EHLO aun.it.uu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751231AbZFSLaz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jun 2009 07:30:55 -0400
In-Reply-To: <4A3B3C75.5090200@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ivan Vecera writes:
 > Francois Romieu napsal(a):
 > > Mikael Pettersson <mikpe@it.uu.se> :
 > > [...]
 > >> May I suggest that 6709fe9a27e43a4931938fe0d7f2cc5edef31386 is reverted
 > >> until this regression is debugged and fixed?
 > > 
 > > Yes.
 > > 
 > Hello guys,
 > I made 3rd attempt to enable the ability to initialize r8169's MAC address
 > on initialization. The proposed patch below works for all my Realtek devices,
 > but you had some issues with the previous one. Could you please test it on your
 > devices? I would like to close finally this long term issue.

Sorry, this one breaks my Thecus n2100 NAS box just like before.
Here's a dmesg diff from 2.6.30 vanilla and 2.6.30 + this patch:

@@ -158,11 +158,13 @@
 r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
 r8169 0000:00:01.0: enabling Mem-Wr-Inval
 r8169 0000:00:01.0: no PCI Express capability
-eth0: RTL8169sb/8110sb at 0xe0810200, 00:14:fd:30:11:78, XID 10000000 IRQ 27
+r8169 0000:00:01.0: MAC address found in EEPROM: 00:14:fd:10:00:00
+eth0: RTL8169sb/8110sb at 0xe0810200, 00:00:00:00:00:00, XID 10000000 IRQ 27
 r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
 r8169 0000:00:02.0: enabling Mem-Wr-Inval
 r8169 0000:00:02.0: no PCI Express capability
-eth1: RTL8169sb/8110sb at 0xe0814300, 00:14:fd:30:11:79, XID 10000000 IRQ 30
+r8169 0000:00:02.0: MAC address found in EEPROM: 00:14:fd:10:00:00
+eth1: RTL8169sb/8110sb at 0xe0814300, 00:00:00:00:00:00, XID 10000000 IRQ 30
 physmap platform flash device: 01000000 at f0000000
 physmap-flash.0: Found 1 x16 devices at 0x0 in 16-bit bank
  Intel/Sharp Extended Query Table at 0x0031
@@ -250,6 +246,4 @@
 EXT3 FS on sda5, internal journal
 EXT3-fs: mounted filesystem with ordered data mode.
 Adding 2008116k swap on /dev/sda3.  Priority:-1 extents:1 across:2008116k 
-r8169: eth0: link up
-r8169: eth0: link up
 warning: `dbus-daemon' uses 32-bit capabilities (legacy support in use)

/Mikael
