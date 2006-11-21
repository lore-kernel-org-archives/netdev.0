From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: [PATCH 4/11] [DECNET]: Use kzalloc where applicable
Date: Tue, 21 Nov 2006 01:27:54 -0200
Message-ID: <20061121032754.GE7039@mandriva.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mandriva.com ([212.85.150.183]:8429 "EHLO mx1.mandriva.com")
	by vger.kernel.org with ESMTP id S1030688AbWKUD2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 22:28:02 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/decnet/dn_table.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
index 9ce58c2..bdbc3f4 100644
--- a/net/decnet/dn_table.c
+++ b/net/decnet/dn_table.c
@@ -831,10 +831,11 @@ struct dn_fib_table *dn_fib_get_table(u3
                 printk(KERN_DEBUG "DECnet: BUG! Attempt to create routing table from interrupt\n"); 
                 return NULL;
         }
-        if ((t = kmalloc(sizeof(struct dn_fib_table) + sizeof(struct dn_hash), GFP_KERNEL)) == NULL)
-                return NULL;
 
-        memset(t, 0, sizeof(struct dn_fib_table));
+        t = kzalloc(sizeof(struct dn_fib_table) + sizeof(struct dn_hash),
+		    GFP_KERNEL);
+        if (t == NULL)
+                return NULL;
 
         t->n = n;
         t->insert = dn_fib_table_insert;
@@ -842,7 +843,6 @@ struct dn_fib_table *dn_fib_get_table(u3
         t->lookup = dn_fib_table_lookup;
         t->flush  = dn_fib_table_flush;
         t->dump = dn_fib_table_dump;
-	memset(t->data, 0, sizeof(struct dn_hash));
 	hlist_add_head_rcu(&t->hlist, &dn_fib_table_hash[h]);
 
         return t;
-- 
1.4.2.1.g3d5c

