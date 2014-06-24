From: Joe Perches <joe@perches.com>
Subject: [trivial PATCH net-next] mac_pton: Use bool not int return
Date: Tue, 24 Jun 2014 11:20:48 -0700
Message-ID: <1403634048.29061.23.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use bool instead of int as the return type.

All uses are tested with !.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/kernel.h |  2 +-
 lib/net_utils.c        | 10 +++++-----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 44649e0..112a6f5 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -501,7 +501,7 @@ static inline char * __deprecated pack_hex_byte(char *buf, u8 byte)
 extern int hex_to_bin(char ch);
 extern int __must_check hex2bin(u8 *dst, const char *src, size_t count);
 
-int mac_pton(const char *s, u8 *mac);
+bool mac_pton(const char *s, u8 *mac);
 
 /*
  * General tracing related utility functions - trace_printk(),
diff --git a/lib/net_utils.c b/lib/net_utils.c
index 2e3c52c..148fc6e 100644
--- a/lib/net_utils.c
+++ b/lib/net_utils.c
@@ -3,24 +3,24 @@
 #include <linux/ctype.h>
 #include <linux/kernel.h>
 
-int mac_pton(const char *s, u8 *mac)
+bool mac_pton(const char *s, u8 *mac)
 {
 	int i;
 
 	/* XX:XX:XX:XX:XX:XX */
 	if (strlen(s) < 3 * ETH_ALEN - 1)
-		return 0;
+		return false;
 
 	/* Don't dirty result unless string is valid MAC. */
 	for (i = 0; i < ETH_ALEN; i++) {
 		if (!isxdigit(s[i * 3]) || !isxdigit(s[i * 3 + 1]))
-			return 0;
+			return false;
 		if (i != ETH_ALEN - 1 && s[i * 3 + 2] != ':')
-			return 0;
+			return false;
 	}
 	for (i = 0; i < ETH_ALEN; i++) {
 		mac[i] = (hex_to_bin(s[i * 3]) << 4) | hex_to_bin(s[i * 3 + 1]);
 	}
-	return 1;
+	return true;
 }
 EXPORT_SYMBOL(mac_pton);
