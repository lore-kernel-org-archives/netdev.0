From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 04/10] sky2: fiber pause bits
Date: Wed, 11 Oct 2006 14:22:29 -0700
Message-ID: <20061011212310.662760992@osdl.org>
References: <20061011212225.941046083@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18381 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161490AbWJKV0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2006 17:26:11 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-fiber-pause-bits.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The advertisement bits for flow control are located in
different location on fiber (1000baseX)

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- sky2.orig/drivers/net/sky2.c	2006-10-11 11:43:43.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-10-11 11:43:47.000000000 -0700
@@ -384,20 +384,31 @@
 				adv |= PHY_M_AN_10_FD;
 			if (sky2->advertising & ADVERTISED_10baseT_Half)
 				adv |= PHY_M_AN_10_HD;
+
+			/* desired flow control */
+			if (sky2->tx_pause && sky2->rx_pause)	/* both */
+				adv |= PHY_M_AN_PC | PHY_M_AN_ASP;
+			else if (sky2->tx_pause)
+				adv |= PHY_M_AN_ASP;
+			else if (sky2->rx_pause)
+				adv |= PHY_M_AN_PC;
+
+
 		} else {	/* special defines for FIBER (88E1040S only) */
 			if (sky2->advertising & ADVERTISED_1000baseT_Full)
 				adv |= PHY_M_AN_1000X_AFD;
 			if (sky2->advertising & ADVERTISED_1000baseT_Half)
 				adv |= PHY_M_AN_1000X_AHD;
-		}
 
-		/* Set Flow-control capabilities */
-		if (sky2->tx_pause && sky2->rx_pause)
-			adv |= PHY_AN_PAUSE_CAP;	/* symmetric */
-		else if (sky2->rx_pause && !sky2->tx_pause)
-			adv |= PHY_AN_PAUSE_ASYM | PHY_AN_PAUSE_CAP;
-		else if (!sky2->rx_pause && sky2->tx_pause)
-			adv |= PHY_AN_PAUSE_ASYM;	/* local */
+			if (sky2->tx_pause && sky2->rx_pause)	/* both */
+ 				adv |= PHY_M_P_BOTH_MD_X;
+			else if (sky2->tx_pause)
+				adv |= PHY_M_P_ASYM_MD_X;
+			else if (sky2->rx_pause)
+ 				adv |= PHY_M_P_SYM_MD_X;
+			else
+				adv |= PHY_M_P_NO_PAUSE_X;
+		}
 
 		/* Restart Auto-negotiation */
 		ctrl |= PHY_CT_ANE | PHY_CT_RE_CFG;

--
Stephen Hemminger <shemminger@osdl.org>

