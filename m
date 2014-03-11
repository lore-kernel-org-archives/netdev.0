From: Thomas Stilwell <stilwellt-OAZXG8/CaxzQFizaE/u3fw@public.gmane.org>
Subject: [PATCH net-next] ieee802154: at86rf230: add
	support for rf233 chip
Date: Mon, 10 Mar 2014 19:29:25 -0500
Message-ID: <1394497765-5288-1-git-send-email-stilwellt@openlabs.co>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

The rf233 and rf231 are sufficiently similar that we can treat
rf233 like rf231.

rf233 is missing some features that rf231 has, but we don't currently
make use of them so there's nothing to handle differently yet.

Should we add support in the future for rf231 *_NOCLK or SLEEP states,
or PAD_IO drive strength, exceptions will need to be made for rf233.

Signed-off-by: Thomas Stilwell <stilwellt-OAZXG8/CaxzQFizaE/u3fw@public.gmane.org>
---
 drivers/net/ieee802154/Kconfig     |    4 ++--
 drivers/net/ieee802154/at86rf230.c |    5 +++++
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ieee802154/Kconfig b/drivers/net/ieee802154/Kconfig
index 9aa06ec..3e89bea 100644
--- a/drivers/net/ieee802154/Kconfig
+++ b/drivers/net/ieee802154/Kconfig
@@ -32,10 +32,10 @@ config IEEE802154_FAKELB
 
 config IEEE802154_AT86RF230
 	depends on IEEE802154_DRIVERS && MAC802154
-	tristate "AT86RF230/231/212 transceiver driver"
+	tristate "AT86RF230/231/233/212 transceiver driver"
 	depends on SPI
 	---help---
-	  Say Y here to enable the at86rf230/231/212 SPI 802.15.4 wireless
+	  Say Y here to enable the at86rf230/231/233/212 SPI 802.15.4 wireless
 	  controller.
 
 	  This driver can also be built as a module. To do so, say M here.
diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 03e24c5..b8e7321 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -244,6 +244,7 @@ static bool is_rf212(struct at86rf230_local *local)
 #define STATE_TX_ON		0x09
 /* 0x0a - 0x0e */			/* 0x0a - UNSUPPORTED_ATTRIBUTE */
 #define STATE_SLEEP		0x0F
+#define STATE_PREP_DEEP_SLEEP	0x10
 #define STATE_BUSY_RX_AACK	0x11
 #define STATE_BUSY_TX_ARET	0x12
 #define STATE_RX_AACK_ON	0x16
@@ -1108,6 +1109,10 @@ static int at86rf230_probe(struct spi_device *spi)
 		if (version == 1)
 			ops = &at86rf212_ops;
 		break;
+	case 11:
+		chip = "at86rf233";
+		ops = &at86rf230_ops;
+		break;
 	default:
 		chip = "UNKNOWN";
 		break;
-- 
1.7.10.4


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
