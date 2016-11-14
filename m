From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH 2/2] amd-xgbe: Fix up some coccinelle identified warnings
Date: Mon, 14 Nov 2016 16:28:58 -0600
Message-ID: <20161114222858.25160.47383.stgit@tlendack-t1.amdoffice.net>
References: <20161114222827.25160.24791.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <julia.lawall@lip6.fr>, <christophe.jaillet@wanadoo.fr>,
        David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0075.outbound.protection.outlook.com ([104.47.34.75]:6270
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S965030AbcKNW3F (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 17:29:05 -0500
In-Reply-To: <20161114222827.25160.24791.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix up some warnings that were identified by coccinelle:

Clean up an if/else block that can look confusing since the same statement
is executed in an "else if" check and the final "else" statement.

Change a variable from unsigned int to int since it is used in an if
statement checking the value to be less than 0.

Reported-by: Julia Lawall <julia.lawall@lip6.fr>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c b/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
index 4ba4332..348cc8c 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
@@ -1766,8 +1766,6 @@ static void xgbe_phy_sfi_mode(struct xgbe_prv_data *pdata)
 			XP_SET_BITS(s0, XP_DRIVER_SCRATCH_0, SUB_COMMAND, 1);
 		else if (phy_data->sfp_cable_len <= 3)
 			XP_SET_BITS(s0, XP_DRIVER_SCRATCH_0, SUB_COMMAND, 2);
-		else if (phy_data->sfp_cable_len <= 5)
-			XP_SET_BITS(s0, XP_DRIVER_SCRATCH_0, SUB_COMMAND, 3);
 		else
 			XP_SET_BITS(s0, XP_DRIVER_SCRATCH_0, SUB_COMMAND, 3);
 	}
@@ -2346,7 +2344,8 @@ static bool xgbe_phy_valid_speed(struct xgbe_prv_data *pdata, int speed)
 static int xgbe_phy_link_status(struct xgbe_prv_data *pdata, int *an_restart)
 {
 	struct xgbe_phy_data *phy_data = pdata->phy_data;
-	unsigned int ret, reg;
+	unsigned int reg;
+	int ret;
 
 	*an_restart = 0;
 
