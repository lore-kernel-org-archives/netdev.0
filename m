From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: [PATCH net-next] neighbour: Make neigh_table_init_no_netlink()
 static.
Date: Sat, 14 Apr 2012 02:34:44 +0900
Message-ID: <20120414023444.b253e677.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:37316 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751474Ab2DMRer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 13:34:47 -0400
Received: by pbcun15 with SMTP id un15so3868701pbc.19
        for <netdev@vger.kernel.org>; Fri, 13 Apr 2012 10:34:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

neigh_table_init_no_netlink() is only used in net/core/neighbour.c file.

Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
---
 include/net/neighbour.h |    1 -
 net/core/neighbour.c    |    3 +--
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 34c996f..63ebd70 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -195,7 +195,6 @@ static inline void *neighbour_priv(const struct neighbour *n)
 #define NEIGH_UPDATE_F_ADMIN			0x80000000
 
 extern void			neigh_table_init(struct neigh_table *tbl);
-extern void			neigh_table_init_no_netlink(struct neigh_table *tbl);
 extern int			neigh_table_clear(struct neigh_table *tbl);
 extern struct neighbour *	neigh_lookup(struct neigh_table *tbl,
 					     const void *pkey,
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index ac71765..2d3e6fc 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1500,7 +1500,7 @@ static void neigh_parms_destroy(struct neigh_parms *parms)
 
 static struct lock_class_key neigh_table_proxy_queue_class;
 
-void neigh_table_init_no_netlink(struct neigh_table *tbl)
+static void neigh_table_init_no_netlink(struct neigh_table *tbl)
 {
 	unsigned long now = jiffies;
 	unsigned long phsize;
@@ -1538,7 +1538,6 @@ void neigh_table_init_no_netlink(struct neigh_table *tbl)
 	tbl->last_flush = now;
 	tbl->last_rand	= now + tbl->parms.reachable_time * 20;
 }
-EXPORT_SYMBOL(neigh_table_init_no_netlink);
 
 void neigh_table_init(struct neigh_table *tbl)
 {
-- 
1.7.8.5
