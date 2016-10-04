From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [net-next 04/13] fsl/fman: use of_get_phy_mode()
Date: Tue, 4 Oct 2016 10:32:50 +0300
Message-ID: <1475566379-5078-5-git-send-email-madalin.bucur@nxp.com>
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

From: Madalin Bucur <madalin.bucur@freescale.com>

Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
---
 drivers/net/ethernet/freescale/fman/mac.c | 33 ++-----------------------------
 1 file changed, 2 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fman/mac.c b/drivers/net/ethernet/freescale/fman/mac.c
index e33d9d2..f94fad7 100644
--- a/drivers/net/ethernet/freescale/fman/mac.c
+++ b/drivers/net/ethernet/freescale/fman/mac.c
@@ -583,31 +583,6 @@ static void setup_memac(struct mac_device *mac_dev)
 
 static DEFINE_MUTEX(eth_lock);
 
-static const char phy_str[][11] = {
-	[PHY_INTERFACE_MODE_MII]		= "mii",
-	[PHY_INTERFACE_MODE_GMII]		= "gmii",
-	[PHY_INTERFACE_MODE_SGMII]		= "sgmii",
-	[PHY_INTERFACE_MODE_TBI]		= "tbi",
-	[PHY_INTERFACE_MODE_RMII]		= "rmii",
-	[PHY_INTERFACE_MODE_RGMII]		= "rgmii",
-	[PHY_INTERFACE_MODE_RGMII_ID]		= "rgmii-id",
-	[PHY_INTERFACE_MODE_RGMII_RXID]	= "rgmii-rxid",
-	[PHY_INTERFACE_MODE_RGMII_TXID]	= "rgmii-txid",
-	[PHY_INTERFACE_MODE_RTBI]		= "rtbi",
-	[PHY_INTERFACE_MODE_XGMII]		= "xgmii"
-};
-
-static phy_interface_t __pure __attribute__((nonnull)) str2phy(const char *str)
-{
-	int i;
-
-	for (i = 0; i < ARRAY_SIZE(phy_str); i++)
-		if (strcmp(str, phy_str[i]) == 0)
-			return (phy_interface_t)i;
-
-	return PHY_INTERFACE_MODE_MII;
-}
-
 static const u16 phy2speed[] = {
 	[PHY_INTERFACE_MODE_MII]		= SPEED_100,
 	[PHY_INTERFACE_MODE_GMII]		= SPEED_1000,
@@ -686,7 +661,6 @@ static int mac_probe(struct platform_device *_of_dev)
 	struct resource		 res;
 	struct mac_priv_s	*priv;
 	const u8		*mac_addr;
-	const char		*char_prop;
 	const u32		*u32_prop;
 	u8			fman_id;
 
@@ -870,15 +844,12 @@ static int mac_probe(struct platform_device *_of_dev)
 	}
 
 	/* Get the PHY connection type */
-	char_prop = (const char *)of_get_property(mac_node,
-						  "phy-connection-type", NULL);
-	if (!char_prop) {
+	priv->phy_if = of_get_phy_mode(mac_node);
+	if (priv->phy_if < 0) {
 		dev_warn(dev,
 			 "of_get_property(%s, phy-connection-type) failed. Defaulting to MII\n",
 			 mac_node->full_name);
 		priv->phy_if = PHY_INTERFACE_MODE_MII;
-	} else {
-		priv->phy_if = str2phy(char_prop);
 	}
 
 	priv->speed		= phy2speed[priv->phy_if];
-- 
2.1.0
