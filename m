From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH] net/tipc: use %*phC to dump small buffers in hex form
Date: Wed, 10 Jul 2013 17:30:34 +0300
Message-ID: <1373466634-24842-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Jon Maloy <jon.maloy@ericsson.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:27436 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754473Ab3GJOao (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jul 2013 10:30:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of passing each byte by stack let's use nice specifier for that.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 net/tipc/ib_media.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/net/tipc/ib_media.c b/net/tipc/ib_media.c
index ad2e1ec..9934a32 100644
--- a/net/tipc/ib_media.c
+++ b/net/tipc/ib_media.c
@@ -292,13 +292,7 @@ static int ib_addr2str(struct tipc_media_addr *a, char *str_buf, int str_size)
 	if (str_size < 60)	/* 60 = 19 * strlen("xx:") + strlen("xx\0") */
 		return 1;
 
-	sprintf(str_buf, "%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x:"
-			 "%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x",
-		a->value[0], a->value[1], a->value[2], a->value[3],
-		a->value[4], a->value[5], a->value[6], a->value[7],
-		a->value[8], a->value[9], a->value[10], a->value[11],
-		a->value[12], a->value[13], a->value[14], a->value[15],
-		a->value[16], a->value[17], a->value[18], a->value[19]);
+	sprintf(str_buf, "%20phC", a->value);
 
 	return 0;
 }
-- 
1.8.3.2
