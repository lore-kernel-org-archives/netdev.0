From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 3/3] Use BUILD_BUG_ON in net/core/flowi.c
Date: Mon, 22 Oct 2007 19:28:22 +0400
Message-ID: <471CC196.50607@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:52104 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751496AbXJVP1o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 11:27:44 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of ugly extern not-existing function.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/core/flow.c b/net/core/flow.c
index 0ab5234..3ed2b4b 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -142,8 +142,6 @@ typedef u64 flow_compare_t;
 typedef u32 flow_compare_t;
 #endif
 
-extern void flowi_is_missized(void);
-
 /* I hear what you're saying, use memcmp.  But memcmp cannot make
  * important assumptions that we can here, such as alignment and
  * constant size.
@@ -153,8 +151,7 @@ static int flow_key_compare(struct flowi *key1, struct flowi *key2)
 	flow_compare_t *k1, *k1_lim, *k2;
 	const int n_elem = sizeof(struct flowi) / sizeof(flow_compare_t);
 
-	if (sizeof(struct flowi) % sizeof(flow_compare_t))
-		flowi_is_missized();
+	BUILD_BUG_ON(sizeof(struct flowi) % sizeof(flow_compare_t));
 
 	k1 = (flow_compare_t *) key1;
 	k1_lim = k1 + n_elem;
-- 
1.5.3.4

