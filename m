From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: [PATCH] net: add+use poison defines
Date: Sun, 2 Jul 2006 16:40:58 -0700
Message-ID: <20060702164058.f8ce0ded.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, akpm <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:23225 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S1750742AbWGBXiN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jul 2006 19:38:13 -0400
Received: from midway.site ([71.245.108.25]) by xenotime.net for <netdev@vger.kernel.org>; Sun, 2 Jul 2006 16:38:11 -0700
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>

Add and use poison defines in net/.

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 include/linux/poison.h          |    4 ++++
 net/atm/clip.c                  |    3 ++-
 net/ipv6/netfilter/ip6_tables.c |    3 ++-
 3 files changed, 8 insertions(+), 2 deletions(-)

--- linux-2617-g20.orig/include/linux/poison.h
+++ linux-2617-g20/include/linux/poison.h
@@ -45,6 +45,10 @@
 /********** drivers/atm/ **********/
 #define ATM_POISON_FREE		0x12
 
+/********** net/ **********/
+#define NEIGHBOR_DEAD		0xdeadbeef
+#define NETFILTER_LINK_POISON	0xdead57ac
+
 /********** kernel/mutexes **********/
 #define MUTEX_DEBUG_INIT	0x11
 #define MUTEX_DEBUG_FREE	0x22
--- linux-2617-g20.orig/net/atm/clip.c
+++ linux-2617-g20/net/atm/clip.c
@@ -23,6 +23,7 @@
 #include <linux/if.h> /* for IFF_UP */
 #include <linux/inetdevice.h>
 #include <linux/bitops.h>
+#include <linux/poison.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/rcupdate.h>
@@ -266,7 +267,7 @@ static void clip_neigh_destroy(struct ne
 	DPRINTK("clip_neigh_destroy (neigh %p)\n", neigh);
 	if (NEIGH2ENTRY(neigh)->vccs)
 		printk(KERN_CRIT "clip_neigh_destroy: vccs != NULL !!!\n");
-	NEIGH2ENTRY(neigh)->vccs = (void *) 0xdeadbeef;
+	NEIGH2ENTRY(neigh)->vccs = (void *) NEIGHBOR_DEAD;
 }
 
 static void clip_neigh_solicit(struct neighbour *neigh, struct sk_buff *skb)
--- linux-2617-g20.orig/net/ipv6/netfilter/ip6_tables.c
+++ linux-2617-g20/net/ipv6/netfilter/ip6_tables.c
@@ -25,6 +25,7 @@
 #include <linux/vmalloc.h>
 #include <linux/netdevice.h>
 #include <linux/module.h>
+#include <linux/poison.h>
 #include <linux/icmpv6.h>
 #include <net/ipv6.h>
 #include <asm/uaccess.h>
@@ -376,7 +377,7 @@ ip6t_do_table(struct sk_buff **pskb,
 	} while (!hotdrop);
 
 #ifdef CONFIG_NETFILTER_DEBUG
-	((struct ip6t_entry *)table_base)->comefrom = 0xdead57ac;
+	((struct ip6t_entry *)table_base)->comefrom = NETFILTER_LINK_POISON;
 #endif
 	read_unlock_bh(&table->lock);
 


---
