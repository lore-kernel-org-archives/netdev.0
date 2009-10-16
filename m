From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] af_packet: mc_drop/flush_mclist changes
Date: Fri, 16 Oct 2009 18:38:46 +0200
Message-ID: <4AD8A195.3040902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:51313 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751327AbZJPQip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 12:38:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We hold RTNL, we can use __dev_get_by_index() instead of dev_get_by_index()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index bf3a295..12b6d5b 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1664,11 +1664,9 @@ static int packet_mc_drop(struct sock *sk, struct packet_mreq_max *mreq)
 			if (--ml->count == 0) {
 				struct net_device *dev;
 				*mlp = ml->next;
-				dev = dev_get_by_index(sock_net(sk), ml->ifindex);
-				if (dev) {
+				dev = __dev_get_by_index(sock_net(sk), ml->ifindex);
+				if (dev)
 					packet_dev_mc(dev, ml, -1);
-					dev_put(dev);
-				}
 				kfree(ml);
 			}
 			rtnl_unlock();
@@ -1692,11 +1690,9 @@ static void packet_flush_mclist(struct sock *sk)
 		struct net_device *dev;
 
 		po->mclist = ml->next;
-		dev = dev_get_by_index(sock_net(sk), ml->ifindex);
-		if (dev != NULL) {
+		dev = __dev_get_by_index(sock_net(sk), ml->ifindex);
+		if (dev != NULL)
 			packet_dev_mc(dev, ml, -1);
-			dev_put(dev);
-		}
 		kfree(ml);
 	}
 	rtnl_unlock();
