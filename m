From: Romain Perier <romain.perier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2 1/4] net: stmmac: dwmac-rk: Don't set the regulator voltage for phy from the driver
Date: Tue, 20 Jan 2015 07:09:37 +0000
Message-ID: <1421737780-1533-2-git-send-email-romain.perier@gmail.com>
References: <1421737780-1533-1-git-send-email-romain.perier@gmail.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org, linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org
To: peppe.cavallaro-qxv4g6HH51o@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1421737780-1533-1-git-send-email-romain.perier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

As these settings can be directly expressed from devicetree for both fixed
regulators and pmic-integrated regulators, it is more standard to set them
from dts and let the regulator framework use the right voltage informations
when it is used in the driver.

Signed-off-by: Romain Perier <romain.perier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 35f9b86..06e1637 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -303,7 +303,6 @@ static int phy_power_on(struct rk_priv_data *bsp_priv, bool enable)
 	} else {
 		if (enable) {
 			if (!regulator_is_enabled(ldo)) {
-				regulator_set_voltage(ldo, 3300000, 3300000);
 				ret = regulator_enable(ldo);
 				if (ret != 0)
 					dev_err(dev, "%s: fail to enable %s\n",
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
