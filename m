From: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Subject: [PATCH v4 3/6] net: stmmac: dwmac-rk: add pd_gmac support for rk3399
Date: Fri,  2 Sep 2016 01:50:01 +0800
Message-ID: <1472752204-8924-4-git-send-email-wxt@rock-chips.com>
References: <1472752204-8924-1-git-send-email-wxt@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Brian Norris <briannorris-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
 Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 dbasehore-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, Douglas Anderson <dianders-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
 Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>, Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
To: Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1472752204-8924-1-git-send-email-wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
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

From: David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>

Add the gmac power domain support for rk3399, in order to save more
power consumption.

Signed-off-by: David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Signed-off-by: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
---

Changes in v4: None
Changes in v3: None
Changes in v2:
- fixes the build error on next kernel.

 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index e2ba6c4..3740a44 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -30,6 +30,7 @@
 #include <linux/delay.h>
 #include <linux/mfd/syscon.h>
 #include <linux/regmap.h>
+#include <linux/pm_runtime.h>
 
 #include "stmmac_platform.h"
 
@@ -883,11 +884,19 @@ static int rk_gmac_powerup(struct rk_priv_data *bsp_priv)
 	if (ret)
 		return ret;
 
+	pm_runtime_enable(dev);
+	pm_runtime_get_sync(dev);
+
 	return 0;
 }
 
 static void rk_gmac_powerdown(struct rk_priv_data *gmac)
 {
+	struct device *dev = &gmac->pdev->dev;
+
+	pm_runtime_put_sync(dev);
+	pm_runtime_disable(dev);
+
 	phy_power_on(gmac, false);
 	gmac_clk_enable(gmac, false);
 }
-- 
1.9.1
