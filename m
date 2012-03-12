From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next 7/8] bnx2x: ethtool returns req. AN even when AN
 fails
Date: Mon, 12 Mar 2012 14:53:13 -0400
Message-ID: <1331578394-1153-8-git-send-email-yuvalmin@broadcom.com>
References: <1331578394-1153-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1169 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754261Ab2CLL7h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2012 07:59:37 -0400
In-Reply-To: <1331578394-1153-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously, if autoneg failed, ethtool would return the achieved autoneg.
This patch corrects this, causing ethtool to return the requested autoneg
capabilities even if autoneg fails.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 8f8421d..858d1b5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1450,7 +1450,7 @@ static void bnx2x_get_pauseparam(struct net_device *dev,
 			   BNX2X_FLOW_CTRL_AUTO);
 
 	if (!epause->autoneg)
-		cfg_reg = bp->link_vars.flow_ctrl;
+		cfg_reg = bp->link_params.req_flow_ctrl[cfg_idx];
 	else
 		cfg_reg = bp->link_params.req_fc_auto_adv;
 
-- 
1.7.9.rc2
