From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH] net: stmmac: fix cbs configuration
Date: Fri, 31 Mar 2017 14:22:02 +0100
Message-ID: <fba7548363a0a3300bdc28679da8bd7bae91b24e.1490959712.git.jpinto__11092.1167456128$1490966654$gmane$org@synopsys.com>
Cc: niklas.cassel@axis.com, netdev@vger.kernel.org,
        Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.60.111]:49021 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933297AbdCaNWI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 09:22:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sending again, because forgot to include net-dev.

The QoS IP does not accept AVB capabilities to default/queue 0, this way we
guarantee 75% bandwidth for AVB. This patch assures that only queues >= 1
gets CBS confgured. Additional info was also added to stmmac.txt.

Reported-by: Niklas Cassel <niklas.cassel@axis.com>
Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
 Documentation/devicetree/bindings/net/stmmac.txt  | 2 ++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 3 ++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index 784d988..f652b0c 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -103,6 +103,8 @@ Optional properties:
 		- Choose one of these modes:
 			- snps,dcb-algorithm: TX queue will be working in DCB
 			- snps,avb-algorithm: TX queue will be working in AVB
+			  [Attention] Queue 0 is reserved for legacy traffic
+			  and so no AVB is available in this queue.
 		- Configure Credit Base Shaper (if AVB Mode selected):
 			- snps,send_slope: enable Low Power Interface
 			- snps,idle_slope: unlock on WoL
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 43361f3..c1c6319 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1880,7 +1880,8 @@ static void stmmac_configure_cbs(struct stmmac_priv *priv)
 	u32 mode_to_use;
 	u32 queue;
 
-	for (queue = 0; queue < tx_queues_count; queue++) {
+	/* queue 0 is reserved for legacy traffic */
+	for (queue = 1; queue < tx_queues_count; queue++) {
 		mode_to_use = priv->plat->tx_queues_cfg[queue].mode_to_use;
 		if (mode_to_use == MTL_QUEUE_DCB)
 			continue;
-- 
2.9.3
