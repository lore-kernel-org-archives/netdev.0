From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: ieee802154: fix potential null pointer dereference
Date: Tue, 23 May 2017 13:11:47 -0500
Message-ID: <20170523181147.GA32714@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Harry Morris <h.morris@cascoda.com>, linuxdev@cascoda.com,
        Alexander Aring <aar@pengutronix.de>,
        Stefan Schmidt <stefan@osg.samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Null check at line 918: if (!spi) {, implies spi might be NULL.
Function spi_get_drvdata() dereference pointer spi.
Move pointer priv assignment after the null check.

Addresses-Coverity-ID: 1408888
Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 drivers/net/ieee802154/ca8210.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ieee802154/ca8210.c b/drivers/net/ieee802154/ca8210.c
index 25fd3b0..ccaf20d 100644
--- a/drivers/net/ieee802154/ca8210.c
+++ b/drivers/net/ieee802154/ca8210.c
@@ -912,7 +912,7 @@ static int ca8210_spi_transfer(
 )
 {
 	int i, status = 0;
-	struct ca8210_priv *priv = spi_get_drvdata(spi);
+	struct ca8210_priv *priv;
 	struct cas_control *cas_ctl;
 
 	if (!spi) {
@@ -923,6 +923,7 @@ static int ca8210_spi_transfer(
 		return -ENODEV;
 	}
 
+	priv = spi_get_drvdata(spi);
 	reinit_completion(&priv->spi_transfer_complete);
 
 	dev_dbg(&spi->dev, "ca8210_spi_transfer called\n");
-- 
2.5.0
