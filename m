From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 4/4] isdn: remove ishexdigit() in regard to isxdigit()
Date: Tue, 23 Feb 2010 00:10:22 +0100 (CET)
Message-ID: <20100221-patch-gigaset-04.tilman@imap.cc>
References: <20100221-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([195.227.45.7]:57838 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754365Ab0BVXLc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2010 18:11:32 -0500
In-Reply-To: <20100221-patch-gigaset-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <ext-andriy.shevchenko@nokia.com>
Subject: [PATCH 4/4] isdn: remove ishexdigit() in regard to isxdigit()

Samll cleanup in drivers/isdn/gigaset/capi.c where own implementation of
isxdigit() has been changed to kernel native one.

Signed-off-by: Andy Shevchenko <ext-andriy.shevchenko@nokia.com>
Acked-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/capi.c |   16 +---------------
 1 files changed, 1 insertions(+), 15 deletions(-)

diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
index 7ac71c5..c949df5 100644
--- a/drivers/isdn/gigaset/capi.c
+++ b/drivers/isdn/gigaset/capi.c
@@ -171,20 +171,6 @@ static inline void ignore_cstruct_param(struct cardstate *cs, _cstruct param,
 }
 
 /*
- * check for legal hex digit
- */
-static inline int ishexdigit(char c)
-{
-	if (c >= '0' && c <= '9')
-		return 1;
-	if (c >= 'A' && c <= 'F')
-		return 1;
-	if (c >= 'a' && c <= 'f')
-		return 1;
-	return 0;
-}
-
-/*
  * convert hex to binary
  */
 static inline u8 hex2bin(char c)
@@ -204,7 +190,7 @@ static int encode_ie(char *in, u8 *out, int maxlen)
 {
 	int l = 0;
 	while (*in) {
-		if (!ishexdigit(in[0]) || !ishexdigit(in[1]) || l >= maxlen)
+		if (!isxdigit(in[0]) || !isxdigit(in[1]) || l >= maxlen)
 			return -1;
 		out[++l] = (hex2bin(in[0]) << 4) + hex2bin(in[1]);
 		in += 2;
-- 
1.6.5.3.298.g39add

