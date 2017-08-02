From: Jonas Gorski <jonas.gorski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 6/8] bcm63xx_enet: just use "enet" as the clock name
Date: Wed,  2 Aug 2017 11:34:27 +0200
Message-ID: <20170802093429.12572-7-jonas.gorski@gmail.com>
References: <20170802093429.12572-1-jonas.gorski@gmail.com>
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Ralf Baechle <ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
        Kevin Cernekee <cernekee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Jiri Slaby <jslaby-IBi9RG/b67k@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
To: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170802093429.12572-1-jonas.gorski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Now that we have the individual clocks available as "enet" we
don't need to rely on the device id for them anymore.

Signed-off-by: Jonas Gorski <jonas.gorski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 61a88b64bd39..d6844923a1c0 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -1718,7 +1718,6 @@ static int bcm_enet_probe(struct platform_device *pdev)
 	struct bcm63xx_enet_platform_data *pd;
 	struct resource *res_mem, *res_irq, *res_irq_rx, *res_irq_tx;
 	struct mii_bus *bus;
-	const char *clk_name;
 	int i, ret;
 
 	/* stop if shared driver failed, assume driver->probe will be
@@ -1761,14 +1760,12 @@ static int bcm_enet_probe(struct platform_device *pdev)
 	if (priv->mac_id == 0) {
 		priv->rx_chan = 0;
 		priv->tx_chan = 1;
-		clk_name = "enet0";
 	} else {
 		priv->rx_chan = 2;
 		priv->tx_chan = 3;
-		clk_name = "enet1";
 	}
 
-	priv->mac_clk = clk_get(&pdev->dev, clk_name);
+	priv->mac_clk = clk_get(&pdev->dev, "enet");
 	if (IS_ERR(priv->mac_clk)) {
 		ret = PTR_ERR(priv->mac_clk);
 		goto out;
-- 
2.13.2

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
