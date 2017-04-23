From: Karim Eshapa <karim.eshapa@gmail.com>
Subject: [PATCH 1/1] drivers:net:ethernet:adi:bfin_mac: Use FIELD_SIZEOF defined kernel macro
Date: Sun, 23 Apr 2017 20:02:04 +0200
Message-ID: <1492970524-12607-1-git-send-email-karim.eshapa@gmail.com>
Cc: tremyfr@gmail.com, a@unstable.cc, fw@strlen.de,
        clabbe.montjoie@gmail.com, edumazet@google.com, jarod@redhat.com,
        adi-buildroot-devel@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Karim Eshapa <karim.eshapa@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33979 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1163076AbdDWSCN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 14:02:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use FIELD_SIZEOF defined kernel macro kernel.h

Signed-off-by: Karim Eshapa <karim.eshapa@gmail.com>
---
 drivers/net/ethernet/adi/bfin_mac.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index a9ac58c..60346e0 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -452,10 +452,14 @@ static irqreturn_t bfin_mac_wake_interrupt(int irq, void *dev_id)
 static void bfin_mac_ethtool_getdrvinfo(struct net_device *dev,
 					struct ethtool_drvinfo *info)
 {
-	strlcpy(info->driver, KBUILD_MODNAME, sizeof(info->driver));
-	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
-	strlcpy(info->fw_version, "N/A", sizeof(info->fw_version));
-	strlcpy(info->bus_info, dev_name(&dev->dev), sizeof(info->bus_info));
+	strlcpy(info->driver, KBUILD_MODNAME, FIELD_SIZEOF(
+		struct ethtool_drvinfo, driver));
+	strlcpy(info->version, DRV_VERSION, FIELD_SIZEOF(
+		struct ethtool_drvinfo, version));
+	strlcpy(info->fw_version, "N/A", FIELD_SIZEOF(
+		struct ethtool_drvinfo, fw_version));
+	strlcpy(info->bus_info, dev_name(&dev->dev), FIELD_SIZEOF(
+		struct ethtool_drvinfo, bus_info));
 }
 
 static void bfin_mac_ethtool_getwol(struct net_device *dev,
@@ -785,7 +789,7 @@ static int bfin_mac_hwtstamp_get(struct net_device *netdev,
 	struct bfin_mac_local *lp = netdev_priv(netdev);
 
 	return copy_to_user(ifr->ifr_data, &lp->stamp_cfg,
-			    sizeof(lp->stamp_cfg)) ?
+			    FILD_SIZEOF(struct bfin_mac_local, stamp_cfg)) ?
 		-EFAULT : 0;
 }
 
-- 
2.7.4
