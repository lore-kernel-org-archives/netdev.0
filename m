From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 15/15] be2net: restrict WOL to PFs only.
Date: Fri, 11 Feb 2011 17:39:30 -0600
Message-ID: <20110211233930.GA18526@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:51265 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758107Ab1BKXju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 18:39:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WOL is not supported for Vrtual Functions.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_ethtool.c |   15 +++++++++++++--
 1 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 0c99314..07b4ab9 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -516,12 +516,23 @@ be_phys_id(struct net_device *netdev, u32 data)
 	return status;
 }
 
+static bool
+be_is_wol_supported(struct be_adapter *adapter)
+{
+	if (!be_physfn(adapter))
+		return false;
+	else
+		return true;
+}
+
 static void
 be_get_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 
-	wol->supported = WAKE_MAGIC;
+	if (be_is_wol_supported(adapter))
+		wol->supported = WAKE_MAGIC;
+
 	if (adapter->wol)
 		wol->wolopts = WAKE_MAGIC;
 	else
@@ -537,7 +548,7 @@ be_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 	if (wol->wolopts & ~WAKE_MAGIC)
 		return -EINVAL;
 
-	if (wol->wolopts & WAKE_MAGIC)
+	if ((wol->wolopts & WAKE_MAGIC) && be_is_wol_supported(adapter))
 		adapter->wol = true;
 	else
 		adapter->wol = false;
-- 
1.7.1

