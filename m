From: David Miller <davem@davemloft.net>
Subject: [PATCH 6/42] decnet: Fix set-but-unused variable.
Date: Sun, 17 Apr 2011 17:32:50 -0700 (PDT)
Message-ID: <20110417.173250.183050174.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40539
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752652Ab1DRAdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:33:24 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 8472424C087
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:32:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


"next" in dn_rebuild_zone() is set but not actually used,
kill it off.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/decnet/dn_table.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
index 99d8d3a..d8ea583 100644
--- a/net/decnet/dn_table.c
+++ b/net/decnet/dn_table.c
@@ -124,11 +124,10 @@ static inline void dn_rebuild_zone(struct dn_zone *dz,
 				   int old_divisor)
 {
 	int i;
-	struct dn_fib_node *f, **fp, *next;
+	struct dn_fib_node *f, **fp;
 
 	for(i = 0; i < old_divisor; i++) {
 		for(f = old_ht[i]; f; f = f->fn_next) {
-			next = f->fn_next;
 			for(fp = dn_chain_p(f->fn_key, dz);
 				*fp && dn_key_leq((*fp)->fn_key, f->fn_key);
 				fp = &(*fp)->fn_next)
-- 
1.7.4.3

