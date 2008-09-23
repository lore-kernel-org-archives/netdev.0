From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: [PATCH]: can: Add documentation for virtual CAN driver usage
Date: Tue, 23 Sep 2008 19:28:42 +0200
Message-ID: <48D9274A.407@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020809060703090006060500"
Cc: Urs Thuermann <urs@isnogud.escape.de>
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:52598 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751388AbYIWR3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 13:29:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020809060703090006060500
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

From: Oliver Hartkopp <oliver@hartkopp.net>

This patch adds a usage documentation for the virtual CAN driver (vcan).

Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
---

Hello Dave,

the virtual CAN netdevices are created via the netlink interface since 
Kerenel 2.6.24.
This patch adds some examples how to create and remove vcans via the 
ip(8) tool.
Please consider for net-next-2.6

Thanks,
Oliver



--------------020809060703090006060500
Content-Type: text/x-patch;
 name="vcan-documentation.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vcan-documentation.patch"

diff --git a/Documentation/networking/can.txt b/Documentation/networking/can.txt
index 297ba7b..2035bc4 100644
--- a/Documentation/networking/can.txt
+++ b/Documentation/networking/can.txt
@@ -35,8 +35,9 @@ This file contains
     6.1 general settings
     6.2 local loopback of sent frames
     6.3 CAN controller hardware filters
-    6.4 currently supported CAN hardware
-    6.5 todo
+    6.4 The virtual CAN driver (vcan)
+    6.5 currently supported CAN hardware
+    6.6 todo
 
   7 Credits
 
@@ -584,7 +585,42 @@ solution for a couple of reasons:
   @133MHz with four SJA1000 CAN controllers from 2002 under heavy bus
   load without any problems ...
 
-  6.4 currently supported CAN hardware (September 2007)
+  6.4 The virtual CAN driver (vcan)
+
+  Similar to the network loopback devices, vcan offers a virtual local
+  CAN interface. A full qualified address on CAN consists of
+
+  - a unique CAN Identifier (CAN ID)
+  - the CAN bus this CAN ID is transmitted on (e.g. can0)
+
+  so in common use cases more than one virtual CAN interface is needed.
+
+  The virtual CAN interfaces allow the transmission and reception of CAN
+  frames without real CAN controller hardware. Virtual CAN network
+  devices are usually named 'vcanX', like vcan0 vcan1 vcan2 ...
+  When compiled as a module the virtual CAN driver module is called vcan.ko
+
+  Since Linux Kernel version 2.6.24 the vcan driver supports the Kernel
+  netlink interface to create vcan network devices. The creation and
+  removal of vcan network devices can be managed with the ip(8) tool:
+
+  - Create a virtual CAN network interface:
+       ip link add type vcan
+
+  - Create a virtual CAN network interface with a specific name 'vcan42':
+       ip link add dev vcan42 type vcan
+
+  - Remove a (virtual CAN) network interface 'vcan42':
+       ip link del vcan42
+
+  The tool 'vcan' from the SocketCAN SVN repository on BerliOS is obsolete.
+
+  Virtual CAN network device creation in older Kernels:
+  In Linux Kernel versions < 2.6.24 the vcan driver creates 4 vcan
+  netdevices at module load time by default. This value can be changed
+  with the module parameter 'numdev'. E.g. 'modprobe vcan numdev=8'
+
+  6.5 currently supported CAN hardware
 
   On the project website http://developer.berlios.de/projects/socketcan
   there are different drivers available:
@@ -603,7 +639,7 @@ solution for a couple of reasons:
 
   Please check the Mailing Lists on the berlios OSS project website.
 
-  6.5 todo (September 2007)
+  6.6 todo
 
   The configuration interface for CAN network drivers is still an open
   issue that has not been finalized in the socketcan project. Also the

--------------020809060703090006060500--
