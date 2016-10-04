From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [net-next 09/13] fsl/fman: check of_get_phy_mode() return value
Date: Tue, 4 Oct 2016 10:32:55 +0300
Message-ID: <1475566379-5078-10-git-send-email-madalin.bucur@nxp.com>
References: <1475566379-5078-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: madalin.bucur@nxp.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: linuxdev.baldrick@gmail.com, linuxppc-dev@lists.ozlabs.org,
 davem@davemloft.net, linux-kernel@vger.kernel.org
To: <netdev@vger.kernel.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1475566379-5078-1-git-send-email-madalin.bucur@nxp.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

For unknown compatibles avoid crashing and default to SGMII.

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 drivers/net/ethernet/freescale/fman/mac.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fman/mac.c b/drivers/net/ethernet/freescale/fman/mac.c
index e4378c2..8fe6b3e 100644
--- a/drivers/net/ethernet/freescale/fman/mac.c
+++ b/drivers/net/ethernet/freescale/fman/mac.c
@@ -663,6 +663,7 @@ static int mac_probe(struct platform_device *_of_dev)
 	const u8		*mac_addr;
 	u32			 val;
 	u8			fman_id;
+	int			phy_if;
 
 	dev = &_of_dev->dev;
 	mac_node = dev->of_node;
@@ -842,13 +843,14 @@ static int mac_probe(struct platform_device *_of_dev)
 	}
 
 	/* Get the PHY connection type */
-	priv->phy_if = of_get_phy_mode(mac_node);
-	if (priv->phy_if < 0) {
+	phy_if = of_get_phy_mode(mac_node);
+	if (phy_if < 0) {
 		dev_warn(dev,
-			 "of_get_phy_mode() for %s failed. Defaulting to MII\n",
+			 "of_get_phy_mode() for %s failed. Defaulting to SGMII\n",
 			 mac_node->full_name);
-		priv->phy_if = PHY_INTERFACE_MODE_MII;
+		phy_if = PHY_INTERFACE_MODE_SGMII;
 	}
+	priv->phy_if = phy_if;
 
 	priv->speed		= phy2speed[priv->phy_if];
 	priv->max_speed		= priv->speed;
-- 
2.1.0
