From: Thomas Gleixner <tglx@linutronix.de>
Subject: [PATCH] net: Make devnet_rename_seq static
Date: Tue, 23 Jul 2013 16:13:17 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1307231612300.4089@ionos.tec.linutronix.de>
References: <alpine.DEB.2.02.1307231559570.4089@ionos.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:46809 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932442Ab3GWONP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 10:13:15 -0400
In-Reply-To: <alpine.DEB.2.02.1307231559570.4089@ionos.tec.linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No users outside net/core/dev.c.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 include/linux/netdevice.h |    3 ---
 net/core/dev.c            |    2 +-
 2 files changed, 1 insertion(+), 4 deletions(-)

Index: linux-stable/include/linux/netdevice.h
===================================================================
--- linux-stable.orig/include/linux/netdevice.h
+++ linux-stable/include/linux/netdevice.h
@@ -1601,9 +1601,6 @@ extern int call_netdevice_notifiers(unsi
 
 extern rwlock_t				dev_base_lock;		/* Device list lock */
 
-extern seqcount_t	devnet_rename_seq;	/* Device rename seq */
-
-
 #define for_each_netdev(net, d)		\
 		list_for_each_entry(d, &(net)->dev_base_head, dev_list)
 #define for_each_netdev_reverse(net, d)	\
Index: linux-stable/net/core/dev.c
===================================================================
--- linux-stable.orig/net/core/dev.c
+++ linux-stable/net/core/dev.c
@@ -166,7 +166,7 @@ static struct list_head offload_base __r
 DEFINE_RWLOCK(dev_base_lock);
 EXPORT_SYMBOL(dev_base_lock);
 
-seqcount_t devnet_rename_seq;
+static seqcount_t devnet_rename_seq;
 
 static inline void dev_base_seq_inc(struct net *net)
 {
