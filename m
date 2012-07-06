From: <s-paulraj@ti.com>
Subject: [PATCH 1/4] phylib: factor out handler callouts into helper
Date: Fri, 6 Jul 2012 16:09:26 -0400
Message-ID: <1341605366-20508-1-git-send-email-s-paulraj@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sandeep Paulraj <s-paulraj@ti.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>, <cyril@ti.com>,
	<grant.likely@secretlab.ca>, <linux-keystone@list.ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:42511 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756845Ab2GFUJe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 16:09:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sandeep Paulraj <s-paulraj@ti.com>

This patch pulls out adjust_link handler callbacks into a helper function.
The patch does not modify phylib behavior in any material way.

Signed-off-by: Cyril Chemparathy <cyril@ti.com>
Signed-off-by: Sandeep Paulraj <s-paulraj@ti.com>
---
 drivers/net/phy/phy.c |   21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 3cbda08..36ca912 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -761,6 +761,11 @@ void phy_start(struct phy_device *phydev)
 EXPORT_SYMBOL(phy_stop);
 EXPORT_SYMBOL(phy_start);
 
+static inline void phy_adjust_link(struct phy_device *phydev)
+{
+	phydev->adjust_link(phydev->attached_dev);
+}
+
 /**
  * phy_state_machine - Handle the state machine
  * @work: work_struct that describes the work to be done
@@ -801,7 +806,7 @@ void phy_state_machine(struct work_struct *work)
 			if (!phydev->link) {
 				phydev->state = PHY_NOLINK;
 				netif_carrier_off(phydev->attached_dev);
-				phydev->adjust_link(phydev->attached_dev);
+				phy_adjust_link(phydev);
 				break;
 			}
 
@@ -815,7 +820,7 @@ void phy_state_machine(struct work_struct *work)
 			if (err > 0) {
 				phydev->state = PHY_RUNNING;
 				netif_carrier_on(phydev->attached_dev);
-				phydev->adjust_link(phydev->attached_dev);
+				phy_adjust_link(phydev);
 
 			} else if (0 == phydev->link_timeout--) {
 				int idx;
@@ -853,7 +858,7 @@ void phy_state_machine(struct work_struct *work)
 			if (phydev->link) {
 				phydev->state = PHY_RUNNING;
 				netif_carrier_on(phydev->attached_dev);
-				phydev->adjust_link(phydev->attached_dev);
+				phy_adjust_link(phydev);
 			}
 			break;
 		case PHY_FORCING:
@@ -872,7 +877,7 @@ void phy_state_machine(struct work_struct *work)
 				}
 			}
 
-			phydev->adjust_link(phydev->attached_dev);
+			phy_adjust_link(phydev);
 			break;
 		case PHY_RUNNING:
 			/* Only register a CHANGE if we are
@@ -894,7 +899,7 @@ void phy_state_machine(struct work_struct *work)
 				netif_carrier_off(phydev->attached_dev);
 			}
 
-			phydev->adjust_link(phydev->attached_dev);
+			phy_adjust_link(phydev);
 
 			if (PHY_POLL != phydev->irq)
 				err = phy_config_interrupt(phydev,
@@ -904,7 +909,7 @@ void phy_state_machine(struct work_struct *work)
 			if (phydev->link) {
 				phydev->link = 0;
 				netif_carrier_off(phydev->attached_dev);
-				phydev->adjust_link(phydev->attached_dev);
+				phy_adjust_link(phydev);
 			}
 			break;
 		case PHY_RESUMING:
@@ -938,7 +943,7 @@ void phy_state_machine(struct work_struct *work)
 						netif_carrier_on(phydev->attached_dev);
 					} else
 						phydev->state = PHY_NOLINK;
-					phydev->adjust_link(phydev->attached_dev);
+					phy_adjust_link(phydev);
 				} else {
 					phydev->state = PHY_AN;
 					phydev->link_timeout = PHY_AN_TIMEOUT;
@@ -953,7 +958,7 @@ void phy_state_machine(struct work_struct *work)
 					netif_carrier_on(phydev->attached_dev);
 				} else
 					phydev->state = PHY_NOLINK;
-				phydev->adjust_link(phydev->attached_dev);
+				phy_adjust_link(phydev);
 			}
 			break;
 	}
-- 
1.7.9.5
