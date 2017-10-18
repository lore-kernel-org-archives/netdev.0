From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH net-next v2 2/3] net: sh_eth: rename name structures as rcar_gen[12]_*
Date: Wed, 18 Oct 2017 09:21:27 +0200
Message-ID: <20171018072128.11857-3-horms+renesas@verge.net.au>
References: <20171018072128.11857-1-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org,
        Simon Horman <horms+renesas@verge.net.au>
To: David Miller <davem@davemloft.net>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:57622 "EHLO
        kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933887AbdJRHVt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 03:21:49 -0400
In-Reply-To: <20171018072128.11857-1-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename structures describing R-Car SoCs as rcar_gen[12]_*
rather than r8a77[79]x_*. This seems a little easier on the
eyes. And will make things slightly cleaner in a follow-up
patch that adds fallback-compatibility strings for these SoCs.

Note that R-Car Gen2 and RZ/G1 have many compatible IP blocks.  The
approach that has been consistently taken for other IP blocks is to name
common code, compatibility strings and so on after R-Car Gen2.

Also rename sh_eth_set_rate_r8a777x as sh_eth_set_rate_rcar as
it it is used by the R-Car generations supported by the driver.

This patch should have no run-time effect and
is compile-tested only.

Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
Reviewed-by: Geert Uytterhoeven <geert+renesas@glider.be>
Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
---
v2
* Updated changelog
* Collected review tags
---
 drivers/net/ethernet/renesas/sh_eth.c | 30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index d2e88a30f57b..c9f92fc8555e 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -594,7 +594,7 @@ static struct sh_eth_cpu_data r8a7740_data = {
 };
 
 /* There is CPU dependent code */
-static void sh_eth_set_rate_r8a777x(struct net_device *ndev)
+static void sh_eth_set_rate_rcar(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 
@@ -608,10 +608,10 @@ static void sh_eth_set_rate_r8a777x(struct net_device *ndev)
 	}
 }
 
-/* R8A7778/9 */
-static struct sh_eth_cpu_data r8a777x_data = {
+/* R-Car Gen1 */
+static struct sh_eth_cpu_data rcar_gen1_data = {
 	.set_duplex	= sh_eth_set_duplex,
-	.set_rate	= sh_eth_set_rate_r8a777x,
+	.set_rate	= sh_eth_set_rate_rcar,
 
 	.register_type	= SH_ETH_REG_FAST_RCAR,
 
@@ -635,10 +635,10 @@ static struct sh_eth_cpu_data r8a777x_data = {
 	.hw_swap	= 1,
 };
 
-/* R8A7790/1 */
-static struct sh_eth_cpu_data r8a779x_data = {
+/* R-Car Gen2 and RZ/G1 */
+static struct sh_eth_cpu_data rcar_gen2_data = {
 	.set_duplex	= sh_eth_set_duplex,
-	.set_rate	= sh_eth_set_rate_r8a777x,
+	.set_rate	= sh_eth_set_rate_rcar,
 
 	.register_type	= SH_ETH_REG_FAST_RCAR,
 
@@ -3086,14 +3086,14 @@ static struct sh_eth_plat_data *sh_eth_parse_dt(struct device *dev)
 
 static const struct of_device_id sh_eth_match_table[] = {
 	{ .compatible = "renesas,gether-r8a7740", .data = &r8a7740_data },
-	{ .compatible = "renesas,ether-r8a7743", .data = &r8a779x_data },
-	{ .compatible = "renesas,ether-r8a7745", .data = &r8a779x_data },
-	{ .compatible = "renesas,ether-r8a7778", .data = &r8a777x_data },
-	{ .compatible = "renesas,ether-r8a7779", .data = &r8a777x_data },
-	{ .compatible = "renesas,ether-r8a7790", .data = &r8a779x_data },
-	{ .compatible = "renesas,ether-r8a7791", .data = &r8a779x_data },
-	{ .compatible = "renesas,ether-r8a7793", .data = &r8a779x_data },
-	{ .compatible = "renesas,ether-r8a7794", .data = &r8a779x_data },
+	{ .compatible = "renesas,ether-r8a7743", .data = &rcar_gen2_data },
+	{ .compatible = "renesas,ether-r8a7745", .data = &rcar_gen2_data },
+	{ .compatible = "renesas,ether-r8a7778", .data = &rcar_gen1_data },
+	{ .compatible = "renesas,ether-r8a7779", .data = &rcar_gen1_data },
+	{ .compatible = "renesas,ether-r8a7790", .data = &rcar_gen2_data },
+	{ .compatible = "renesas,ether-r8a7791", .data = &rcar_gen2_data },
+	{ .compatible = "renesas,ether-r8a7793", .data = &rcar_gen2_data },
+	{ .compatible = "renesas,ether-r8a7794", .data = &rcar_gen2_data },
 	{ .compatible = "renesas,ether-r7s72100", .data = &r7s72100_data },
 	{ }
 };
-- 
2.11.0
