From: varkabhadram@gmail.com
Subject: [PATCH net-next 8/8] ethernet: amd: switch case fixes
Date: Fri, 11 Jul 2014 13:05:10 +0530
Message-ID: <1405064110-22579-9-git-send-email-varkabhadram@gmail.com>
References: <1405064110-22579-1-git-send-email-varkabhadram@gmail.com>
Cc: Thomas.Lendacky@amd.com, geert+renesas@linux-m68k.org,
	ebiederm@xmission.com, macro@linux-mips.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:42204 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752961AbaGKHhB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 03:37:01 -0400
In-Reply-To: <1405064110-22579-1-git-send-email-varkabhadram@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Varka Bhadram <varkab@cdac.in>

This patch fix the *swith* case indentation and usage issues

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/amd/amd8111e.c |  117 +++++++++++++++++------------------
 1 file changed, 58 insertions(+), 59 deletions(-)

diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index f0d3809..ab2e09b9 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -197,23 +197,24 @@ static void amd8111e_set_ext_phy(struct net_device *dev)
 	advert = amd8111e_mdio_read(dev, lp->ext_phy_addr, MII_ADVERTISE);
 	tmp = advert & ~(ADVERTISE_ALL | ADVERTISE_100BASE4);
 	switch (lp->ext_phy_option) {
-		default:
-		case SPEED_AUTONEG: /* advertise all values */
-			tmp |= (ADVERTISE_10HALF | ADVERTISE_10FULL |
-				ADVERTISE_100HALF | ADVERTISE_100FULL);
-			break;
-		case SPEED10_HALF:
-			tmp |= ADVERTISE_10HALF;
-			break;
-		case SPEED10_FULL:
-			tmp |= ADVERTISE_10FULL;
-			break;
-		case SPEED100_HALF:
-			tmp |= ADVERTISE_100HALF;
-			break;
-		case SPEED100_FULL:
-			tmp |= ADVERTISE_100FULL;
-			break;
+	case SPEED_AUTONEG: /* advertise all values */
+		tmp |= (ADVERTISE_10HALF | ADVERTISE_10FULL |
+			ADVERTISE_100HALF | ADVERTISE_100FULL);
+		break;
+	case SPEED10_HALF:
+		tmp |= ADVERTISE_10HALF;
+		break;
+	case SPEED10_FULL:
+		tmp |= ADVERTISE_10FULL;
+		break;
+	case SPEED100_HALF:
+		tmp |= ADVERTISE_100HALF;
+		break;
+	case SPEED100_FULL:
+		tmp |= ADVERTISE_100FULL;
+		break;
+	default:
+		break;
 	}
 
 	if (advert != tmp)
@@ -383,49 +384,47 @@ static int amd8111e_set_coalesce(struct net_device *dev, enum coal_mode cmod)
 	void __iomem *mmio = lp->mmio;
 	struct amd8111e_coalesce_conf *coal_conf = &lp->coal_conf;
 
+	switch (cmod) {
+	case RX_INTR_COAL:
+		timeout = coal_conf->rx_timeout;
+		event_count = coal_conf->rx_event_count;
+		if (timeout > MAX_TIMEOUT ||
+		    event_count > MAX_EVENT_COUNT)
+			return -EINVAL;
+
+		timeout = timeout * DELAY_TIMER_CONV;
+		writel(VAL0 | STINTEN, mmio + INTEN0);
+		writel((u32)DLY_INT_A_R0 | (event_count << 16) |
+		       timeout, mmio+DLY_INT_A);
+		break;
 
-	switch (cmod)
-	{
-		case RX_INTR_COAL:
-			timeout = coal_conf->rx_timeout;
-			event_count = coal_conf->rx_event_count;
-			if (timeout > MAX_TIMEOUT ||
-			    event_count > MAX_EVENT_COUNT)
-				return -EINVAL;
-
-			timeout = timeout * DELAY_TIMER_CONV;
-			writel(VAL0 | STINTEN, mmio + INTEN0);
-			writel((u32)DLY_INT_A_R0 | (event_count << 16) |
-			       timeout, mmio+DLY_INT_A);
-			break;
-
-		case TX_INTR_COAL:
-			timeout = coal_conf->tx_timeout;
-			event_count = coal_conf->tx_event_count;
-			if (timeout > MAX_TIMEOUT ||
-			    event_count > MAX_EVENT_COUNT)
-				return -EINVAL;
-
-
-			timeout = timeout * DELAY_TIMER_CONV;
-			writel(VAL0 | STINTEN, mmio + INTEN0);
-			writel((u32)DLY_INT_B_T0 | (event_count << 16) |
-			       timeout, mmio + DLY_INT_B);
-			break;
-
-		case DISABLE_COAL:
-			writel(0, mmio + STVAL);
-			writel(STINTEN, mmio + INTEN0);
-			writel(0, mmio + DLY_INT_B);
-			writel(0, mmio + DLY_INT_A);
-			break;
-		 case ENABLE_COAL:
-		       /* Start the timer (0.5 sec) */
-			writel((u32)SOFT_TIMER_FREQ, mmio + STVAL);
-			writel(VAL0 | STINTEN, mmio + INTEN0);
-			break;
-		default:
-			break;
+	case TX_INTR_COAL:
+		timeout = coal_conf->tx_timeout;
+		event_count = coal_conf->tx_event_count;
+		if (timeout > MAX_TIMEOUT ||
+		    event_count > MAX_EVENT_COUNT)
+			return -EINVAL;
+
+		timeout = timeout * DELAY_TIMER_CONV;
+		writel(VAL0 | STINTEN, mmio + INTEN0);
+		writel((u32)DLY_INT_B_T0 | (event_count << 16) |
+		       timeout, mmio + DLY_INT_B);
+		break;
+
+	case DISABLE_COAL:
+		writel(0, mmio + STVAL);
+		writel(STINTEN, mmio + INTEN0);
+		writel(0, mmio + DLY_INT_B);
+		writel(0, mmio + DLY_INT_A);
+		break;
+
+	case ENABLE_COAL:
+		/* Start the timer (0.5 sec) */
+		writel((u32)SOFT_TIMER_FREQ, mmio + STVAL);
+		writel(VAL0 | STINTEN, mmio + INTEN0);
+		break;
+	default:
+		break;
 	}
 
 	return 0;
-- 
1.7.9.5
