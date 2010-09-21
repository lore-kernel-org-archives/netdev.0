From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: [PATCHv1.5 3/3] net: core: use kernel's converter from hex to bin
Date: Tue, 21 Sep 2010 09:40:26 +0300
Message-ID: <3998a210e172f58814e2b559f67d42c9ba78ba6a.1285051188.git.andy.shevchenko@gmail.com>
References: <2d00b66224535ae82be1a1e638b86b81fb890f58.1285051188.git.andy.shevchenko@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andy Shevchenko <andy.shevchenko@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:47899 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753274Ab0IUGkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 02:40:46 -0400
In-Reply-To: <2d00b66224535ae82be1a1e638b86b81fb890f58.1285051188.git.andy.shevchenko@gmail.com>
In-Reply-To: <2d00b66224535ae82be1a1e638b86b81fb890f58.1285051188.git.andy.shevchenko@gmail.com>
References: <2d00b66224535ae82be1a1e638b86b81fb890f58.1285051188.git.andy.shevchenko@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>
---
 net/core/pktgen.c |   10 ++++------
 net/core/utils.c  |   13 +++++++------
 2 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 386c228..2c0df0f 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -729,16 +729,14 @@ static int hex32_arg(const char __user *user_buffer, unsigned long maxlen,
 	*num = 0;
 
 	for (; i < maxlen; i++) {
+		int value;
 		char c;
 		*num <<= 4;
 		if (get_user(c, &user_buffer[i]))
 			return -EFAULT;
-		if ((c >= '0') && (c <= '9'))
-			*num |= c - '0';
-		else if ((c >= 'a') && (c <= 'f'))
-			*num |= c - 'a' + 10;
-		else if ((c >= 'A') && (c <= 'F'))
-			*num |= c - 'A' + 10;
+		value = hex_to_bin(c);
+		if (value >= 0)
+			*num |= value;
 		else
 			break;
 	}
diff --git a/net/core/utils.c b/net/core/utils.c
index f418544..ec6bb32 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -92,18 +92,19 @@ EXPORT_SYMBOL(in_aton);
 
 static inline int xdigit2bin(char c, int delim)
 {
+	int val;
+
 	if (c == delim || c == '\0')
 		return IN6PTON_DELIM;
 	if (c == ':')
 		return IN6PTON_COLON_MASK;
 	if (c == '.')
 		return IN6PTON_DOT;
-	if (c >= '0' && c <= '9')
-		return (IN6PTON_XDIGIT | IN6PTON_DIGIT| (c - '0'));
-	if (c >= 'a' && c <= 'f')
-		return (IN6PTON_XDIGIT | (c - 'a' + 10));
-	if (c >= 'A' && c <= 'F')
-		return (IN6PTON_XDIGIT | (c - 'A' + 10));
+
+	val = hex_to_bin(c);
+	if (val >= 0)
+		return val | IN6PTON_XDIGIT | (val < 10 ? IN6PTON_DIGIT : 0);
+
 	if (delim == -1)
 		return IN6PTON_DELIM;
 	return IN6PTON_UNKNOWN;
-- 
1.7.2.2

