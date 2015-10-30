From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 1/2] net: encx24j600: Fix SPI id table definition
Date: Fri, 30 Oct 2015 13:49:17 +0100
Message-ID: <1446209358-26094-2-git-send-email-javier@osg.samsung.com>
References: <1446209358-26094-1-git-send-email-javier@osg.samsung.com>
Cc: netdev@vger.kernel.org, Jon Ringle <jringle@gridpoint.com>,
	davem@davemloft.net,
	Javier Martinez Canillas <javier@osg.samsung.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446209358-26094-1-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A driver's SPI id table is expected to be an array of struct spi_device_id
that ends with a zero-initialized sentinel entry. But this driver defines
the table as a single struct spi_device_id and sets .id_table to a pointer
to this struct.

But spi_match_id() has a loop that iterates while the struct spi_device_id
.name[0] is not NULL, so not having a sentinel can cause a NULL pointer
deference error.

This patch defines the SPI id table correctly as all other SPI drivers do.

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 drivers/net/ethernet/microchip/encx24j600.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/microchip/encx24j600.c b/drivers/net/ethernet/microchip/encx24j600.c
index bf08ce2baf8d..c2dafc1c53de 100644
--- a/drivers/net/ethernet/microchip/encx24j600.c
+++ b/drivers/net/ethernet/microchip/encx24j600.c
@@ -1094,8 +1094,9 @@ static int encx24j600_spi_remove(struct spi_device *spi)
 	return 0;
 }
 
-static const struct spi_device_id encx24j600_spi_id_table = {
-	.name = "encx24j600"
+static const struct spi_device_id encx24j600_spi_id_table[] = {
+	{ .name = "encx24j600" },
+	{ /* sentinel */ }
 };
 
 static struct spi_driver encx24j600_spi_net_driver = {
@@ -1106,7 +1107,7 @@ static struct spi_driver encx24j600_spi_net_driver = {
 	},
 	.probe		= encx24j600_spi_probe,
 	.remove		= encx24j600_spi_remove,
-	.id_table	= &encx24j600_spi_id_table,
+	.id_table	= encx24j600_spi_id_table,
 };
 
 static int __init encx24j600_init(void)
-- 
2.4.3
