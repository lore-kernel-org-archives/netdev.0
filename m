From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 3/8] amd-xgbe: Add ethtool support for setting
 the msglevel
Date: Wed, 30 Sep 2015 08:52:51 -0500
Message-ID: <20150930135251.12605.53602.stgit@tlendack-t1.amdoffice.net>
References: <20150930135232.12605.15604.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0091.outbound.protection.outlook.com ([157.56.110.91]:59776
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753984AbbI3OIJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 10:08:09 -0400
In-Reply-To: <20150930135232.12605.15604.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Provide the ethtool functions to support getting and setting the
msglevel for the driver.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
index 59e090e..29db64b 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
@@ -388,6 +388,20 @@ static void xgbe_get_drvinfo(struct net_device *netdev,
 	drvinfo->n_stats = XGBE_STATS_COUNT;
 }
 
+static u32 xgbe_get_msglevel(struct net_device *netdev)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+
+	return pdata->msg_enable;
+}
+
+static void xgbe_set_msglevel(struct net_device *netdev, u32 msglevel)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+
+	pdata->msg_enable = msglevel;
+}
+
 static int xgbe_get_coalesce(struct net_device *netdev,
 			     struct ethtool_coalesce *ec)
 {
@@ -594,6 +608,8 @@ static const struct ethtool_ops xgbe_ethtool_ops = {
 	.get_settings = xgbe_get_settings,
 	.set_settings = xgbe_set_settings,
 	.get_drvinfo = xgbe_get_drvinfo,
+	.get_msglevel = xgbe_get_msglevel,
+	.set_msglevel = xgbe_set_msglevel,
 	.get_link = ethtool_op_get_link,
 	.get_coalesce = xgbe_get_coalesce,
 	.set_coalesce = xgbe_set_coalesce,
