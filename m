From: Stas Sergeev <stsp@list.ru>
Subject: [PATCH 1/2] mvneta: consolidate autoneg enabling
Date: Wed, 2 Dec 2015 20:33:56 +0300
Message-ID: <565F2B84.8050808@list.ru>
References: <565F2B28.4080501@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <565F2B28.4080501@list.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This moves autoneg-related bit manipulations to the single place.

CC: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
CC: netdev@vger.kernel.org
CC: linux-kernel@vger.kernel.org

Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>
---
 drivers/net/ethernet/marvell/mvneta.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index e84c7f2..8e0e6de 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1065,15 +1065,28 @@ static void mvneta_defaults_set(struct mvneta_port *pp)
 		       MVNETA_GMAC_AN_SPEED_EN |
 		       MVNETA_GMAC_AN_DUPLEX_EN;
 		mvreg_write(pp, MVNETA_GMAC_AUTONEG_CONFIG, val);
+
 		val = mvreg_read(pp, MVNETA_GMAC_CLOCK_DIVIDER);
 		val |= MVNETA_GMAC_1MS_CLOCK_ENABLE;
 		mvreg_write(pp, MVNETA_GMAC_CLOCK_DIVIDER, val);
+
+		val = mvreg_read(pp, MVNETA_GMAC_CTRL_2);
+		val |= MVNETA_GMAC2_INBAND_AN_ENABLE;
+		mvreg_write(pp, MVNETA_GMAC_CTRL_2, val);
 	} else {
 		val = mvreg_read(pp, MVNETA_GMAC_AUTONEG_CONFIG);
 		val &= ~(MVNETA_GMAC_INBAND_AN_ENABLE |
 		       MVNETA_GMAC_AN_SPEED_EN |
 		       MVNETA_GMAC_AN_DUPLEX_EN);
 		mvreg_write(pp, MVNETA_GMAC_AUTONEG_CONFIG, val);
+
+		val = mvreg_read(pp, MVNETA_GMAC_CLOCK_DIVIDER);
+		val &= ~MVNETA_GMAC_1MS_CLOCK_ENABLE;
+		mvreg_write(pp, MVNETA_GMAC_CLOCK_DIVIDER, val);
+
+		val = mvreg_read(pp, MVNETA_GMAC_CTRL_2);
+		val &= ~MVNETA_GMAC2_INBAND_AN_ENABLE;
+		mvreg_write(pp, MVNETA_GMAC_CTRL_2, val);
 	}

 	mvneta_set_ucast_table(pp, -1);
@@ -3223,9 +3236,6 @@ static int mvneta_port_power_up(struct mvneta_port *pp, int phy_mode)
 		return -EINVAL;
 	}

-	if (pp->use_inband_status)
-		ctrl |= MVNETA_GMAC2_INBAND_AN_ENABLE;
-
 	/* Cancel Port Reset */
 	ctrl &= ~MVNETA_GMAC2_PORT_RESET;
 	mvreg_write(pp, MVNETA_GMAC_CTRL_2, ctrl);
-- 
2.4.3
