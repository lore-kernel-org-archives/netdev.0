From: Mikael Pettersson <mikpe@it.uu.se>
Subject: [BUG] 2.6.30-rc broke ixp4xx_eth, firmware breakage?
Date: Sat, 18 Apr 2009 23:53:25 +0200 (MEST)
Message-ID: <200904182153.n3ILrP6j027453@pilspetsen.it.uu.se>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from aun.it.uu.se ([130.238.12.36]:36801 "EHLO aun.it.uu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752470AbZDRVxg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Apr 2009 17:53:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ixp4xx_eth driver for my IXP420 XScale box (Synology DS101)
worked fine in kernel 2.6.29. Now trying to boot 2.6.30-rc2 I'm
greeted with the following failure during init:

Bringing up interface eth0:  RTNETLINK answers: No such file or directory
Failed to bring up eth0.
[FAILED]

There's a fairly long (at least 10 seconds) delay between the 'Bringing up'
message and the RTNETLINK error.

A diff between the 2.6.29 and 2.6.30-rc2 boot logs indicates that
the firmware doesn't get loaded:

--- dmesg-2.6.29	2009-04-18 23:26:30.000000000 +0200
+++ dmesg-2.6.30-rc2	2009-04-18 23:24:03.000000000 +0200
@@ -221,11 +222,9 @@
 kjournald starting.  Commit interval 5 seconds
 EXT3 FS on sda8, internal journal
 EXT3-fs: mounted filesystem with ordered data mode.
-net eth0: firmware: requesting NPE-C
-NPE-C: firmware functionality 0x0, revision 0x2:1
-NET: Registered protocol family 17
-eth0: link up, speed 100 Mb/s, full duplex
 Adding 2000336k swap on /dev/sda5.  Priority:-1 extents:1 across:2000336k 
+NET: Registered protocol family 17
+net eth0: firmware: requesting NPE-C
 RPC: Registered udp transport module.
 RPC: Registered tcp transport module.
 warning: `dbus-daemon' uses 32-bit capabilities (legacy support in use)

I'll try to debug this tomorrow, but I may not have time for a proper
debug session until next weekend.

/Mikael
