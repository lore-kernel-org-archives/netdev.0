From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: Fix dev_mc_add()
Date: Wed, 10 Mar 2010 06:09:08 +0100
Message-ID: <1268197748.2872.129.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jiri Pirko <jpirko@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:60990 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835Ab0CJFJO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 00:09:14 -0500
Received: by bwz1 with SMTP id 1so4616936bwz.21
        for <netdev@vger.kernel.org>; Tue, 09 Mar 2010 21:09:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 6e17d45a (net: add addr len check to dev_mc_add)
added a bug in dev_mc_add(), since it can now exit with a lock
imbalance.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Jiri Pirko <jpirko@redhat.com>
---
diff --git a/net/core/dev_mcast.c b/net/core/dev_mcast.c
index fd91569..3dc295b 100644
--- a/net/core/dev_mcast.c
+++ b/net/core/dev_mcast.c
@@ -97,8 +97,9 @@ int dev_mc_add(struct net_device *dev, void *addr, int alen, int glbl)
 
 	netif_addr_lock_bh(dev);
 	if (alen != dev->addr_len)
-		return -EINVAL;
-	err = __dev_addr_add(&dev->mc_list, &dev->mc_count, addr, alen, glbl);
+		err = -EINVAL;
+	else
+		err = __dev_addr_add(&dev->mc_list, &dev->mc_count, addr, alen, glbl);
 	if (!err)
 		__dev_set_rx_mode(dev);
 	netif_addr_unlock_bh(dev);


