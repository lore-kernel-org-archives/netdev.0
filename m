From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net 10/10] bnx2x: Clear MDC/MDIO warning message
Date: Wed, 4 Apr 2012 14:40:02 +0300
Message-ID: <1333539602-10117-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4274 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755930Ab2DDJkI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 05:40:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch clears a warning message of "MDC/MDIO access timeout" which may
appear when interface is loaded due to missing clock setting before resetting
the LED, and starting periodic function too early.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |    1 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |    2 +-
 2 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 44556b7..4b05481 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1874,7 +1874,6 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		 * bnx2x_periodic_task().
 		 */
 		smp_mb();
-		queue_delayed_work(bnx2x_wq, &bp->period_task, 0);
 	} else
 		bp->port.pmf = 0;
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 7e41682..ad95324 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -12205,10 +12205,10 @@ int bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 	 * Hold it as vars low
 	 */
 	 /* clear link led */
+	bnx2x_set_mdio_clk(bp, params->chip_id, port);
 	bnx2x_set_led(params, vars, LED_MODE_OFF, 0);
 
 	if (reset_ext_phy) {
-		bnx2x_set_mdio_clk(bp, params->chip_id, port);
 		for (phy_index = EXT_PHY1; phy_index < params->num_phys;
 		      phy_index++) {
 			if (params->phy[phy_index].link_reset) {
-- 
1.7.7.1
