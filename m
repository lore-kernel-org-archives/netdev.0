From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH] mrf24j40: Fix en error handling path in 'mrf24j40_probe()'
Date: Sat,  8 Jul 2017 09:57:10 +0200
Message-ID: <20170708075710.18478-1-christophe.jaillet@wanadoo.fr>
Cc: linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: alan@signal11.us, alex.aring@gmail.com, stefan@osg.samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If this check fails, we must release some resources as done everywhere
else in this function before returning an error code.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
 drivers/net/ieee802154/mrf24j40.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
index 7d334963dc08..da8683782ffc 100644
--- a/drivers/net/ieee802154/mrf24j40.c
+++ b/drivers/net/ieee802154/mrf24j40.c
@@ -1330,7 +1330,7 @@ static int mrf24j40_probe(struct spi_device *spi)
 	if (spi->max_speed_hz > MAX_SPI_SPEED_HZ) {
 		dev_warn(&spi->dev, "spi clock above possible maximum: %d",
 			 MAX_SPI_SPEED_HZ);
-		return -EINVAL;
+		goto err_register_device;
 	}
 
 	ret = mrf24j40_hw_init(devrec);
-- 
2.11.0
