From: Corcodel Marian <asd@marian1000.go.ro>
Subject: [PATCH net v4] r8169:   Disabling multiple invocation on rtl_try_msi function.
Date: Thu,  4 Feb 2016 11:35:38 +0200
Message-ID: <1454578538-2544-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: Corcodel Marian <asd@marian1000.go.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-225-121.residential.rdsnet.ro ([5.14.225.121]:34805 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752572AbcBDJgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 04:36:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set MSI on probe stage without this patch MSI is set when rtl_open occur.
 Do not need to run rtl_try_msi on multiple times.

Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
---
 drivers/net/ethernet/realtek/r8169.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 30eed0d..b0b43b7 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -8248,6 +8248,9 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* Identify chip attached to board */
 	rtl8169_get_mac_version(tp, dev, cfg->default_ver);
+	RTL_W8(Cfg9346, Cfg9346_Unlock);
+	tp->features = rtl_try_msi(tp, cfg);
+	RTL_W8(Cfg9346, Cfg9346_Lock);
 
 	rtl_init_rxcfg(tp);
 
@@ -8303,7 +8306,6 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 	if ((RTL_R8(Config5) & (UWF | BWF | MWF)) != 0)
 		tp->features |= RTL_FEATURE_WOL;
-	tp->features |= rtl_try_msi(tp, cfg);
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
 	if (rtl_tbi_enabled(tp)) {
-- 
2.5.0
