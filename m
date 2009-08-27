From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] tipc: fix test of bearer_priority range in tipc_register_media()
Date: Thu, 27 Aug 2009 14:03:15 +0200
Message-ID: <4A967603.8070707@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Per Liden <per.liden@ericsson.com>,
	tipc-discussion@lists.sourceforge.net,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f206.google.com ([209.85.219.206]:59520 "EHLO
	mail-ew0-f206.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751975AbZH0L56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2009 07:57:58 -0400
Received: by ewy2 with SMTP id 2so1108192ewy.17
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2009 04:58:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the bearer_priority to be less than TIPC_MIN_LINK_PRI and greater than
TIPC_MAX_LINK_PRI is logically impossible.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index a7a3677..327011f 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -119,7 +119,7 @@ int  tipc_register_media(u32 media_type,
 		warn("Media <%s> rejected, no broadcast address\n", name);
 		goto exit;
 	}
-	if ((bearer_priority < TIPC_MIN_LINK_PRI) &&
+	if ((bearer_priority < TIPC_MIN_LINK_PRI) ||
 	    (bearer_priority > TIPC_MAX_LINK_PRI)) {
 		warn("Media <%s> rejected, illegal priority (%u)\n", name,
 		     bearer_priority);
