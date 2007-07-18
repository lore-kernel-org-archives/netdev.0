From: Denis Cheng <crquan@gmail.com>
Subject: [PATCH 3/3] [net/core] move __dev_addr_discard adjacent to dev_addr_discard for readability
Date: Wed, 18 Jul 2007 10:41:05 +0800
Message-ID: <11847264843820-git-send-email-crquan@gmail.com>
References: <11846606051099-git-send-email-crquan@gmail.com>
 <11847264651509-git-send-email-crquan@gmail.com>
 <11847264751175-git-send-email-crquan@gmail.com>
Cc: Pekka Savola <pekkas@netcore.fi>, James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@coreworks.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Denis Cheng <crquan@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Networking Team <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.234]:63963 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934989AbXGRClT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 22:41:19 -0400
Received: by qb-out-0506.google.com with SMTP id e11so42986qbe
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2007 19:41:19 -0700 (PDT)
In-Reply-To: <11847264751175-git-send-email-crquan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Denis Cheng <crquan@gmail.com>
---
 net/core/dev.c |   28 ++++++++++++++--------------
 1 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 17c9cbd..6357f54 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2715,20 +2715,6 @@ int __dev_addr_add(struct dev_addr_list **list, int *count,
 	return 0;
 }
 
-static void __dev_addr_discard(struct dev_addr_list **list)
-{
-	struct dev_addr_list *tmp;
-
-	while (*list != NULL) {
-		tmp = *list;
-		*list = tmp->next;
-		if (tmp->da_users > tmp->da_gusers)
-			printk("__dev_addr_discard: address leakage! "
-			       "da_users=%d\n", tmp->da_users);
-		kfree(tmp);
-	}
-}
-
 /**
  *	dev_unicast_delete	- Release secondary unicast address.
  *	@dev: device
@@ -2777,6 +2763,20 @@ int dev_unicast_add(struct net_device *dev, void *addr, int alen)
 }
 EXPORT_SYMBOL(dev_unicast_add);
 
+static void __dev_addr_discard(struct dev_addr_list **list)
+{
+	struct dev_addr_list *tmp;
+
+	while (*list != NULL) {
+		tmp = *list;
+		*list = tmp->next;
+		if (tmp->da_users > tmp->da_gusers)
+			printk("__dev_addr_discard: address leakage! "
+			       "da_users=%d\n", tmp->da_users);
+		kfree(tmp);
+	}
+}
+
 static void dev_addr_discard(struct net_device *dev)
 {
 	netif_tx_lock_bh(dev);
-- 
1.5.2.2

