From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.6] e1000: Documentation/networking/e1000.txt update
Date: Thu, 6 Jan 2005 17:03:45 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061417450.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>

diff -Nuar -u net-drivers-2.6/Documentation/networking/e1000.txt net-drivers-2.6.new/Documentation/networking/e1000.txt
--- net-drivers-2.6/Documentation/networking/e1000.txt	2004-10-26 04:14:03.000000000 -0700
+++ net-drivers-2.6.new/Documentation/networking/e1000.txt	2005-01-06 11:01:12.000000000 -0800
@@ -1,7 +1,7 @@
 Linux* Base Driver for the Intel(R) PRO/1000 Family of Adapters
 ===============================================================
 
-September 13, 2004
+November 17, 2004
 
 
 Contents
@@ -20,8 +20,7 @@
 ===============
 
 This file describes the Linux* Base Driver for the Intel(R) PRO/1000 Family
-of Adapters, version 5.x.x.  This driver includes support for Itanium(TM)2 
-and EM64T systems.
+of Adapters, version 5.x.x.  
 
 For questions related to hardware requirements, refer to the documentation 
 supplied with your Intel PRO/1000 adapter. All hardware requirements listed 
@@ -145,9 +144,11 @@
 Default Value: 256
     This value is the number of receive descriptors allocated by the driver. 
     Increasing this value allows the driver to buffer more incoming packets. 
-    Each descriptor is 16 bytes.  A receive buffer is also allocated for each
-    descriptor and can be either 2048, 4096, 8192, or 16384 bytes, depending 
-    on the MTU setting. The maximum MTU size is 16110.
+    Each descriptor is 16 bytes.  A receive buffer is allocated for each
+    descriptor and can either be 2048 or 4096 bytes long, depending on the MTU 
+
+    setting. An incoming packet can span one or more receive descriptors. 
+    The maximum MTU size is 16110.
 
     NOTE: MTU designates the frame size. It only needs to be set for Jumbo 
           Frames.
@@ -251,17 +252,16 @@
   also be forced.
 
 The AutoNeg parameter is used when more control is required over the auto-
-negotiation process.  When this parameter is used, Speed and Duplex must not 
-be specified.  This parameter is a bitmap that specifies which speed and 
-duplex settings are advertised to the link partner.
-
-Bit            7      6      5       4       3      2      1       0
-Speed (Mbps)   N/A    N/A    1000    N/A     100    100    10      10
-Duplex                       Full            Full   Half   Full    Half
-
-For example to limit the negotiated speed/duplex on the interface to 10 Mbps 
-Half or Full duplex, set AutoNeg to 0x02: 
-    insmod e1000 AutoNeg=0x02
+negotiation process. When this parameter is used, Speed and Duplex parameters 
+must not be specified. The following table describes supported values for the 
+AutoNeg parameter:
+
+Speed (Mbps)   		 1000      100    100    10     10
+Duplex                   Full      Full   Half   Full   Half
+Value (in base 16)       0x20      0x08   0x04   0x02   0x01
+
+Example: insmod e1000 AutoNeg=0x03, loads e1000 and specifies (10 full duplex, 
+10 half duplex) for negotiation with the peer.
 
 Note that setting AutoNeg does not guarantee that the board will link at the 
 highest specified speed or duplex mode, but the board will link at the 
@@ -333,11 +333,7 @@
   version 1.6 or later is required for this functionality.
 
   The latest release of ethtool can be found from
-  http://sf.net/projects/gkernel.  After ethtool is installed,
-  ethtool-copy.h must be copied and renamed to ethtool.h in your kernel
-  source tree at <linux_kernel_src>/include/linux.  Backup the original
-  ethtool.h as needed before copying.  The driver then must be recompiled
-  in order to take advantage of the latest ethtool features.
+  http://sf.net/projects/gkernel.  
 
   NOTE: Ethtool 1.6 only supports a limited set of ethtool options. Support 
   for a more complete ethtool feature set can be enabled by upgrading 
