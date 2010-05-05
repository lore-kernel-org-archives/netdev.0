From: Sebastien Jan <s-jan@ti.com>
Subject: [PATCH 1/4 v2] ks8851: Add caching of CCR register
Date: Wed,  5 May 2010 20:45:52 +0200
Message-ID: <1273085155-1260-2-git-send-email-s-jan@ti.com>
References: <1273085155-1260-1-git-send-email-s-jan@ti.com>
Cc: linux-omap@vger.kernel.org, Abraham Arce <x0066660@ti.com>,
	Ben Dooks <ben-linux@fluff.org>, Tristram.Ha@micrel.com,
	Sebastien Jan <s-jan@ti.com>
To: netdev@vger.kernel.org
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1273085155-1260-1-git-send-email-s-jan@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CCR register contains information on companion eeprom availability.

Signed-off-by: Sebastien Jan <s-jan@ti.com>
---
 drivers/net/ks8851.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ks8851.c b/drivers/net/ks8851.c
index 9e9f9b3..a84e500 100644
--- a/drivers/net/ks8851.c
+++ b/drivers/net/ks8851.c
@@ -76,7 +76,9 @@ union ks8851_tx_hdr {
  * @msg_enable: The message flags controlling driver output (see ethtool).
  * @fid: Incrementing frame id tag.
  * @rc_ier: Cached copy of KS_IER.
+ * @rc_ccr: Cached copy of KS_CCR.
  * @rc_rxqcr: Cached copy of KS_RXQCR.
+ * @eeprom_size: Companion eeprom size in Bytes, 0 if no eeprom
  *
  * The @lock ensures that the chip is protected when certain operations are
  * in progress. When the read or write packet transfer is in progress, most
@@ -107,6 +109,8 @@ struct ks8851_net {
 
 	u16			rc_ier;
 	u16			rc_rxqcr;
+	u16			rc_ccr;
+	u16			eeprom_size;
 
 	struct mii_if_info	mii;
 	struct ks8851_rxctrl	rxctrl;
@@ -1279,6 +1283,14 @@ static int __devinit ks8851_probe(struct spi_device *spi)
 		goto err_id;
 	}
 
+	/* cache the contents of the CCR register for EEPROM, etc. */
+	ks->rc_ccr = ks8851_rdreg16(ks, KS_CCR);
+
+	if (ks->rc_ccr & CCR_EEPROM)
+		ks->eeprom_size = 128;
+	else
+		ks->eeprom_size = 0;
+
 	ks8851_read_selftest(ks);
 	ks8851_init_mac(ks);
 
-- 
1.6.3.3

