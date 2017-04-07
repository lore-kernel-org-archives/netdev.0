From: <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next v4 4/5] net-next: ethernet: mediatek: add device_node of GMAC pointing into the netdev instance
Date: Fri, 7 Apr 2017 16:45:08 +0800
Message-ID: <1491554709-9723-5-git-send-email-sean.wang@mediatek.com>
References: <1491554709-9723-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, <Landen.Chao-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>,
        <keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <objelf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: <andrew-g2DYL2Zd6BY@public.gmane.org>, <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>, <matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1491554709-9723-1-git-send-email-sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>

the patch adds the setup of the corresponding device node of GMAC into the
netdev instance which could allow other modules such as DSA to find the
instance through the node in dt-bindings using of_find_net_device_by_node()
call.

Signed-off-by: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Reviewed-by: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Reviewed-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index c21ed99..84b09a4 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -2323,6 +2323,8 @@ static int mtk_add_mac(struct mtk_eth *eth, struct device_node *np)
 	eth->netdev[id]->ethtool_ops = &mtk_ethtool_ops;
 
 	eth->netdev[id]->irq = eth->irq[0];
+	eth->netdev[id]->dev.of_node = np;
+
 	return 0;
 
 free_netdev:
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
