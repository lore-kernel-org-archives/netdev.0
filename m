From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH 2/2] net: fs_enet: Simplify code
Date: Fri, 10 Feb 2017 21:17:19 +0100
Message-ID: <20170210201719.16636-1-christophe.jaillet@wanadoo.fr>
Cc: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: pantelis.antoniou@gmail.com, vbordug@ru.mvista.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no need to use an intermediate variable to handle an error code
in this case.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
I think that the remaining use of 'err' a few lines above could also be
dropped. However, it could change the return value (i.e. propagation of the
error returned by 'of_phy_register_fixed_link' instead of -ENODEV) and I'm
unsure it would be correct. So I leave it as-is.
---
 drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index 5c6426756d11..753259091b22 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -964,11 +964,10 @@ static int fs_enet_probe(struct platform_device *ofdev)
 	 */
 	clk = devm_clk_get(&ofdev->dev, "per");
 	if (!IS_ERR(clk)) {
-		err = clk_prepare_enable(clk);
-		if (err) {
-			ret = err;
+		ret = clk_prepare_enable(clk);
+		if (ret)
 			goto out_deregister_fixed_link;
-		}
+
 		fpi->clk_per = clk;
 	}
 
-- 
2.9.3
