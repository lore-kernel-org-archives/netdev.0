From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 3/3] qlcnic: Fix typo in logs
Date: Thu, 18 Apr 2013 14:10:06 -0400
Message-ID: <1366308606-20435-4-git-send-email-shahed.shaikh@qlogic.com>
References: <1366308606-20435-1-git-send-email-shahed.shaikh@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:6506 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S932200Ab3DRSe1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 14:34:27 -0400
In-Reply-To: <1366308606-20435-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

o Debug logs were not matching with code functionality.
o Changed dev_info to netdev_err

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 284d628..edd63f1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -2786,6 +2786,7 @@ static u64 *qlcnic_83xx_fill_stats(struct qlcnic_adapter *adapter,
 void qlcnic_83xx_get_stats(struct qlcnic_adapter *adapter, u64 *data)
 {
 	struct qlcnic_cmd_args cmd;
+	struct net_device *netdev = adapter->netdev;
 	int ret = 0;
 
 	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_GET_STATISTICS);
@@ -2795,7 +2796,7 @@ void qlcnic_83xx_get_stats(struct qlcnic_adapter *adapter, u64 *data)
 	data = qlcnic_83xx_fill_stats(adapter, &cmd, data,
 				      QLC_83XX_STAT_TX, &ret);
 	if (ret) {
-		dev_info(&adapter->pdev->dev, "Error getting MAC stats\n");
+		netdev_err(netdev, "Error getting Tx stats\n");
 		goto out;
 	}
 	/* Get MAC stats */
@@ -2805,8 +2806,7 @@ void qlcnic_83xx_get_stats(struct qlcnic_adapter *adapter, u64 *data)
 	data = qlcnic_83xx_fill_stats(adapter, &cmd, data,
 				      QLC_83XX_STAT_MAC, &ret);
 	if (ret) {
-		dev_info(&adapter->pdev->dev,
-			 "Error getting Rx stats\n");
+		netdev_err(netdev, "Error getting MAC stats\n");
 		goto out;
 	}
 	/* Get Rx stats */
@@ -2816,8 +2816,7 @@ void qlcnic_83xx_get_stats(struct qlcnic_adapter *adapter, u64 *data)
 	data = qlcnic_83xx_fill_stats(adapter, &cmd, data,
 				      QLC_83XX_STAT_RX, &ret);
 	if (ret)
-		dev_info(&adapter->pdev->dev,
-			 "Error getting Tx stats\n");
+		netdev_err(netdev, "Error getting Rx stats\n");
 out:
 	qlcnic_free_mbx_args(&cmd);
 }
-- 
1.5.6
