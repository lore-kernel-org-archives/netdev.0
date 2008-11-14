From: David Miller <davem@davemloft.net>
Subject: Re: PATCH[1/1] NIU: Add Sun CP3260 ATCA blade support
Date: Fri, 14 Nov 2008 14:45:21 -0800 (PST)
Message-ID: <20081114.144521.56971719.davem@davemloft.net>
References: <491DB3B4.5010805@Sun.COM>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Matheos.Worku@Sun.COM
To: Santwona.Behera@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51098
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751608AbYKNWpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 17:45:22 -0500
In-Reply-To: <491DB3B4.5010805@Sun.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Santwona.Behera@Sun.COM
Date: Fri, 14 Nov 2008 09:21:56 -0800

> This patch adds support for the Sun CP3260 ATCA blade which is
> a N2 based ATCA blade with 2 NIU ports. The NIU ports do not
> have on-board PHY.

This patch looks great.

I've made some extremely minor coding style fixups, and applied
this patch to net-2.6  Interdiff is below.

Thank you!

--- drivers/net/niu.c~	2008-11-14 14:36:52.000000000 -0800
+++ drivers/net/niu.c	2008-11-14 14:40:33.000000000 -0800
@@ -446,12 +446,12 @@ static int serdes_init_niu_10g_fiber(str
 static int serdes_init_niu_1g_serdes(struct niu *np)
 {
 	struct niu_link_config *lp = &np->link_config;
-	u32 tx_cfg, rx_cfg;
 	u16 pll_cfg, pll_sts;
+	int max_retry = 100;
+	u64 sig, mask, val;
+	u32 tx_cfg, rx_cfg;
 	unsigned long i;
 	int err;
-	u64 sig, mask, val;
-	int max_retry = 100;
 
 	tx_cfg = (PLL_TX_CFG_ENTX | PLL_TX_CFG_SWING_1375MV |
 		  PLL_TX_CFG_RATE_HALF);
@@ -545,12 +545,11 @@ static int serdes_init_niu_1g_serdes(str
 static int serdes_init_niu_10g_serdes(struct niu *np)
 {
 	struct niu_link_config *lp = &np->link_config;
-	u32 tx_cfg, rx_cfg;
-	u32 pll_cfg, pll_sts;
+	u32 tx_cfg, rx_cfg, pll_cfg, pll_sts;
+	int max_retry = 100;
+	u64 sig, mask, val;
 	unsigned long i;
 	int err;
-	u64 sig, mask, val;
-	int max_retry = 100;
 
 	tx_cfg = (PLL_TX_CFG_ENTX | PLL_TX_CFG_SWING_1375MV);
 	rx_cfg = (PLL_RX_CFG_ENRX | PLL_RX_CFG_TERM_0P8VDDT |
@@ -643,7 +642,6 @@ static int serdes_init_niu_10g_serdes(st
 	}
 
 	if ((sig & mask) != val) {
-
 		pr_info(PFX "NIU Port %u signal bits [%08x] are not "
 			"[%08x] for 10G...trying 1G\n",
 			np->port, (int) (sig & mask), (int) val);
@@ -2428,11 +2426,11 @@ static int niu_determine_phy_disposition
 		case NIU_FLAGS_10G | NIU_FLAGS_XCVR_SERDES:
 			/* 10G Serdes */
 			tp = &phy_template_niu_10g_serdes;
-		      break;
+			break;
 		case NIU_FLAGS_XCVR_SERDES:
 			/* 1G Serdes */
 			tp = &phy_template_niu_1g_serdes;
-		      break;
+			break;
 		case NIU_FLAGS_10G | NIU_FLAGS_FIBER:
 			/* 10G Fiber */
 		default:
