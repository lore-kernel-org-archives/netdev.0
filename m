From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 2/9] qlcnic: Fix typo in logs
Date: Sat, 13 Apr 2013 13:28:27 -0400
Message-ID: <1365874114-6759-3-git-send-email-shahed.shaikh@qlogic.com>
References: <1365874114-6759-1-git-send-email-shahed.shaikh@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:7605 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752071Ab3DMRwZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Apr 2013 13:52:25 -0400
In-Reply-To: <1365874114-6759-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

o Debug logs were not matching with code functionality.
o Changed dev_info to netdev_err

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 374fa8a..c9c342e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -2892,7 +2892,7 @@ void qlcnic_83xx_get_stats(struct qlcnic_adapter *adapter, u64 *data)
 	data = qlcnic_83xx_fill_stats(adapter, &cmd, data,
 				      QLC_83XX_STAT_TX, &ret);
 	if (ret) {
-		dev_info(&adapter->pdev->dev, "Error getting MAC stats\n");
+		netdev_err(adapter->netdev, "Error getting Tx stats\n");
 		goto out;
 	}
 	/* Get MAC stats */
@@ -2902,8 +2902,7 @@ void qlcnic_83xx_get_stats(struct qlcnic_adapter *adapter, u64 *data)
 	data = qlcnic_83xx_fill_stats(adapter, &cmd, data,
 				      QLC_83XX_STAT_MAC, &ret);
 	if (ret) {
-		dev_info(&adapter->pdev->dev,
-			 "Error getting Rx stats\n");
+		netdev_err(adapter->netdev, "Error getting MAC stats\n");
 		goto out;
 	}
 	/* Get Rx stats */
@@ -2913,8 +2912,7 @@ void qlcnic_83xx_get_stats(struct qlcnic_adapter *adapter, u64 *data)
 	data = qlcnic_83xx_fill_stats(adapter, &cmd, data,
 				      QLC_83XX_STAT_RX, &ret);
 	if (ret)
-		dev_info(&adapter->pdev->dev,
-			 "Error getting Tx stats\n");
+		netdev_err(adapter->netdev, "Error getting Rx stats\n");
 out:
 	qlcnic_free_mbx_args(&cmd);
 }
-- 
1.5.6
