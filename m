From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 3/5] [net-next] net: qcom/emac: do not call emac_mac_start twice
Date: Fri, 27 Jan 2017 16:43:45 -0600
Message-ID: <1485557028-32510-4-git-send-email-timur@codeaurora.org>
References: <1485557028-32510-1-git-send-email-timur@codeaurora.org>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:57232 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750849AbdA0Wzl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 17:55:41 -0500
In-Reply-To: <1485557028-32510-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

emac_mac_start() uses information from the external PHY to program
the MAC, so it makes no sense to call it before the link is up.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/emac/emac-mac.c | 2 +-
 drivers/net/ethernet/qualcomm/emac/emac-mac.h | 1 -
 drivers/net/ethernet/qualcomm/emac/emac.c     | 2 --
 3 files changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac-mac.c b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
index 155e273..3f3cd00 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-mac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
@@ -556,7 +556,7 @@ void emac_mac_reset(struct emac_adapter *adpt)
 	emac_reg_update32(adpt->base + EMAC_DMA_MAS_CTRL, 0, INT_RD_CLR_EN);
 }
 
-void emac_mac_start(struct emac_adapter *adpt)
+static void emac_mac_start(struct emac_adapter *adpt)
 {
 	struct phy_device *phydev = adpt->phydev;
 	u32 mac, csr1;
diff --git a/drivers/net/ethernet/qualcomm/emac/emac-mac.h b/drivers/net/ethernet/qualcomm/emac/emac-mac.h
index f3aa24d..5028fb4 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-mac.h
+++ b/drivers/net/ethernet/qualcomm/emac/emac-mac.h
@@ -230,7 +230,6 @@ struct emac_tx_queue {
 int  emac_mac_up(struct emac_adapter *adpt);
 void emac_mac_down(struct emac_adapter *adpt);
 void emac_mac_reset(struct emac_adapter *adpt);
-void emac_mac_start(struct emac_adapter *adpt);
 void emac_mac_stop(struct emac_adapter *adpt);
 void emac_mac_mode_config(struct emac_adapter *adpt);
 void emac_mac_rx_process(struct emac_adapter *adpt, struct emac_rx_queue *rx_q,
diff --git a/drivers/net/ethernet/qualcomm/emac/emac.c b/drivers/net/ethernet/qualcomm/emac/emac.c
index 3e1be91..75305ad 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac.c
@@ -280,8 +280,6 @@ static int emac_open(struct net_device *netdev)
 		return ret;
 	}
 
-	emac_mac_start(adpt);
-
 	return 0;
 }
 
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
