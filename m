From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net-next v2 6/9] bnx2x: Add known PHY type check
Date: Mon, 28 Nov 2011 12:49:50 +0200
Message-ID: <1322477393-22904-7-git-send-email-yanivr@broadcom.com>
References: <1322477393-22904-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4111 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752950Ab1K1Iuw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 03:50:52 -0500
In-Reply-To: <1322477393-22904-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The populate function will fail in case an unknown external PHY is detected.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 4ffc75d..cc7dbbe 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -11489,6 +11489,10 @@ static int bnx2x_populate_ext_phy(struct bnx2x *bp,
 		return -EINVAL;
 	default:
 		*phy = phy_null;
+		/* In case external PHY wasn't found */
+		if ((phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) &&
+		    (phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN))
+			return -EINVAL;
 		return 0;
 	}
 
-- 
1.7.7.1
