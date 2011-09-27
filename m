From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCHv2.1] wireless: at76c50x: use native hex_pack_byte() method
Date: Tue, 27 Sep 2011 15:01:49 +0300
Message-ID: <3feae30d537a79c064495cc834f585192a1e636d.1317124866.git.andriy.shevchenko@linux.intel.com>
References: <71d8213731be21f26a82255a4fffdbe1b6dd4a44.1316774801.git.andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:33110 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752184Ab1I0MCU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Sep 2011 08:02:20 -0400
In-Reply-To: <71d8213731be21f26a82255a4fffdbe1b6dd4a44.1316774801.git.andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: "John W. Linville" <linville@tuxdriver.com>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 drivers/net/wireless/at76c50x-usb.c |   18 +++++++-----------
 1 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/drivers/net/wireless/at76c50x-usb.c b/drivers/net/wireless/at76c50x-usb.c
index 2986014..2dde5f6 100644
--- a/drivers/net/wireless/at76c50x-usb.c
+++ b/drivers/net/wireless/at76c50x-usb.c
@@ -500,10 +500,9 @@ exit:
 
 #define HEX2STR_BUFFERS 4
 #define HEX2STR_MAX_LEN 64
-#define BIN2HEX(x) ((x) < 10 ? '0' + (x) : (x) + 'A' - 10)
 
 /* Convert binary data into hex string */
-static char *hex2str(void *buf, int len)
+static char *hex2str(void *buf, size_t len)
 {
 	static atomic_t a = ATOMIC_INIT(0);
 	static char bufs[HEX2STR_BUFFERS][3 * HEX2STR_MAX_LEN + 1];
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
