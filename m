From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 2/2] net: napi_hash_add() is no longer exported
Date: Tue, 08 Nov 2016 11:07:28 -0800
Message-ID: <1478632048.17367.24.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Michael Chan <michael.chan@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35521 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750869AbcKHTHa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 14:07:30 -0500
Received: by mail-pf0-f196.google.com with SMTP id i88so20517255pfk.2
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2016 11:07:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

There are no more users except from net/core/dev.c
napi_hash_add() can now be static.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Michael Chan <michael.chan@broadcom.com>
---
 include/linux/netdevice.h |   11 -----------
 net/core/dev.c            |    3 +--
 2 files changed, 1 insertion(+), 13 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 66fd61c681d90d4a7ecc3bf7bae44c2b3b1fe10c..d64135a0ab718b9e119646b74f92901e8fe4b356 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -468,17 +468,6 @@ static inline void napi_complete(struct napi_struct *n)
 }
 
 /**
- *	napi_hash_add - add a NAPI to global hashtable
- *	@napi: NAPI context
- *
- * Generate a new napi_id and store a @napi under it in napi_hash.
- * Used for busy polling (CONFIG_NET_RX_BUSY_POLL).
- * Note: This is normally automatically done from netif_napi_add(),
- * so might disappear in a future Linux version.
- */
-void napi_hash_add(struct napi_struct *napi);
-
-/**
  *	napi_hash_del - remove a NAPI from global table
  *	@napi: NAPI context
  *
diff --git a/net/core/dev.c b/net/core/dev.c
index 0260ad314506c621215a0e3449392bc01aad55ca..e2148d9845868d7ca5d2c6b853cb0fbe18b32163 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5017,7 +5017,7 @@ EXPORT_SYMBOL(sk_busy_loop);
 
 #endif /* CONFIG_NET_RX_BUSY_POLL */
 
-void napi_hash_add(struct napi_struct *napi)
+static void napi_hash_add(struct napi_struct *napi)
 {
 	if (test_bit(NAPI_STATE_NO_BUSY_POLL, &napi->state) ||
 	    test_and_set_bit(NAPI_STATE_HASHED, &napi->state))
@@ -5037,7 +5037,6 @@ void napi_hash_add(struct napi_struct *napi)
 
 	spin_unlock(&napi_hash_lock);
 }
-EXPORT_SYMBOL_GPL(napi_hash_add);
 
 /* Warning : caller is responsible to make sure rcu grace period
  * is respected before freeing memory containing @napi
