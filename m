From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] ethernet: sfc: Add Kconfig entry for vendor Solarflare
Date: Tue, 20 Dec 2016 14:38:26 +0100
Message-ID: <20161220133826.1478-1-tklauser@distanz.ch>
Cc: linux-net-drivers@solarflare.com, ecree@solarflare.com,
        bkenward@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:46632 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932415AbcLTNih (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Dec 2016 08:38:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit

  5a6681e22c14 ("sfc: separate out SFC4000 ("Falcon") support into new sfc-falcon driver")

there are two drivers for Solarflare devices, but both still show up
directly beneath "Ethernet driver support" in the Kconfig. Follow the
pattern of other vendors and group them beneath an own vendor Kconfig
entry for Solarflare.

Cc: Edward Cree <ecree@solarflare.com>
Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/Kconfig     |  1 -
 drivers/net/ethernet/sfc/Kconfig | 21 +++++++++++++++++++++
 2 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 6e16e441f85e..e4c28fed61d5 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -166,7 +166,6 @@ source "drivers/net/ethernet/seeq/Kconfig"
 source "drivers/net/ethernet/silan/Kconfig"
 source "drivers/net/ethernet/sis/Kconfig"
 source "drivers/net/ethernet/sfc/Kconfig"
-source "drivers/net/ethernet/sfc/falcon/Kconfig"
 source "drivers/net/ethernet/sgi/Kconfig"
 source "drivers/net/ethernet/smsc/Kconfig"
 source "drivers/net/ethernet/stmicro/Kconfig"
diff --git a/drivers/net/ethernet/sfc/Kconfig b/drivers/net/ethernet/sfc/Kconfig
index 46f7be85f5a3..2c032629c369 100644
--- a/drivers/net/ethernet/sfc/Kconfig
+++ b/drivers/net/ethernet/sfc/Kconfig
@@ -1,3 +1,20 @@
+#
+# Solarflare device configuration
+#
+
+config NET_VENDOR_SOLARFLARE
+	bool "Solarflare devices"
+	default y
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Solarflare devices. If you say Y, you will be asked
+	  for your specific card in the following questions.
+
+if NET_VENDOR_SOLARFLARE
+
 config SFC
 	tristate "Solarflare SFC9000/SFC9100-family support"
 	depends on PCI
@@ -44,3 +61,7 @@ config SFC_MCDI_LOGGING
 	  Driver-Interface) commands and responses, allowing debugging of
 	  driver/firmware interaction.  The tracing is actually enabled by
 	  a sysfs file 'mcdi_logging' under the PCI device.
+
+source "drivers/net/ethernet/sfc/falcon/Kconfig"
+
+endif # NET_VENDOR_SOLARFLARE
-- 
2.11.0
