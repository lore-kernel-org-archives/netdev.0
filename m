From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: [PATCH] drivers: isdn: capi: use simple_strtol to convert numbers
Date: Tue,  7 Sep 2010 18:14:30 +0300
Message-ID: <1283872470-22800-1-git-send-email-andy.shevchenko@gmail.com>
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>,
	Karsten Keil <isdn@linux-pingi.de>,
	Tilman Schmidt <tilman@imap.cc>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:64607 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757186Ab0IGPOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 11:14:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: Tilman Schmidt <tilman@imap.cc>
Cc: netdev@vger.kernel.org
---
 drivers/isdn/capi/capidrv.c |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/isdn/capi/capidrv.c b/drivers/isdn/capi/capidrv.c
index 2978bda..e54e79d4 100644
--- a/drivers/isdn/capi/capidrv.c
+++ b/drivers/isdn/capi/capidrv.c
@@ -1515,8 +1515,13 @@ static int decodeFVteln(char *teln, unsigned long *bmaskp, int *activep)
 	while (*s) {
 		int digit1 = 0;
 		int digit2 = 0;
-		if (!isdigit(*s)) return -3;
-		while (isdigit(*s)) { digit1 = digit1*10 + (*s - '0'); s++; }
+		char *endp;
+
+		digit1 = simple_strtoul(s, &endp, 10);
+		if (s == endp)
+			return -3;
+		s = endp;
+
 		if (digit1 <= 0 || digit1 > 30) return -4;
 		if (*s == 0 || *s == ',' || *s == ' ') {
 			bmask |= (1 << digit1);
@@ -1526,8 +1531,12 @@ static int decodeFVteln(char *teln, unsigned long *bmaskp, int *activep)
 		}
 		if (*s != '-') return -5;
 		s++;
-		if (!isdigit(*s)) return -3;
-		while (isdigit(*s)) { digit2 = digit2*10 + (*s - '0'); s++; }
+
+		digit2 = simple_strtoul(s, &endp, 10);
+		if (s == endp)
+			return -3;
+		s = endp;
+
 		if (digit2 <= 0 || digit2 > 30) return -4;
 		if (*s == 0 || *s == ',' || *s == ' ') {
 			if (digit1 > digit2)
-- 
1.7.2.2

