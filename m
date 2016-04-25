From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH] net: ethernet: davinci_emac: Fix devioctl while in fixed link
Date: Mon, 25 Apr 2016 19:41:38 +0200
Message-ID: <1461606098-20057-1-git-send-email-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong@baylibre.com>,
	Brian Hutchinson <b.hutchman@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Tom Lendacky <thomas.lendacky@amd.com>,
	Mugunthan V N <mugunthanvnm@ti.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When configured in fixed link, the DaVinci emac driver sets the
priv->phydev to NULL and further ioctl calls to the phy_mii_ioctl()
causes the kernel to crash.

Cc: Brian Hutchinson <b.hutchman@gmail.com>
Fixes: 1bb6aa56bb38 ("net: davinci_emac: Add support for fixed-link PHY")
Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 drivers/net/ethernet/ti/davinci_emac.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 58d58f0..f56d66e 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1512,7 +1512,10 @@ static int emac_devioctl(struct net_device *ndev, struct ifreq *ifrq, int cmd)
 
 	/* TODO: Add phy read and write and private statistics get feature */
 
-	return phy_mii_ioctl(priv->phydev, ifrq, cmd);
+	if (priv->phydev)
+		return phy_mii_ioctl(priv->phydev, ifrq, cmd);
+	else
+		return -EOPNOTSUPP;
 }
 
 static int match_first_device(struct device *dev, void *data)
-- 
1.9.1
