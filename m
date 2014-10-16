From: roy.qing.li@gmail.com
Subject: [PATCH] vxlan: small improvements
Date: Thu, 16 Oct 2014 17:00:44 +0800
Message-ID: <1413450045-5008-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:43681 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbaJPJAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2014 05:00:51 -0400
Received: by mail-pd0-f173.google.com with SMTP id g10so2894108pdj.4
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2014 02:00:51 -0700 (PDT)
Received: from localhost ([106.120.101.38])
        by mx.google.com with ESMTPSA id ra2sm18243580pbc.27.2014.10.16.02.00.49
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 16 Oct 2014 02:00:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

1. remove the dead codes, pr_fmt definition and vxlan_salt variable
2. pskb_may_pull() can change skb->data, so we have to reload eth in vxlan_xmit.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 drivers/net/vxlan.c |    7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 77ab844..3a07fbf 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -8,8 +8,6 @@
  * published by the Free Software Foundation.
  */
 
-#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
-
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/module.h>
@@ -152,8 +150,6 @@ struct vxlan_dev {
 	struct hlist_head fdb_head[FDB_HASH_SIZE];
 };
 
-/* salt for hash table */
-static u32 vxlan_salt __read_mostly;
 static struct workqueue_struct *vxlan_wq;
 
 static void vxlan_sock_work(struct work_struct *work);
@@ -1890,6 +1886,7 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 #endif
 	}
 
+	eth = eth_hdr(skb);
 	f = vxlan_find_mac(vxlan, eth->h_dest);
 	did_rsc = false;
 
@@ -2797,8 +2794,6 @@ static int __init vxlan_init_module(void)
 	if (!vxlan_wq)
 		return -ENOMEM;
 
-	get_random_bytes(&vxlan_salt, sizeof(vxlan_salt));
-
 	rc = register_pernet_subsys(&vxlan_net_ops);
 	if (rc)
 		goto out1;
-- 
1.7.10.4
