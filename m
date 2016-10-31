From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH/RFC] ravb: Support 1Gbps on R-Car H3 ES1.1+ and R-Car M3-W
Date: Mon, 31 Oct 2016 18:13:38 +0100
Message-ID: <1477934018-13968-1-git-send-email-geert+renesas@glider.be>
Cc: Simon Horman <horms+renesas@verge.net.au>,
        Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S. Miller" <davem@davemloft.net>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The limitation to 10/100Mbit speeds on R-Car Gen3 is valid for R-Car H3
ES1.0 only. Check for the exact SoC model to allow 1Gbps on newer
revisions of R-Car H3, and on R-Car M3-W.

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
Tested on:
  - r8a7795/salvator-x with R-Car H3 ES1.0 (limited to 100Mbps),
  - r8a7795/salvator-x with R-Car H3 ES1.1 (1Gbps),
  - r8a7796/salvator-x with R-Car M3-W ES1.0 (1Gbps).

This is marked as an RFC because it depends on:
  A) the soc_device_match() infrastructure,
  B) Renesas SoC core ESx.y handling.
Hence I think the best merge strategy is to let this patch go in through
Simon's Renesas tree.

David: If you agree, can you please provide your ack? Thanks!
---
 drivers/net/ethernet/renesas/ravb_main.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index 27cfec3154c8e0f2..bf3109a413ac5721 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -31,6 +31,7 @@
 #include <linux/pm_runtime.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
+#include <linux/sys_soc.h>
 
 #include <asm/div64.h>
 
@@ -977,6 +978,11 @@ static void ravb_adjust_link(struct net_device *ndev)
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
@@ -1011,10 +1017,10 @@ static int ravb_phy_init(struct net_device *ndev)
 		return -ENOENT;
 	}
 
-	/* This driver only support 10/100Mbit speeds on Gen3
+	/* This driver only support 10/100Mbit speeds on R-Car H3 ES1.0
 	 * at this time.
 	 */
-	if (priv->chip_id == RCAR_GEN3) {
+	if (soc_device_match(r8a7795es10)) {
 		int err;
 
 		err = phy_set_max_speed(phydev, SPEED_100);
-- 
1.9.1
