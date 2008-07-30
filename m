From: akpm@linux-foundation.org
Subject: [patch 11/11] isdn: use the common ascii hex helpers
Date: Wed, 30 Jul 2008 12:37:43 -0700
Message-ID: <200807301937.m6UJbhia012461@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	harvey.harrison@gmail.com, kkeil@suse.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52194 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752182AbYG3TxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 15:53:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
Acked-by: Karsten Keil <kkeil@suse.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/gigaset/isocdata.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff -puN drivers/isdn/gigaset/isocdata.c~isdn-use-the-common-ascii-hex-helpers drivers/isdn/gigaset/isocdata.c
--- a/drivers/isdn/gigaset/isocdata.c~isdn-use-the-common-ascii-hex-helpers
+++ a/drivers/isdn/gigaset/isocdata.c
@@ -247,7 +247,6 @@ static inline void dump_bytes(enum debug
 #ifdef CONFIG_GIGASET_DEBUG
 	unsigned char c;
 	static char dbgline[3 * 32 + 1];
-	static const char hexdigit[] = "0123456789abcdef";
 	int i = 0;
 	while (count-- > 0) {
 		if (i > sizeof(dbgline) - 4) {
@@ -258,8 +257,8 @@ static inline void dump_bytes(enum debug
 		c = *bytes++;
 		dbgline[i] = (i && !(i % 12)) ? '-' : ' ';
 		i++;
-		dbgline[i++] = hexdigit[(c >> 4) & 0x0f];
-		dbgline[i++] = hexdigit[c & 0x0f];
+		dbgline[i++] = hex_asc_hi(c);
+		dbgline[i++] = hex_asc_lo(c);
 	}
 	dbgline[i] = '\0';
 	gig_dbg(level, "%s:%s", tag, dbgline);
_
