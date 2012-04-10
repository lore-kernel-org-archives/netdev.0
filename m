From: Lars-Peter Clausen <lars@metafoo.de>
Subject: [PATCH 4/4] net: Remove redundant spi driver bus initialization
Date: Tue, 10 Apr 2012 22:51:29 +0200
Message-ID: <1334091089-10138-4-git-send-email-lars@metafoo.de>
References: <1334091089-10138-1-git-send-email-lars@metafoo.de>
Cc: Lars-Peter Clausen <lars@metafoo.de>,
	"David S. Miller" <davem@davemloft.net>,
	Gabor Juhos <juhosg@openwrt.org>,
	Frederic Lambert <frdrc66@gmail.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334091089-10138-1-git-send-email-lars@metafoo.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In ancient times it was necessary to manually initialize the bus field of an
spi_driver to spi_bus_type. These days this is done in spi_driver_register() so
we can drop the manual assignment.

The patch was generated using the following coccinelle semantic patch:
// <smpl>
@@
identifier _driver;
@@
struct spi_driver _driver = {
	.driver = {
-		.bus = &spi_bus_type,
	},
};
// </smpl>

Signed-off-by: Lars-Peter Clausen <lars@metafoo.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Gabor Juhos <juhosg@openwrt.org>
Cc: Frederic Lambert <frdrc66@gmail.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/phy/spi_ks8995.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks8995.c
index 116a2dd..4eb98bc 100644
--- a/drivers/net/phy/spi_ks8995.c
+++ b/drivers/net/phy/spi_ks8995.c
@@ -348,7 +348,6 @@ static int __devexit ks8995_remove(struct spi_device *spi)
 static struct spi_driver ks8995_driver = {
 	.driver = {
 		.name	    = "spi-ks8995",
-		.bus	     = &spi_bus_type,
 		.owner	   = THIS_MODULE,
 	},
 	.probe	  = ks8995_probe,
-- 
1.7.9.5
