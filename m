From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 04/22] phy: Add phydev_err() and phydev_dbg() macros
Date: Wed,  6 Jan 2016 20:11:09 +0100
Message-ID: <1452107487-475-5-git-send-email-andrew@lunn.ch>
References: <1452107487-475-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42333 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751653AbcAFTMg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 14:12:36 -0500
In-Reply-To: <1452107487-475-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for moving some of the phy_device structure members,
add macros for printing errors and debug information.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/at803x.c  |  4 ++--
 drivers/net/phy/bcm87xx.c |  5 +++--
 drivers/net/phy/micrel.c  | 16 +++++++++-------
 drivers/net/phy/phy.c     |  5 +++--
 include/linux/phy.h       |  6 ++++++
 5 files changed, 23 insertions(+), 13 deletions(-)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index 2d020a3ec0b5..62361f8af375 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -281,8 +281,8 @@ static void at803x_link_change_notify(struct phy_device *phydev)
 
 				at803x_context_restore(phydev, &context);
 
-				dev_dbg(&phydev->dev, "%s(): phy was reset\n",
-					__func__);
+				phydev_dbg(phydev, "%s(): phy was reset\n",
+					   __func__);
 				priv->phy_reset = true;
 			}
 		} else {
diff --git a/drivers/net/phy/bcm87xx.c b/drivers/net/phy/bcm87xx.c
index 1eca20452f03..71b491c7bf96 100644
--- a/drivers/net/phy/bcm87xx.c
+++ b/drivers/net/phy/bcm87xx.c
@@ -163,8 +163,9 @@ static int bcm87xx_did_interrupt(struct phy_device *phydev)
 	reg = phy_read(phydev, BCM87XX_LASI_STATUS);
 
 	if (reg < 0) {
-		dev_err(&phydev->dev,
-			"Error: Read of BCM87XX_LASI_STATUS failed: %d\n", reg);
+		phydev_err(phydev,
+			   "Error: Read of BCM87XX_LASI_STATUS failed: %d\n",
+			   reg);
 		return 0;
 	}
 	return (reg & 1) != 0;
diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 1a6048a8c29d..bf72365e90bc 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -224,7 +224,7 @@ static int kszphy_setup_led(struct phy_device *phydev, u32 reg, int val)
 	rc = phy_write(phydev, reg, temp);
 out:
 	if (rc < 0)
-		dev_err(&phydev->dev, "failed to set led mode\n");
+		phydev_err(phydev, "failed to set led mode\n");
 
 	return rc;
 }
@@ -243,7 +243,7 @@ static int kszphy_broadcast_disable(struct phy_device *phydev)
 	ret = phy_write(phydev, MII_KSZPHY_OMSO, ret | KSZPHY_OMSO_B_CAST_OFF);
 out:
 	if (ret)
-		dev_err(&phydev->dev, "failed to disable broadcast address\n");
+		phydev_err(phydev, "failed to disable broadcast address\n");
 
 	return ret;
 }
@@ -263,7 +263,7 @@ static int kszphy_nand_tree_disable(struct phy_device *phydev)
 			ret & ~KSZPHY_OMSO_NAND_TREE_ON);
 out:
 	if (ret)
-		dev_err(&phydev->dev, "failed to disable NAND tree mode\n");
+		phydev_err(phydev, "failed to disable NAND tree mode\n");
 
 	return ret;
 }
@@ -288,7 +288,8 @@ static int kszphy_config_init(struct phy_device *phydev)
 	if (priv->rmii_ref_clk_sel) {
 		ret = kszphy_rmii_clk_sel(phydev, priv->rmii_ref_clk_sel_val);
 		if (ret) {
-			dev_err(&phydev->dev, "failed to set rmii reference clock\n");
+			phydev_err(phydev,
+				   "failed to set rmii reference clock\n");
 			return ret;
 		}
 	}
@@ -649,8 +650,8 @@ static int kszphy_probe(struct phy_device *phydev)
 			priv->led_mode = -1;
 
 		if (priv->led_mode > 3) {
-			dev_err(&phydev->dev, "invalid led mode: 0x%02x\n",
-					priv->led_mode);
+			phydev_err(phydev, "invalid led mode: 0x%02x\n",
+				   priv->led_mode);
 			priv->led_mode = -1;
 		}
 	} else {
@@ -672,7 +673,8 @@ static int kszphy_probe(struct phy_device *phydev)
 		} else if (rate > 49500000 && rate < 50500000) {
 			priv->rmii_ref_clk_sel_val = !rmii_ref_clk_sel_25_mhz;
 		} else {
-			dev_err(&phydev->dev, "Clock rate out of range: %ld\n", rate);
+			phydev_err(phydev, "Clock rate out of range: %ld\n",
+				   rate);
 			return -EINVAL;
 		}
 	}
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 47cd306dbb3c..9771941cf0ee 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -995,8 +995,9 @@ void phy_state_machine(struct work_struct *work)
 	if (err < 0)
 		phy_error(phydev);
 
-	dev_dbg(&phydev->dev, "PHY state change %s -> %s\n",
-		phy_state_to_str(old_state), phy_state_to_str(phydev->state));
+	phydev_dbg(phydev, "PHY state change %s -> %s\n",
+		   phy_state_to_str(old_state),
+		   phy_state_to_str(phydev->state));
 
 	queue_delayed_work(system_power_efficient_wq, &phydev->state_queue,
 			   PHY_STATE_TIME * HZ);
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 8ca161a37e8a..dbcf9fdd960c 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -777,6 +777,12 @@ static inline int phy_read_status(struct phy_device *phydev)
 	return phydev->drv->read_status(phydev);
 }
 
+#define phydev_err(_phydev, format, args...)	\
+	dev_err(&_phydev->dev, format, ##args)
+
+#define phydev_dbg(_phydev, format, args...)	\
+	dev_dbg(&_phydev->dev, format, ##args)
+
 int genphy_config_init(struct phy_device *phydev);
 int genphy_setup_forced(struct phy_device *phydev);
 int genphy_restart_aneg(struct phy_device *phydev);
-- 
2.6.4
