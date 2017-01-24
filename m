From: Stephen Boyd <stephen.boyd@linaro.org>
Subject: [PATCH] net: ks8851: Drop eeprom_size structure member
Date: Mon, 23 Jan 2017 17:49:20 -0800
Message-ID: <20170124014920.644-1-stephen.boyd@linaro.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After commit 51b7b1c34e19 (KSZ8851-SNL: Add ethtool support for
EEPROM via eeprom_93cx6, 2011-11-21) this structure member is
unused. Delete it.

Signed-off-by: Stephen Boyd <stephen.boyd@linaro.org>
---

Found while debugging an eeprom issue.

 drivers/net/ethernet/micrel/ks8851.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index e7e1aff40bd9..955d69a8e8d3 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -84,7 +84,6 @@ union ks8851_tx_hdr {
  * @rc_ier: Cached copy of KS_IER.
  * @rc_ccr: Cached copy of KS_CCR.
  * @rc_rxqcr: Cached copy of KS_RXQCR.
- * @eeprom_size: Companion eeprom size in Bytes, 0 if no eeprom
  * @eeprom: 93CX6 EEPROM state for accessing on-board EEPROM.
  * @vdd_reg:	Optional regulator supplying the chip
  * @vdd_io: Optional digital power supply for IO
@@ -120,7 +119,6 @@ struct ks8851_net {
 	u16			rc_ier;
 	u16			rc_rxqcr;
 	u16			rc_ccr;
-	u16			eeprom_size;
 
 	struct mii_if_info	mii;
 	struct ks8851_rxctrl	rxctrl;
@@ -1533,11 +1531,6 @@ static int ks8851_probe(struct spi_device *spi)
 	/* cache the contents of the CCR register for EEPROM, etc. */
 	ks->rc_ccr = ks8851_rdreg16(ks, KS_CCR);
 
-	if (ks->rc_ccr & CCR_EEPROM)
-		ks->eeprom_size = 128;
-	else
-		ks->eeprom_size = 0;
-
 	ks8851_read_selftest(ks);
 	ks8851_init_mac(ks);
 
-- 
2.10.0.297.gf6727b0
