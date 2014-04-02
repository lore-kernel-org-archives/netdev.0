From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 1/1] sxgbe: use common NET_VENDOR_FOO style.
Date: Thu, 3 Apr 2014 01:13:03 +0200
Message-ID: <20140402231303.GB5013@electric-eye.fr.zoreil.com>
References: <19617.1396041625@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Siva Reddy Kallam <siva.kallam@samsung.com>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:44338 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933473AbaDBXNU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 19:13:20 -0400
Content-Disposition: inline
In-Reply-To: <19617.1396041625@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---

 Valdis, is it what you had in mind ?

 drivers/net/ethernet/samsung/Kconfig       | 24 ++++++++++++++++++++----
 drivers/net/ethernet/samsung/sxgbe/Kconfig |  9 ---------
 2 files changed, 20 insertions(+), 13 deletions(-)
 delete mode 100644 drivers/net/ethernet/samsung/sxgbe/Kconfig

diff --git a/drivers/net/ethernet/samsung/Kconfig b/drivers/net/ethernet/samsung/Kconfig
index 7902341..2360d81 100644
--- a/drivers/net/ethernet/samsung/Kconfig
+++ b/drivers/net/ethernet/samsung/Kconfig
@@ -3,14 +3,30 @@
 #
 
 config NET_VENDOR_SAMSUNG
-	bool "Samsung Ethernet device"
+	bool "Samsung Ethernet devices"
 	default y
 	---help---
-	  This is the driver for the SXGBE 10G Ethernet IP block found on Samsung
-	  platforms.
+	  If you have a network (Ethernet) chipset belonging to this class,
+	  say Y.
+
+	  Note that the answer to this question does not directly affect
+	  the kernel: saying N will just case the configurator to skip all
+	  the questions about Samsung chipsets. If you say Y, you will be asked
+	  for your specific chipset/driver in the following questions.
 
 if NET_VENDOR_SAMSUNG
 
-source "drivers/net/ethernet/samsung/sxgbe/Kconfig"
+config SXGBE_ETH
+	tristate "Samsung 10G/2.5G/1G SXGBE Ethernet driver"
+	depends on HAS_IOMEM && HAS_DMA
+	select PHYLIB
+	select CRC32
+	select PTP_1588_CLOCK
+	---help---
+	  This is the driver for the SXGBE 10G Ethernet IP block found on
+	  Samsung platforms.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called samsung-sxgbe.
 
 endif # NET_VENDOR_SAMSUNG
diff --git a/drivers/net/ethernet/samsung/sxgbe/Kconfig b/drivers/net/ethernet/samsung/sxgbe/Kconfig
deleted file mode 100644
index d79288c..0000000
--- a/drivers/net/ethernet/samsung/sxgbe/Kconfig
+++ /dev/null
@@ -1,9 +0,0 @@
-config SXGBE_ETH
-	tristate "Samsung 10G/2.5G/1G SXGBE Ethernet driver"
-	depends on HAS_IOMEM && HAS_DMA
-	select PHYLIB
-	select CRC32
-	select PTP_1588_CLOCK
-	---help---
-	  This is the driver for the SXGBE 10G Ethernet IP block found on Samsung
-	  platforms.
-- 
1.9.0
