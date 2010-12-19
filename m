From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: [PATCH 3/4] net: phy: White space correction and switch/case braces
Date: Sun, 19 Dec 2010 11:58:50 +0100
Message-ID: <1292756331-3735-3-git-send-email-jhautbois@gmail.com>
References: <1292756331-3735-1-git-send-email-jhautbois@gmail.com>
Cc: richard.cochran@omicron.at, shemminger@vyatta.com, tj@kernel.org,
	randy.dunlap@oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Jean-Michel Hautbois <jhautbois@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1292756331-3735-1-git-send-email-jhautbois@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Little corrections in the file :
- use linux and not asm for some include files
- Trailing whitespaces removed
- no lines over 80 characters
- switch and case on the same column

Signed-off-by: Jean-Michel Hautbois <jhautbois@gmail.com>
---
 drivers/net/phy/phy.c |  304 ++++++++++++++++++++++++------------------------
 1 files changed, 152 insertions(+), 152 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 4ab48d7..87a64c0 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -33,10 +33,10 @@
 #include <linux/timer.h>
 #include <linux/workqueue.h>
 
-#include <asm/atomic.h>
-#include <asm/io.h>
+#include <linux/atomic.h>
+#include <linux/io.h>
 #include <asm/irq.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 
 /**
  * phy_print_status - Convenience function to print out the current phy status
@@ -48,7 +48,8 @@ void phy_print_status(struct phy_device *phydev)
 		pr_info("PHY: %s - Link is up - %d/%s\n",
 				dev_name(&phydev->dev),
 				phydev->speed,
-				phydev->duplex == DUPLEX_FULL ? "Full" : "Half");
+				phydev->duplex == DUPLEX_FULL ?
+				"Full" : "Half");
 	else
 		pr_info("PHY: %s - Link is down\n",
 				dev_name(&phydev->dev));
@@ -325,7 +326,7 @@ int phy_mii_ioctl(struct phy_device *phydev,
 
 	case SIOCSMIIREG:
 		if (mii_data->phy_id == phydev->addr) {
-			switch(mii_data->reg_num) {
+			switch (mii_data->reg_num) {
 			case MII_BMCR:
 				if ((val & (BMCR_RESET|BMCR_ANENABLE)) == 0)
 					phydev->autoneg = AUTONEG_DISABLE;
@@ -352,7 +353,6 @@ int phy_mii_ioctl(struct phy_device *phydev,
 		}
 
 		phy_write(phydev, mii_data->reg_num, val);
-		
 		if (mii_data->reg_num == MII_BMCR &&
 		    val & BMCR_RESET &&
 		    phydev->drv->config_init) {
@@ -471,7 +471,7 @@ static void phy_force_reduction(struct phy_device *phydev)
 	int idx;
 
 	idx = phy_find_setting(phydev->speed, phydev->duplex);
-	
+
 	idx++;
 
 	idx = phy_find_valid(idx, phydev->supported);
@@ -749,16 +749,16 @@ void phy_start(struct phy_device *phydev)
 	mutex_lock(&phydev->lock);
 
 	switch (phydev->state) {
-		case PHY_STARTING:
-			phydev->state = PHY_PENDING;
-			break;
-		case PHY_READY:
-			phydev->state = PHY_UP;
-			break;
-		case PHY_HALTED:
-			phydev->state = PHY_RESUMING;
-		default:
-			break;
+	case PHY_STARTING:
+		phydev->state = PHY_PENDING;
+		break;
+	case PHY_READY:
+		phydev->state = PHY_UP;
+		break;
+	case PHY_HALTED:
+		phydev->state = PHY_RESUMING;
+	default:
+		break;
 	}
 	mutex_unlock(&phydev->lock);
 }
@@ -782,172 +782,157 @@ void phy_state_machine(struct work_struct *work)
 	if (phydev->adjust_state)
 		phydev->adjust_state(phydev->attached_dev);
 
-	switch(phydev->state) {
-		case PHY_DOWN:
-		case PHY_STARTING:
-		case PHY_READY:
-		case PHY_PENDING:
-			break;
-		case PHY_UP:
-			needs_aneg = 1;
+	switch (phydev->state) {
+	case PHY_DOWN:
+	case PHY_STARTING:
+	case PHY_READY:
+	case PHY_PENDING:
+		break;
+	case PHY_UP:
+		needs_aneg = 1;
 
-			phydev->link_timeout = PHY_AN_TIMEOUT;
+		phydev->link_timeout = PHY_AN_TIMEOUT;
+
+		break;
+	case PHY_AN:
+		err = phy_read_status(phydev);
 
+		if (err < 0)
 			break;
-		case PHY_AN:
-			err = phy_read_status(phydev);
 
-			if (err < 0)
-				break;
+		/* If the link is down, give up on
+		 * negotiation for now */
+		if (!phydev->link) {
+			phydev->state = PHY_NOLINK;
+			netif_carrier_off(phydev->attached_dev);
+			phydev->adjust_link(phydev->attached_dev);
+			break;
+		}
 
-			/* If the link is down, give up on
-			 * negotiation for now */
-			if (!phydev->link) {
-				phydev->state = PHY_NOLINK;
-				netif_carrier_off(phydev->attached_dev);
-				phydev->adjust_link(phydev->attached_dev);
-				break;
-			}
+		/* Check if negotiation is done.  Break
+		 * if there's an error */
+		err = phy_aneg_done(phydev);
+		if (err < 0)
+			break;
 
-			/* Check if negotiation is done.  Break
-			 * if there's an error */
-			err = phy_aneg_done(phydev);
-			if (err < 0)
-				break;
+		/* If AN is done, we're running */
+		if (err > 0) {
+			phydev->state = PHY_RUNNING;
+			netif_carrier_on(phydev->attached_dev);
+			phydev->adjust_link(phydev->attached_dev);
 
-			/* If AN is done, we're running */
-			if (err > 0) {
-				phydev->state = PHY_RUNNING;
-				netif_carrier_on(phydev->attached_dev);
-				phydev->adjust_link(phydev->attached_dev);
+		} else if (0 == phydev->link_timeout--) {
+			int idx;
 
-			} else if (0 == phydev->link_timeout--) {
-				int idx;
+			needs_aneg = 1;
+			/* If we have the magic_aneg bit,
+			 * we try again */
+			if (phydev->drv->flags & PHY_HAS_MAGICANEG)
+				break;
 
-				needs_aneg = 1;
-				/* If we have the magic_aneg bit,
-				 * we try again */
-				if (phydev->drv->flags & PHY_HAS_MAGICANEG)
-					break;
+			/* The timer expired, and we still
+			 * don't have a setting, so we try
+			 * forcing it until we find one that
+			 * works, starting from the fastest speed,
+			 * and working our way down */
+			idx = phy_find_valid(0, phydev->supported);
 
-				/* The timer expired, and we still
-				 * don't have a setting, so we try
-				 * forcing it until we find one that
-				 * works, starting from the fastest speed,
-				 * and working our way down */
-				idx = phy_find_valid(0, phydev->supported);
+			phydev->speed = settings[idx].speed;
+			phydev->duplex = settings[idx].duplex;
 
-				phydev->speed = settings[idx].speed;
-				phydev->duplex = settings[idx].duplex;
+			phydev->autoneg = AUTONEG_DISABLE;
 
-				phydev->autoneg = AUTONEG_DISABLE;
+			pr_info("Trying %d/%s\n", phydev->speed,
+					DUPLEX_FULL ==
+					phydev->duplex ?
+					"FULL" : "HALF");
+		}
+		break;
+	case PHY_NOLINK:
+		err = phy_read_status(phydev);
 
-				pr_info("Trying %d/%s\n", phydev->speed,
-						DUPLEX_FULL ==
-						phydev->duplex ?
-						"FULL" : "HALF");
-			}
+		if (err)
 			break;
-		case PHY_NOLINK:
-			err = phy_read_status(phydev);
 
-			if (err)
-				break;
+		if (phydev->link) {
+			phydev->state = PHY_RUNNING;
+			netif_carrier_on(phydev->attached_dev);
+			phydev->adjust_link(phydev->attached_dev);
+		}
+		break;
+	case PHY_FORCING:
+		err = genphy_update_link(phydev);
 
-			if (phydev->link) {
-				phydev->state = PHY_RUNNING;
-				netif_carrier_on(phydev->attached_dev);
-				phydev->adjust_link(phydev->attached_dev);
-			}
+		if (err)
 			break;
-		case PHY_FORCING:
-			err = genphy_update_link(phydev);
-
-			if (err)
-				break;
 
-			if (phydev->link) {
-				phydev->state = PHY_RUNNING;
-				netif_carrier_on(phydev->attached_dev);
-			} else {
-				if (0 == phydev->link_timeout--) {
-					phy_force_reduction(phydev);
-					needs_aneg = 1;
-				}
+		if (phydev->link) {
+			phydev->state = PHY_RUNNING;
+			netif_carrier_on(phydev->attached_dev);
+		} else {
+			if (0 == phydev->link_timeout--) {
+				phy_force_reduction(phydev);
+				needs_aneg = 1;
 			}
+		}
 
-			phydev->adjust_link(phydev->attached_dev);
-			break;
-		case PHY_RUNNING:
-			/* Only register a CHANGE if we are
-			 * polling */
-			if (PHY_POLL == phydev->irq)
-				phydev->state = PHY_CHANGELINK;
+		phydev->adjust_link(phydev->attached_dev);
+		break;
+	case PHY_RUNNING:
+		/* Only register a CHANGE if we are
+		 * polling */
+		if (PHY_POLL == phydev->irq)
+			phydev->state = PHY_CHANGELINK;
+		break;
+	case PHY_CHANGELINK:
+		err = phy_read_status(phydev);
+
+		if (err)
 			break;
-		case PHY_CHANGELINK:
-			err = phy_read_status(phydev);
 
-			if (err)
-				break;
+		if (phydev->link) {
+			phydev->state = PHY_RUNNING;
+			netif_carrier_on(phydev->attached_dev);
+		} else {
+			phydev->state = PHY_NOLINK;
+			netif_carrier_off(phydev->attached_dev);
+		}
 
-			if (phydev->link) {
-				phydev->state = PHY_RUNNING;
-				netif_carrier_on(phydev->attached_dev);
-			} else {
-				phydev->state = PHY_NOLINK;
-				netif_carrier_off(phydev->attached_dev);
-			}
+		phydev->adjust_link(phydev->attached_dev);
 
+		if (PHY_POLL != phydev->irq)
+			err = phy_config_interrupt(phydev,
+					PHY_INTERRUPT_ENABLED);
+		break;
+	case PHY_HALTED:
+		if (phydev->link) {
+			phydev->link = 0;
+			netif_carrier_off(phydev->attached_dev);
 			phydev->adjust_link(phydev->attached_dev);
+		}
+		break;
+	case PHY_RESUMING:
 
-			if (PHY_POLL != phydev->irq)
-				err = phy_config_interrupt(phydev,
-						PHY_INTERRUPT_ENABLED);
-			break;
-		case PHY_HALTED:
-			if (phydev->link) {
-				phydev->link = 0;
-				netif_carrier_off(phydev->attached_dev);
-				phydev->adjust_link(phydev->attached_dev);
-			}
-			break;
-		case PHY_RESUMING:
+		err = phy_clear_interrupt(phydev);
 
-			err = phy_clear_interrupt(phydev);
+		if (err)
+			break;
 
-			if (err)
-				break;
+		err = phy_config_interrupt(phydev,
+				PHY_INTERRUPT_ENABLED);
 
-			err = phy_config_interrupt(phydev,
-					PHY_INTERRUPT_ENABLED);
+		if (err)
+			break;
 
-			if (err)
+		if (AUTONEG_ENABLE == phydev->autoneg) {
+			err = phy_aneg_done(phydev);
+			if (err < 0)
 				break;
 
-			if (AUTONEG_ENABLE == phydev->autoneg) {
-				err = phy_aneg_done(phydev);
-				if (err < 0)
-					break;
-
-				/* err > 0 if AN is done.
-				 * Otherwise, it's 0, and we're
-				 * still waiting for AN */
-				if (err > 0) {
-					err = phy_read_status(phydev);
-					if (err)
-						break;
-
-					if (phydev->link) {
-						phydev->state = PHY_RUNNING;
-						netif_carrier_on(phydev->attached_dev);
-					} else
-						phydev->state = PHY_NOLINK;
-					phydev->adjust_link(phydev->attached_dev);
-				} else {
-					phydev->state = PHY_AN;
-					phydev->link_timeout = PHY_AN_TIMEOUT;
-				}
-			} else {
+			/* err > 0 if AN is done.
+			 * Otherwise, it's 0, and we're
+			 * still waiting for AN */
+			if (err > 0) {
 				err = phy_read_status(phydev);
 				if (err)
 					break;
@@ -958,8 +943,23 @@ void phy_state_machine(struct work_struct *work)
 				} else
 					phydev->state = PHY_NOLINK;
 				phydev->adjust_link(phydev->attached_dev);
+			} else {
+				phydev->state = PHY_AN;
+				phydev->link_timeout = PHY_AN_TIMEOUT;
 			}
-			break;
+		} else {
+			err = phy_read_status(phydev);
+			if (err)
+				break;
+
+			if (phydev->link) {
+				phydev->state = PHY_RUNNING;
+				netif_carrier_on(phydev->attached_dev);
+			} else
+				phydev->state = PHY_NOLINK;
+			phydev->adjust_link(phydev->attached_dev);
+		}
+		break;
 	}
 
 	mutex_unlock(&phydev->lock);
-- 
1.7.0.4
