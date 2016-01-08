From: Xing Zheng <zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Subject: [PATCH v2 1/3] net: ethernet: arc: Probe emac after set RMII clock
Date: Fri,  8 Jan 2016 09:35:00 +0800
Message-ID: <1452216902-21063-2-git-send-email-zhengxing@rock-chips.com>
References: <1452216902-21063-1-git-send-email-zhengxing@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org, Xing Zheng <zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, keescook-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
 leozwang-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
To: linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1452216902-21063-1-git-send-email-zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-rockchip/>
List-Post: <mailto:linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-rockchip" <linux-rockchip-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

After enter arc_emac_probe, emac will get_phy_id, phy_poll_reset and
other connecting PHY via mdiobus_read, so we need to set correct
ref clock rate for emac before probe emac.

Signed-off-by: Xing Zheng <zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
---

Changes in v2: None

 drivers/net/ethernet/arc/emac_rockchip.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/arc/emac_rockchip.c b/drivers/net/ethernet/arc/emac_rockchip.c
index c31c740..36e9eb1 100644
--- a/drivers/net/ethernet/arc/emac_rockchip.c
+++ b/drivers/net/ethernet/arc/emac_rockchip.c
@@ -164,10 +164,6 @@ static int emac_rockchip_probe(struct platform_device *pdev)
 		}
 	}
 
-	err = arc_emac_probe(ndev, interface);
-	if (err)
-		goto out_regulator_disable;
-
 	/* write-enable bits */
 	data = GRF_MODE_ENABLE_BIT | GRF_SPEED_ENABLE_BIT;
 
@@ -184,6 +180,13 @@ static int emac_rockchip_probe(struct platform_device *pdev)
 	err = clk_set_rate(priv->refclk, 50000000);
 	if (err)
 		dev_err(dev, "failed to change reference clock rate (%d)\n", err);
+
+	err = arc_emac_probe(ndev, interface);
+	if (err) {
+		dev_err(dev, "failed to probe arc emac (%d)\n", err);
+		goto out_regulator_disable;
+	}
+
 	return 0;
 
 out_regulator_disable:
-- 
1.7.9.5
