From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PPATCH net-next-2.6] ipv4: inetdev_by_index() switch to RCU
Date: Mon, 02 Nov 2009 06:23:04 +0100
Message-ID: <4AEE6CB8.1000106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57770 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751048AbZKBFXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 00:23:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use dev_get_by_index_rcu() instead of __dev_get_by_index() and
dev_base_lock rwlock

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 5df2f6a..ccccaae 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -405,11 +405,12 @@ struct in_device *inetdev_by_index(struct net *net, int ifindex)
 {
 	struct net_device *dev;
 	struct in_device *in_dev = NULL;
-	read_lock(&dev_base_lock);
-	dev = __dev_get_by_index(net, ifindex);
+
+	rcu_read_lock();
+	dev = dev_get_by_index_rcu(net, ifindex);
 	if (dev)
 		in_dev = in_dev_get(dev);
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 	return in_dev;
 }
 
