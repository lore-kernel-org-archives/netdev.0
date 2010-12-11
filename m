From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 02/27] Documentation/networking/e1000e.txt: Update documentation
Date: Fri, 10 Dec 2010 22:16:56 -0800
Message-ID: <1292048241-22026-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1292048241-22026-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:39925 "EHLO
	qmta05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751176Ab0LKGRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Dec 2010 01:17:42 -0500
To: davem@davemloft.net
In-Reply-To: <1292048241-22026-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update Intel Wired LAN e1000e documentation.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 Documentation/networking/e1000e.txt |   40 +++++++++++++++++++---------------
 1 files changed, 22 insertions(+), 18 deletions(-)

diff --git a/Documentation/networking/e1000e.txt b/Documentation/networking/e1000e.txt
index 6aa048b..81a66e6 100644
--- a/Documentation/networking/e1000e.txt
+++ b/Documentation/networking/e1000e.txt
@@ -1,5 +1,5 @@
 Linux* Driver for Intel(R) Network Connection
-===============================================================
+=============================================
 
 Intel Gigabit Linux driver.
 Copyright(c) 1999 - 2010 Intel Corporation.
@@ -61,6 +61,12 @@ per second, even if more packets have come in. This reduces interrupt
 load on the system and can lower CPU utilization under heavy load,
 but will increase latency as packets are not processed as quickly.
 
+The default behaviour of the driver previously assumed a static
+InterruptThrottleRate value of 8000, providing a good fallback value for
+all traffic types, but lacking in small packet performance and latency.
+The hardware can handle many more small packets per second however, and
+for this reason an adaptive interrupt moderation algorithm was implemented.
+
 The driver has two adaptive modes (setting 1 or 3) in which
 it dynamically adjusts the InterruptThrottleRate value based on the traffic
 that it receives. After determining the type of incoming traffic in the last
@@ -86,8 +92,8 @@ InterruptThrottleRate is set to mode 1. In this mode, which operates
 the same as mode 3, the InterruptThrottleRate will be increased stepwise to
 70000 for traffic in class "Lowest latency".
 
-In simplified mode the interrupt rate is based on the ratio of Tx and
-Rx traffic.  If the bytes per second rate is approximately equal the
+In simplified mode the interrupt rate is based on the ratio of TX and
+RX traffic.  If the bytes per second rate is approximately equal, the
 interrupt rate will drop as low as 2000 interrupts per second.  If the
 traffic is mostly transmit or mostly receive, the interrupt rate could
 be as high as 8000.
@@ -177,7 +183,7 @@ Copybreak
 Valid Range:   0-xxxxxxx (0=off)
 Default Value: 256
 
-Driver copies all packets below or equaling this size to a fresh Rx
+Driver copies all packets below or equaling this size to a fresh RX
 buffer before handing it up the stack.
 
 This parameter is different than other parameters, in that it is a
@@ -223,17 +229,17 @@ loading or enabling the driver, try disabling this feature.
 
 WriteProtectNVM
 ---------------
-Valid Range: 0-1
-Default Value: 1 (enabled)
-
-Set the hardware to ignore all write/erase cycles to the GbE region in the
-ICHx NVM (non-volatile memory).  This feature can be disabled by the
-WriteProtectNVM module parameter (enabled by default) only after a hardware
-reset, but the machine must be power cycled before trying to enable writes.
-
-Note: the kernel boot option iomem=relaxed may need to be set if the kernel
-config option CONFIG_STRICT_DEVMEM=y, if the root user wants to write the
-NVM from user space via ethtool.
+Valid Range: 0,1
+Default Value: 1
+
+If set to 1, configure the hardware to ignore all write/erase cycles to the
+GbE region in the ICHx NVM (in order to prevent accidental corruption of the
+NVM). This feature can be disabled by setting the parameter to 0 during initial
+driver load.
+NOTE: The machine must be power cycled (full off/on) when enabling NVM writes
+via setting the parameter to zero. Once the NVM has been locked (via the
+parameter at 1 when the driver loads) it cannot be unlocked except via power
+cycle.
 
 Additional Configurations
 =========================
@@ -259,7 +265,6 @@ Additional Configurations
   - Some adapters limit Jumbo Frames sized packets to a maximum of
     4096 bytes and some adapters do not support Jumbo Frames.
 
-
   Ethtool
   -------
   The driver utilizes the ethtool interface for driver configuration and
@@ -283,8 +288,7 @@ Additional Configurations
   loaded when shutting down or rebooting the system.
 
   In most cases Wake On LAN is only supported on port A for multiple port
-  adapters. To verify if a port supports Wake on LAN run ethtool eth<X>.
-
+  adapters. To verify if a port supports Wake on Lan run Ethtool eth<X>.
 
 Support
 =======
-- 
1.7.3.2

