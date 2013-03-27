From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH 2/2] ppp: reuse print_hex_dump_bytes
Date: Wed, 27 Mar 2013 17:54:14 +0200
Message-ID: <1364399654-9729-2-git-send-email-andriy.shevchenko@linux.intel.com>
References: <1364399654-9729-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Paul Mackerras <paulus@samba.org>,
	"David S. Miller" <davem@davemloft.net>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:32107 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751475Ab3C0Pye (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 11:54:34 -0400
In-Reply-To: <1364399654-9729-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a native function to dump hex buffers.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ppp/ppp_synctty.c | 53 ++-----------------------------------------
 1 file changed, 2 insertions(+), 51 deletions(-)

diff --git a/drivers/net/ppp/ppp_synctty.c b/drivers/net/ppp/ppp_synctty.c
index bdf3b13..925d3e2 100644
--- a/drivers/net/ppp/ppp_synctty.c
+++ b/drivers/net/ppp/ppp_synctty.c
@@ -105,64 +105,15 @@ static const struct ppp_channel_ops sync_ops = {
 };
 
 /*
- * Utility procedures to print a buffer in hex/ascii
+ * Utility procedure to print a buffer in hex/ascii
  */
 static void
-ppp_print_hex (register __u8 * out, const __u8 * in, int count)
-{
-	register __u8 next_ch;
-	static const char hex[] = "0123456789ABCDEF";
-
-	while (count-- > 0) {
-		next_ch = *in++;
-		*out++ = hex[(next_ch >> 4) & 0x0F];
-		*out++ = hex[next_ch & 0x0F];
-		++out;
-	}
-}
-
-static void
-ppp_print_char (register __u8 * out, const __u8 * in, int count)
-{
-	register __u8 next_ch;
-
-	while (count-- > 0) {
-		next_ch = *in++;
-
-		if (next_ch < 0x20 || next_ch > 0x7e)
-			*out++ = '.';
-		else {
-			*out++ = next_ch;
-			if (next_ch == '%')   /* printk/syslogd has a bug !! */
-				*out++ = '%';
-		}
-	}
-	*out = '\0';
-}
-
-static void
 ppp_print_buffer (const char *name, const __u8 *buf, int count)
 {
-	__u8 line[44];
-
 	if (name != NULL)
 		printk(KERN_DEBUG "ppp_synctty: %s, count = %d\n", name, count);
 
-	while (count > 8) {
-		memset (line, 32, 44);
-		ppp_print_hex (line, buf, 8);
-		ppp_print_char (&line[8 * 3], buf, 8);
-		printk(KERN_DEBUG "%s\n", line);
-		count -= 8;
-		buf += 8;
-	}
-
-	if (count > 0) {
-		memset (line, 32, 44);
-		ppp_print_hex (line, buf, count);
-		ppp_print_char (&line[8 * 3], buf, count);
-		printk(KERN_DEBUG "%s\n", line);
-	}
+	print_hex_dump_bytes("", DUMP_PREFIX_NONE, buf, count);
 }
 
 
-- 
1.8.2.rc0.22.gb3600c3
