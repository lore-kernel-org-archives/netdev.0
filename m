From: Joe Perches <joe@perches.com>
Subject: [RFC net-next 1/2] drivers/net: Create an ANCIENT_NETDEVICES symbol
Date: Fri, 18 Mar 2016 17:33:30 -0700
Message-ID: <3403c9026d3c71310a32a97ac3351540e9ff8378.1458347329.git.joe@perches.com>
References: <1458340518.26915.30.camel@perches.com>
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458340518.26915.30.camel@perches.com>
In-Reply-To: <cover.1458347329.git.joe@perches.com>
References: <cover.1458347329.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Many drivers are ancient and written for hardware that is no longer
available.  These drivers are effectively untested under current
kernels.  Add a symbol that could guard inclusions of these drivers
into modern kernels unless specifically requested.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/Kconfig | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 2a1ba62b..0878363 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -21,6 +21,25 @@ menuconfig NETDEVICES
 
 	  If unsure, say Y.
 
+menuconfig ANCIENT_NETDEVICES
+	   default n
+	   depends on NET && NETDEVICES
+	   bool "Network ancient device support"
+	   ---help---
+	   Many old devices are no longer manufactured.
+
+	   The drivers for these devices likely worked with the original
+	   kernel version when the devices were manufactured, but do not
+	   necessarily function well today.
+
+	   If these devices still exist and are still functional, the drivers
+	   for these devices get scant testing.
+
+	   The drivers for these devices are unmaintained and not supported by
+	   the vendor.
+
+	   If you are unsure that you need drivers for old hardware, say N.
+
 # All the following symbols are dependent on NETDEVICES - do not repeat
 # that for each of the symbols.
 if NETDEVICES
-- 
2.6.3.368.gf34be46
