From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 43/51] caif: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:33 -0400
Message-ID: <1333335521-1348-44-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46801 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754473Ab2DBDAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 23:00:34 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/caif/chnl_net.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index 20618dd..93e9c6d 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -421,14 +421,14 @@ static int ipcaif_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	struct chnl_net *priv;
 	u8 loop;
 	priv = netdev_priv(dev);
-	NLA_PUT_U32(skb, IFLA_CAIF_IPV4_CONNID,
-		    priv->conn_req.sockaddr.u.dgm.connection_id);
-	NLA_PUT_U32(skb, IFLA_CAIF_IPV6_CONNID,
-		    priv->conn_req.sockaddr.u.dgm.connection_id);
+	if (nla_put_u32(skb, IFLA_CAIF_IPV4_CONNID,
+			priv->conn_req.sockaddr.u.dgm.connection_id) ||
+	    nla_put_u32(skb, IFLA_CAIF_IPV6_CONNID,
+			priv->conn_req.sockaddr.u.dgm.connection_id))
+		goto nla_put_failure;
 	loop = priv->conn_req.protocol == CAIFPROTO_DATAGRAM_LOOP;
-	NLA_PUT_U8(skb, IFLA_CAIF_LOOPBACK, loop);
-
-
+	if (nla_put_u8(skb, IFLA_CAIF_LOOPBACK, loop))
+		goto nla_put_failure;
 	return 0;
 nla_put_failure:
 	return -EMSGSIZE;
-- 
1.7.7.6
