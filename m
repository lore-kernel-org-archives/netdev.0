From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 36/39] netfilter: ipset: use setup_timer() and mod_timer().
Date: Sun, 13 Nov 2016 23:25:30 +0100
Message-ID: <1479075933-4491-37-git-send-email-pablo@netfilter.org>
References: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Use setup_timer() and instead of init_timer(), being the preferred way
of setting up a timer.

Also, quoting the mod_timer() function comment:
-> mod_timer() is a more efficient way to update the expire field of an
   active timer (if the timer is inactive it will be activated).

Use setup_timer() and mod_timer() to setup and arm a timer, making the
code compact and easier to read.

Signed-off-by: Muhammad Falak R Wani <falakreyaz@gmail.com>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_bitmap_gen.h | 7 ++-----
 net/netfilter/ipset/ip_set_hash_gen.h   | 7 ++-----
 net/netfilter/ipset/ip_set_list_set.c   | 7 ++-----
 3 files changed, 6 insertions(+), 15 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_bitmap_gen.h b/net/netfilter/ipset/ip_set_bitmap_gen.h
index f8ea26cafa30..6f09a99298cd 100644
--- a/net/netfilter/ipset/ip_set_bitmap_gen.h
+++ b/net/netfilter/ipset/ip_set_bitmap_gen.h
@@ -41,11 +41,8 @@ mtype_gc_init(struct ip_set *set, void (*gc)(unsigned long ul_set))
 {
 	struct mtype *map = set->data;
 
-	init_timer(&map->gc);
-	map->gc.data = (unsigned long)set;
-	map->gc.function = gc;
-	map->gc.expires = jiffies + IPSET_GC_PERIOD(set->timeout) * HZ;
-	add_timer(&map->gc);
+	setup_timer(&map->gc, gc, (unsigned long)set);
+	mod_timer(&map->gc, jiffies + IPSET_GC_PERIOD(set->timeout) * HZ);
 }
 
 static void
diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index 88b70fcc5ac5..1b05d4a7d5a1 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -433,11 +433,8 @@ mtype_gc_init(struct ip_set *set, void (*gc)(unsigned long ul_set))
 {
 	struct htype *h = set->data;
 
-	init_timer(&h->gc);
-	h->gc.data = (unsigned long)set;
-	h->gc.function = gc;
-	h->gc.expires = jiffies + IPSET_GC_PERIOD(set->timeout) * HZ;
-	add_timer(&h->gc);
+	setup_timer(&h->gc, gc, (unsigned long)set);
+	mod_timer(&h->gc, jiffies + IPSET_GC_PERIOD(set->timeout) * HZ);
 	pr_debug("gc initialized, run in every %u\n",
 		 IPSET_GC_PERIOD(set->timeout));
 }
diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index dede343a662b..51077c53d76b 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -586,11 +586,8 @@ list_set_gc_init(struct ip_set *set, void (*gc)(unsigned long ul_set))
 {
 	struct list_set *map = set->data;
 
-	init_timer(&map->gc);
-	map->gc.data = (unsigned long)set;
-	map->gc.function = gc;
-	map->gc.expires = jiffies + IPSET_GC_PERIOD(set->timeout) * HZ;
-	add_timer(&map->gc);
+	setup_timer(&map->gc, gc, (unsigned long)set);
+	mod_timer(&map->gc, jiffies + IPSET_GC_PERIOD(set->timeout) * HZ);
 }
 
 /* Create list:set type of sets */
-- 
2.1.4

