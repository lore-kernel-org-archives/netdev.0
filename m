From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net-next 4/4] l2tp: remove field 'dev' from struct l2tp_eth
Date: Tue, 31 Oct 2017 17:36:46 +0100
Message-ID: <3a1c6704dc22033c68afc0162c4e837246a5c2a5.1509466904.git.g.nault@alphalink.fr>
References: <cover.1509466904.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:38662 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751295AbdJaQgv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 12:36:51 -0400
Content-Disposition: inline
In-Reply-To: <cover.1509466904.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This field has never been used.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_eth.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index d29bfee291cb..3e2dec1fb0f5 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -41,7 +41,6 @@
 
 /* via netdev_priv() */
 struct l2tp_eth {
-	struct net_device	*dev;
 	struct sock		*tunnel_sock;
 	struct l2tp_session	*session;
 	atomic_long_t		tx_bytes;
@@ -60,9 +59,6 @@ struct l2tp_eth_sess {
 
 static int l2tp_eth_dev_init(struct net_device *dev)
 {
-	struct l2tp_eth *priv = netdev_priv(dev);
-
-	priv->dev = dev;
 	eth_hw_addr_random(dev);
 	eth_broadcast_addr(dev->broadcast);
 	netdev_lockdep_set_classes(dev);
@@ -315,7 +311,6 @@ static int l2tp_eth_create(struct net *net, struct l2tp_tunnel *tunnel,
 	l2tp_eth_adjust_mtu(tunnel, session, dev);
 
 	priv = netdev_priv(dev);
-	priv->dev = dev;
 	priv->session = session;
 
 	priv->tunnel_sock = tunnel->sock;
-- 
2.15.0
