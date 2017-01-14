From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH resend iproute2 1/1] utils: make hex2mem available to all users
Date: Sat, 14 Jan 2017 17:10:06 -0500
Message-ID: <1484431806-31969-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36159 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750702AbdANWR6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2017 17:17:58 -0500
Received: by mail-it0-f67.google.com with SMTP id o138so8706448ito.3
        for <netdev@vger.kernel.org>; Sat, 14 Jan 2017 14:17:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

hex2mem() api is useful for parsing hexstrings which are then packed in
a stream of chars.

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/utils.h |  1 +
 ip/ipl2tp.c     | 25 -------------------------
 lib/utils.c     | 25 +++++++++++++++++++++++++
 3 files changed, 26 insertions(+), 25 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index dc1d6b9..22369e0 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -118,6 +118,7 @@ int get_be32(__be32 *val, const char *arg, int base);
 int get_be16(__be16 *val, const char *arg, int base);
 int get_addr64(__u64 *ap, const char *cp);
 
+int hex2mem(const char *buf, uint8_t *mem, int count);
 char *hexstring_n2a(const __u8 *str, int len, char *buf, int blen);
 __u8 *hexstring_a2n(const char *str, __u8 *buf, int blen, unsigned int *len);
 #define ADDR64_BUF_SIZE sizeof("xxxx:xxxx:xxxx:xxxx")
diff --git a/ip/ipl2tp.c b/ip/ipl2tp.c
index 0f91aeb..88664c9 100644
--- a/ip/ipl2tp.c
+++ b/ip/ipl2tp.c
@@ -485,31 +485,6 @@ static int get_tunnel(struct l2tp_data *p)
  * Command parser
  *****************************************************************************/
 
-static int hex2mem(const char *buf, uint8_t *mem, int count)
-{
-	int i, j;
-	int c;
-
-	for (i = 0, j = 0; i < count; i++, j += 2) {
-		c = get_hex(buf[j]);
-		if (c < 0)
-			goto err;
-
-		mem[i] = c << 4;
-
-		c = get_hex(buf[j + 1]);
-		if (c < 0)
-			goto err;
-
-		mem[i] |= c;
-	}
-
-	return 0;
-
-err:
-	return -1;
-}
-
 static void usage(void) __attribute__((noreturn));
 
 static void usage(void)
diff --git a/lib/utils.c b/lib/utils.c
index 83c9d09..870c4f1 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -962,6 +962,31 @@ __u8 *hexstring_a2n(const char *str, __u8 *buf, int blen, unsigned int *len)
 	return buf;
 }
 
+int hex2mem(const char *buf, uint8_t *mem, int count)
+{
+	int i, j;
+	int c;
+
+	for (i = 0, j = 0; i < count; i++, j += 2) {
+		c = get_hex(buf[j]);
+		if (c < 0)
+			goto err;
+
+		mem[i] = c << 4;
+
+		c = get_hex(buf[j + 1]);
+		if (c < 0)
+			goto err;
+
+		mem[i] |= c;
+	}
+
+	return 0;
+
+err:
+	return -1;
+}
+
 int addr64_n2a(__u64 addr, char *buff, size_t len)
 {
 	__u16 *words = (__u16 *)&addr;
-- 
1.9.1
