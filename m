From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net PATCH v2 5/7] bnx2x: correct advertisement of pause
 capabilities
Date: Tue, 11 Sep 2012 17:34:12 +0300
Message-ID: <1347374054-16730-6-git-send-email-yuvalmin@broadcom.com>
References: <1347374054-16730-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yaniv Rosner" <yaniv.rosner@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3253 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759287Ab2IKO6m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2012 10:58:42 -0400
In-Reply-To: <1347374054-16730-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <yaniv.rosner@broadcom.com>

This patch propagates users' requested flow-control into the link layer,
which will later be used to advertise this flow-control for auto-negotiation
(until now these values were ignored).

Signed-off-by: Yaniv Rosner <yaniv.rosner@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index c37a68d..bbf4cf0 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1587,6 +1587,12 @@ static int bnx2x_set_pauseparam(struct net_device *dev,
 			bp->link_params.req_flow_ctrl[cfg_idx] =
 				BNX2X_FLOW_CTRL_AUTO;
 		}
+		bp->link_params.req_fc_auto_adv = BNX2X_FLOW_CTRL_NONE;
+		if (epause->rx_pause)
+			bp->link_params.req_fc_auto_adv |= BNX2X_FLOW_CTRL_RX;
+
+		if (epause->tx_pause)
+			bp->link_params.req_fc_auto_adv |= BNX2X_FLOW_CTRL_TX;
 	}
 
 	DP(BNX2X_MSG_ETHTOOL,
-- 
1.7.9.rc2
