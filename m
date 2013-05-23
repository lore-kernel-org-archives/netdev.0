From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH v2 net-next 4/4] bnx2x: Enable `set_phys_id' for all
 functions
Date: Thu, 23 May 2013 10:21:52 +0300
Message-ID: <1369293712-26541-5-git-send-email-yuvalmin@broadcom.com>
References: <1369293712-26541-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3635 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756485Ab3EWHWj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 May 2013 03:22:39 -0400
In-Reply-To: <1369293712-26541-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <yanivr@broadcom.com>

In Multi-function mode, all functions should be able to utilize said function;
There's no reason why only the link owner should be able to do so.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index da23aea..5bd6b24 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -3146,11 +3146,6 @@ static int bnx2x_set_phys_id(struct net_device *dev,
 		return -EAGAIN;
 	}
 
-	if (!bp->port.pmf) {
-		DP(BNX2X_MSG_ETHTOOL, "Interface is not pmf\n");
-		return -EOPNOTSUPP;
-	}
-
 	switch (state) {
 	case ETHTOOL_ID_ACTIVE:
 		return 1;	/* cycle on/off once per second */
-- 
1.8.1.227.g44fe835
