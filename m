From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH net-next 2/2] ravb: Support 1Gbps on R-Car H3 ES1.1+ and R-Car M3-W
Date: Fri, 27 Jan 2017 12:04:50 +0100
Message-ID: <1485515090-7570-3-git-send-email-horms+renesas@verge.net.au>
References: <1485515090-7570-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        Simon Horman <horms+renesas@verge.net.au>
To: David Miller <davem@davemloft.net>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:60878 "EHLO
        kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933516AbdA0LFc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 06:05:32 -0500
In-Reply-To: <1485515090-7570-1-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geert Uytterhoeven <geert+renesas@glider.be>

The limitation to 10/100Mbit speeds on R-Car Gen3 is valid for R-Car H3
ES1.0 only. Check for the exact SoC model to allow 1Gbps on newer
revisions of R-Car H3, and on R-Car M3-W.

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
---
 drivers/net/ethernet/renesas/ravb_main.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index 9fb4c04c5885..93cdadeae354 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -31,6 +31,7 @@
 #include <linux/pm_runtime.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
+#include <linux/sys_soc.h>
 
 #include <asm/div64.h>
 
@@ -973,6 +974,11 @@ static void ravb_adjust_link(struct net_device *ndev)
 		phy_print_status(phydev);
 }
 
+static const struct soc_device_attribute r8a7795es10[] = {
+	{ .soc_id = "r8a7795", .revision = "ES1.0", },
+	{ /* sentinel */ }
+};
+
 /* PHY init function */
 static int ravb_phy_init(struct net_device *ndev)
 {
@@ -1008,10 +1014,10 @@ static int ravb_phy_init(struct net_device *ndev)
 		goto err_deregister_fixed_link;
 	}
 
-	/* This driver only support 10/100Mbit speeds on Gen3
+	/* This driver only support 10/100Mbit speeds on R-Car H3 ES1.0
 	 * at this time.
 	 */
-	if (priv->chip_id == RCAR_GEN3) {
+	if (soc_device_match(r8a7795es10)) {
 		err = phy_set_max_speed(phydev, SPEED_100);
 		if (err) {
 			netdev_err(ndev, "failed to limit PHY to 100Mbit/s\n");
-- 
2.7.0.rc3.207.g0ac5344
