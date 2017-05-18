From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH 2/2] sh_eth: Do not print an error message for probe deferral
Date: Thu, 18 May 2017 15:01:35 +0200
Message-ID: <1495112495-25086-2-git-send-email-geert+renesas@glider.be>
References: <1495112495-25086-1-git-send-email-geert+renesas@glider.be>
Cc: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1495112495-25086-1-git-send-email-geert+renesas@glider.be>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

EPROBE_DEFER is not an error, hence printing an error message like

    sh-eth ee700000.ethernet: failed to initialise MDIO

may confuse the user.

To fix this, suppress the error message in case of probe deferral.
While at it, shorten the message, and add the actual error code.

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
 drivers/net/ethernet/renesas/sh_eth.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index c85222b02754f5a7..2d686ccf971b1b65 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -3220,7 +3220,8 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	/* MDIO bus init */
 	ret = sh_mdio_init(mdp, pd);
 	if (ret) {
-		dev_err(&pdev->dev, "failed to initialise MDIO\n");
+		if (ret != -EPROBE_DEFER)
+			dev_err(&pdev->dev, "MDIO init failed: %d\n", ret);
 		goto out_release;
 	}
 
-- 
2.7.4
