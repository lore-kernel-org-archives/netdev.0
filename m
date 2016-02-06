From: Corcodel Marian <asd@marian1000.go.ro>
Subject: [PATCH net v4] r8169:  Add bios support.
Date: Sat,  6 Feb 2016 08:31:26 +0200
Message-ID: <1454740286-4738-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: Corcodel Marian <asd@marian1000.go.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-227-244.residential.rdsnet.ro ([5.14.227.244]:35013 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750754AbcBFGzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 01:55:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This patch help do not compile functions relative to setting latency,
  setting bus master wich have provided on bios.Davem says "The chip
  can be used on systems without a BIOS and that should still
  work."

Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
---
 drivers/Kconfig                      | 4 ++++
 drivers/net/ethernet/realtek/r8169.c | 3 ++-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/Kconfig b/drivers/Kconfig
index d2ac339..46bdd2b 100644
--- a/drivers/Kconfig
+++ b/drivers/Kconfig
@@ -1,5 +1,9 @@
 menu "Device Drivers"
 
+config BIOS_SUPPORT
+	bool "bios support for systems wich have one"
+	def_bool y
+
 source "drivers/amba/Kconfig"
 
 source "drivers/base/Kconfig"
diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 6a2b7bb..2e83059 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -8262,8 +8262,9 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	rtl_hw_reset(tp);
 
 	rtl_ack_events(tp, 0xffff);
-
+#ifndef CONFIG_BIOS_SUPPORT
 	pci_set_master(pdev);
+#endif
 
 	rtl_init_mdio_ops(tp);
 	rtl_init_pll_power_ops(tp);
-- 
2.5.0
