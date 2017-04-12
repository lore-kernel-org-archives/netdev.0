From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v4 02/18] net: stmmac: add optional setup function
Date: Wed, 12 Apr 2017 13:13:44 +0200
Message-ID: <20170412111400.2296-3-clabbe.montjoie@gmail.com>
References: <20170412111400.2296-1-clabbe.montjoie@gmail.com>
Reply-To: clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	mark.rutland-5wv7dgnIgG8@public.gmane.org,
	maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	wens-jdAy2FN1RRM@public.gmane.org,
	linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org,
	catalin.marinas-5wv7dgnIgG8@public.gmane.org,
	will.deacon-5wv7dgnIgG8@public.gmane.org,
	peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
	alexandre.torgue-qxv4g6HH51o@public.gmane.org
Return-path: <linux-sunxi+bncBD7YLCN32UNBB6UYXDDQKGQEVZBX2UA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20170412111400.2296-1-clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

Instead of adding more ifthen logic for adding a new mac_device_info
setup function, it is easier to add a function pointer to the function
needed.

Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 4 +++-
 include/linux/stmmac.h                            | 1 +
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index a89f76b..72d371d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -3946,7 +3946,9 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 	struct mac_device_info *mac;
 
 	/* Identify the MAC HW device */
-	if (priv->plat->has_gmac) {
+	if (priv->plat->setup) {
+		mac = priv->plat->setup(priv);
+	} else if (priv->plat->has_gmac) {
 		priv->dev->priv_flags |= IFF_UNICAST_FLT;
 		mac = dwmac1000_setup(priv->ioaddr,
 				      priv->plat->multicast_filter_bins,
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 3921cb9..8bb550b 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -177,6 +177,7 @@ struct plat_stmmacenet_data {
 	void (*fix_mac_speed)(void *priv, unsigned int speed);
 	int (*init)(struct platform_device *pdev, void *priv);
 	void (*exit)(struct platform_device *pdev, void *priv);
+	struct mac_device_info *(*setup)(void *priv);
 	void *bsp_priv;
 	struct clk *stmmac_clk;
 	struct clk *pclk;
-- 
2.10.2
