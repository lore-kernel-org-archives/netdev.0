From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 03/15] net: bcm63xx_enet: Utilize phy_ethtool_nway_reset
Date: Tue, 15 Nov 2016 10:06:32 -0800
Message-ID: <20161115180644.3941-4-f.fainelli@gmail.com>
References: <20161115180644.3941-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, Florian Fainelli <f.fainelli@gmail.com>,
 Arnd Bergmann <arnd@arndb.de>, "xypron.glpk@gmx.de" <xypron.glpk@gmx.de>,
 open list <linux-kernel@vger.kernel.org>, Jarod Wilson <jarod@redhat.com>,
 "maintainer:BROADCOM BCM63XX ARM ARCHITECTURE"
 <bcm-kernel-feedback-list@broadcom.com>, Thierry Reding <treding@nvidia.com>,
 davem@davemloft.net, "moderated list:BROADCOM BCM63XX ARM ARCHITECTURE"
 <linux-arm-kernel@lists.infradead.org>, tremyfr@gmail.com
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20161115180644.3941-1-f.fainelli@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 5c7acef1de2e..a43ab90c051e 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -1434,11 +1434,8 @@ static int bcm_enet_nway_reset(struct net_device *dev)
 	struct bcm_enet_priv *priv;
 
 	priv = netdev_priv(dev);
-	if (priv->has_phy) {
-		if (!dev->phydev)
-			return -ENODEV;
-		return genphy_restart_aneg(dev->phydev);
-	}
+	if (priv->has_phy)
+		return phy_ethtool_nway_reset(dev),
 
 	return -EOPNOTSUPP;
 }
-- 
2.9.3
