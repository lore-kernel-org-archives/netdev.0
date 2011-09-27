From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCHv2] wireless: at76c50x: use native hex_pack_byte() method
Date: Tue, 27 Sep 2011 14:51:02 +0300
Message-ID: <a1f4782ddfc14a689a056a911f1efac6e9e9a6da.1317124055.git.andriy.shevchenko@linux.intel.com>
References: <71d8213731be21f26a82255a4fffdbe1b6dd4a44.1316774801.git.andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <71d8213731be21f26a82255a4fffdbe1b6dd4a44.1316774801.git.andriy.shevchenko@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: "John W. Linville" <linville@tuxdriver.com>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 drivers/net/wireless/at76c50x-usb.c |   16 ++++++----------
 1 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/at76c50x-usb.c b/drivers/net/wireless/at76c50x-usb.c
index 2986014..96daaad 100644
--- a/drivers/net/wireless/at76c50x-usb.c
+++ b/drivers/net/wireless/at76c50x-usb.c
@@ -500,7 +500,6 @@ exit:
 
 #define HEX2STR_BUFFERS 4
 #define HEX2STR_MAX_LEN 64
-#define BIN2HEX(x) ((x) < 10 ? '0' + (x) : (x) + 'A' - 10)
 
 /* Convert binary data into hex string */
 static char *hex2str(void *buf, int len)
@@ -514,18 +513,15 @@ static char *hex2str(void *buf, int len)
 	if (len > HEX2STR_MAX_LEN)
 		len = HEX2STR_MAX_LEN;
 
-	if (len <= 0) {
-		ret[0] = '\0';
-		return ret;
-	}
-
 	while (len--) {
-		*obuf++ = BIN2HEX(*ibuf >> 4);
-		*obuf++ = BIN2HEX(*ibuf & 0xf);
+		obuf = pack_hex_byte(obuf, *ibuf++);
 		*obuf++ = '-';
-		ibuf++;
 	}
-	*(--obuf) = '\0';
+
+	if (*obuf == '-')
+		obuf--;
+
+	*obuf = '\0';
 
 	return ret;
 }
-- 
1.7.6.3
