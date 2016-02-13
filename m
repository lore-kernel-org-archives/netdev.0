From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Subject: [PATCH] drivers: net: cpsw-phy-sel: add dev_warn() for unsupported
 PHY mode
Date: Fri, 12 Feb 2016 19:45:36 -0500
Message-ID: <1455324336-3884-1-git-send-email-drivshin.allworx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Nicolas Chauvet <kwizart@gmail.com>, Mugunthan V N <mugunthanvnm@ti.com>,
 linux-omap@vger.kernel.org, David Miller <davem@davemloft.net>,
 linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
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

From: David Rivshin <drivshin@allworx.com>

The cpsw-phy-sel driver supports only MII, RMII, and RGMII PHY modes,
and silently handled any other values as if MII was specified. In a
case where the PHY mode was incorrectly specified, or a bug elsewhere,
there would be no indication of a problem. If MII was the correct mode,
then this will go unnoticed, otherwise the symptom will be a failure
to transmit/receive data over the RMII/RGMII link.

Add a dev_warn() to make this condition obvious and provide a
breadcrumb to follow.

Cc: Mugunthan V N <mugunthanvnm@ti.com>
Signed-off-by: David Rivshin <drivshin@allworx.com>
---

Dave,
 I'm not sure if you'd consider this net or net-next material, but it will
apply cleanly to either. Indeed, if you want it for -stable, it applies back
as far as 3.18.

 drivers/net/ethernet/ti/cpsw-phy-sel.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw-phy-sel.c b/drivers/net/ethernet/ti/cpsw-phy-sel.c
index e9cc61e..c3e85ac 100644
--- a/drivers/net/ethernet/ti/cpsw-phy-sel.c
+++ b/drivers/net/ethernet/ti/cpsw-phy-sel.c
@@ -63,8 +63,12 @@ static void cpsw_gmii_sel_am3352(struct cpsw_phy_sel_priv *priv,
 		mode = AM33XX_GMII_SEL_MODE_RGMII;
 		break;
 
-	case PHY_INTERFACE_MODE_MII:
 	default:
+		dev_warn(priv->dev,
+			 "Unsupported PHY mode: \"%s\". Defaulting to MII.\n",
+			phy_modes(phy_mode));
+		/* fallthrough */
+	case PHY_INTERFACE_MODE_MII:
 		mode = AM33XX_GMII_SEL_MODE_MII;
 		break;
 	};
@@ -106,8 +110,12 @@ static void cpsw_gmii_sel_dra7xx(struct cpsw_phy_sel_priv *priv,
 		mode = AM33XX_GMII_SEL_MODE_RGMII;
 		break;
 
-	case PHY_INTERFACE_MODE_MII:
 	default:
+		dev_warn(priv->dev,
+			 "Unsupported PHY mode: \"%s\". Defaulting to MII.\n",
+			phy_modes(phy_mode));
+		/* fallthrough */
+	case PHY_INTERFACE_MODE_MII:
 		mode = AM33XX_GMII_SEL_MODE_MII;
 		break;
 	};
-- 
2.5.0
