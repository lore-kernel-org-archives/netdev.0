From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 14/17] batman-adv: Check type of x and y in seq_(before|after)
Date: Mon, 30 May 2011 09:22:59 +0200
Message-ID: <1306740182-2665-15-git-send-email-sven@narfation.org>
References: <1306740182-2665-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:60265 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755237Ab1E3HXW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 May 2011 03:23:22 -0400
In-Reply-To: <1306740182-2665-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

seq_before and seq_after depend on the fact that both sequence numbers
have the same type and thus the same bitwidth. We can ensure that by
compile time checking using a compare between the pointer to the
temporary buffers which were created using the typeof of both
parameters. For example gcc would create a warning like
"warning: comparison of distinct pointer types lacks a cast".

Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/main.h |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 80be5ad..610eaf0 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -194,8 +194,11 @@ static inline int compare_eth(const void *data1, const void *data2)
  *  - before adding more than 127 to the starting value - it is a predecessor,
  *  - when adding 128 - it is neither a predecessor nor a successor,
  *  - after adding more than 127 to the starting value - it is a successor */
-#define seq_before(x, y) ({typeof(x) _dummy = (x - y); \
-			_dummy > smallest_signed_int(_dummy); })
+#define seq_before(x, y) ({typeof(x) _d1 = (x); \
+			  typeof(y) _d2 = (y); \
+			  typeof(x) _dummy = (_d1 - _d2); \
+			  (void) (&_d1 == &_d2); \
+			  _dummy > smallest_signed_int(_dummy); })
 #define seq_after(x, y) seq_before(y, x)
 
 #endif /* _NET_BATMAN_ADV_MAIN_H_ */
-- 
1.7.5.3

