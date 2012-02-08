From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 27/50] davinci_emac: use dev_hw_addr_random() instead of random_ether_addr()
Date: Wed,  8 Feb 2012 22:10:34 +0100
Message-ID: <1328735457-29986-28-git-send-email-danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Richard Cochran <richard.cochran@omicron.at>,
	Julia Lawall <julia@diku.dk>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Joe Perches <joe@perches.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use dev_hw_addr_random() instead of calling random_ether_addr()
to set addr_assign_type correctly to NET_ADDR_RANDOM.

Reset the state to NET_ADDR_PERM as soon as the MAC get
changed via .ndo_set_mac_address.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/ti/davinci_emac.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 794ac30..fba3f74 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1260,6 +1260,8 @@ static int emac_dev_setmac_addr(struct net_device *ndev, void *addr)
 	/* Store mac addr in priv and rx channel and set it in EMAC hw */
 	memcpy(priv->mac_addr, sa->sa_data, ndev->addr_len);
 	memcpy(ndev->dev_addr, sa->sa_data, ndev->addr_len);
+	if (ndev->addr_assign_type & NET_ADDR_RANDOM)
+		ndev->addr_assign_type ^= NET_ADDR_RANDOM;
 
 	/* MAC address is configured only after the interface is enabled. */
 	if (netif_running(ndev)) {
@@ -1897,7 +1899,7 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 
 	if (!is_valid_ether_addr(priv->mac_addr)) {
 		/* Use random MAC if none passed */
-		random_ether_addr(priv->mac_addr);
+		dev_hw_addr_random(ndev, priv->mac_addr);
 		dev_warn(&pdev->dev, "using random MAC addr: %pM\n",
 							priv->mac_addr);
 	}
-- 
1.7.7.3
