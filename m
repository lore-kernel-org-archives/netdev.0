From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net-next 6/8] bnx2x: Add known PHY type check
Date: Sun, 27 Nov 2011 20:17:59 +0200
Message-ID: <1322417881-17760-7-git-send-email-yanivr@broadcom.com>
References: <1322417881-17760-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1444 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755807Ab1K0QTG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Nov 2011 11:19:06 -0500
In-Reply-To: <1322417881-17760-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The populate function will fail in case an unknown external PHY is detected.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index c734fff..e291c50 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -11489,6 +11489,10 @@ static int bnx2x_populate_ext_phy(struct bnx2x *bp,
 		return -EINVAL;
 	default:
 		*phy = phy_null;
+		/* In case external PHY wasn't found */
+		if ((phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) &&
+			(phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN))
+			return -EINVAL;
 		return 0;
 	}
 
-- 
1.7.7.1
