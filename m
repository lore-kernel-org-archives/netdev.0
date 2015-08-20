From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 07/18] net: ks8851: Export OF module alias information
Date: Thu, 20 Aug 2015 09:07:20 +0200
Message-ID: <1440054451-1223-8-git-send-email-javier@osg.samsung.com>
References: <1440054451-1223-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440054451-1223-1-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The SPI core always reports the MODALIAS uevent as "spi:<modalias>"
regardless of the mechanism that was used to register the device
(i.e: OF or board code) and the table that is used later to match
the driver with the device (i.e: SPI id table or OF match table).

So drivers needs to export the SPI id table and this be built into
the module or udev won't have the necessary information to autoload
the needed driver module when the device is added.

But this means that OF-only drivers needs to have both OF and SPI id
tables that have to be kept in sync and also the dev node compatible
manufacturer prefix is stripped when reporting the MODALIAS. Which can
lead to issues if two vendors use the same SPI device name for example.

To avoid the above, the SPI core behavior may be changed in the future
to not require an SPI device table for OF-only drivers and report the
OF module alias. So, it's better to also export the OF table even when
is unused now to prevent breaking module loading when the core changes.

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 drivers/net/ethernet/micrel/ks8851.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index 66d4ab703f45..60f43ec22175 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -1601,6 +1601,7 @@ static const struct of_device_id ks8851_match_table[] = {
 	{ .compatible = "micrel,ks8851" },
 	{ }
 };
+MODULE_DEVICE_TABLE(of, ks8851_match_table);
 
 static struct spi_driver ks8851_driver = {
 	.driver = {
-- 
2.4.3
