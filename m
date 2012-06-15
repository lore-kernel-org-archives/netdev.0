From: Joe Perches <joe@perches.com>
Subject: [PATCH wireless-next 14/20] p54: Use pr_<level>
Date: Thu, 14 Jun 2012 22:53:54 -0700
Message-ID: <388e95fcf40ae223fb9227166800f7cc733eaa5e.1339739416.git.joe@perches.com>
References: <cover.1339739415.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1339739415.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use a more current logging style.

Convert printks to pr_<level>.
Coalesce formats, align arguments.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/p54/fwio.c   |    6 ++++--
 drivers/net/wireless/p54/p54spi.c |    4 +++-
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/p54/fwio.c b/drivers/net/wireless/p54/fwio.c
index 18e82b3..ea64d5d 100644
--- a/drivers/net/wireless/p54/fwio.c
+++ b/drivers/net/wireless/p54/fwio.c
@@ -16,6 +16,8 @@
  * published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/firmware.h>
@@ -100,8 +102,8 @@ int p54_parse_firmware(struct ieee80211_hw *dev, const struct firmware *fw)
 				 4 + /* rx alignment */
 				 IEEE80211_MAX_FRAG_THRESHOLD;
 			if (priv->rx_mtu > maxlen && PAGE_SIZE == 4096) {
-				printk(KERN_INFO "p54: rx_mtu reduced from %d "
-				       "to %d\n", priv->rx_mtu, maxlen);
+				pr_info("rx_mtu reduced from %d to %d\n",
+					priv->rx_mtu, maxlen);
 				priv->rx_mtu = maxlen;
 			}
 			break;
diff --git a/drivers/net/wireless/p54/p54spi.c b/drivers/net/wireless/p54/p54spi.c
index f792990..8bf4a01 100644
--- a/drivers/net/wireless/p54/p54spi.c
+++ b/drivers/net/wireless/p54/p54spi.c
@@ -20,6 +20,8 @@
  * 02110-1301 USA
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/platform_device.h>
 #include <linux/interrupt.h>
@@ -719,7 +721,7 @@ static int __init p54spi_init(void)
 
 	ret = spi_register_driver(&p54spi_driver);
 	if (ret < 0) {
-		printk(KERN_ERR "failed to register SPI driver: %d", ret);
+		pr_err("failed to register SPI driver: %d\n", ret);
 		goto out;
 	}
 
-- 
1.7.8.111.gad25c.dirty
