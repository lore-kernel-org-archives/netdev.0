From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] decnet: avoid touching device refcount in dn_dev_by_index()
Date: Wed, 04 Nov 2009 19:15:14 +0100
Message-ID: <4AF1C4B2.6090802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59604 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754762AbZKDSPN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 13:15:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/decnet/dn_dev.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 6e1f085..d566e98 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -600,15 +600,17 @@ static void dn_dev_check_default(struct net_device *dev)
 		dev_put(dev);
 }
 
+/*
+ * Called with RTNL
+ */
 static struct dn_dev *dn_dev_by_index(int ifindex)
 {
 	struct net_device *dev;
 	struct dn_dev *dn_dev = NULL;
-	dev = dev_get_by_index(&init_net, ifindex);
-	if (dev) {
+
+	dev = __dev_get_by_index(&init_net, ifindex);
+	if (dev)
 		dn_dev = dev->dn_ptr;
-		dev_put(dev);
-	}
 
 	return dn_dev;
 }
