From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 9/9] tg3: Add additional EEE messaging
Date: Wed, 20 Apr 2011 10:57:43 -0700
Message-ID: <1303322263-18991-10-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1815 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752253Ab1DTRs0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 13:48:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds link messages and an item to the sign-on banner to make
EEE status more visible.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 9ed6bfb..693f36e 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1360,6 +1360,11 @@ static void tg3_link_report(struct tg3 *tp)
 			    "on" : "off",
 			    (tp->link_config.active_flowctrl & FLOW_CTRL_RX) ?
 			    "on" : "off");
+
+		if (tp->phy_flags & TG3_PHYFLG_EEE_CAP)
+			netdev_info(tp->dev, "EEE is %s\n",
+				    tp->setlpicnt ? "enabled" : "disabled");
+
 		tg3_ump_link_report(tp);
 	}
 }
@@ -15278,8 +15283,10 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 			ethtype = "10/100/1000Base-T";
 
 		netdev_info(dev, "attached PHY is %s (%s Ethernet) "
-			    "(WireSpeed[%d])\n", tg3_phy_string(tp), ethtype,
-			  (tp->phy_flags & TG3_PHYFLG_NO_ETH_WIRE_SPEED) == 0);
+			    "(WireSpeed[%d], EEE[%d])\n",
+			    tg3_phy_string(tp), ethtype,
+			    (tp->phy_flags & TG3_PHYFLG_NO_ETH_WIRE_SPEED) == 0,
+			    (tp->phy_flags & TG3_PHYFLG_EEE_CAP) != 0);
 	}
 
 	netdev_info(dev, "RXcsums[%d] LinkChgREG[%d] MIirq[%d] ASF[%d] TSOcap[%d]\n",
-- 
1.7.3.4


