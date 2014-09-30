From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 net-next 2/5] sit: Set inner IP protocol in sit
Date: Mon, 29 Sep 2014 20:22:30 -0700
Message-ID: <1412047353-28502-3-git-send-email-therbert@google.com>
References: <1412047353-28502-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:56436 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754565AbaI3DW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 23:22:58 -0400
Received: by mail-pa0-f42.google.com with SMTP id et14so988344pad.29
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 20:22:58 -0700 (PDT)
In-Reply-To: <1412047353-28502-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call skb_set_inner_ipproto to set inner IP protocol to IPPROTO_IPV6
before tunnel_xmit. This is needed if UDP encapsulation (fou) is
being done.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv6/sit.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index db75809..0d4e274 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -982,6 +982,8 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 		goto tx_error;
 	}
 
+	skb_set_inner_ipproto(skb, IPPROTO_IPV6);
+
 	err = iptunnel_xmit(skb->sk, rt, skb, fl4.saddr, fl4.daddr,
 			    protocol, tos, ttl, df,
 			    !net_eq(tunnel->net, dev_net(dev)));
@@ -1006,6 +1008,8 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (IS_ERR(skb))
 		goto out;
 
+	skb_set_inner_ipproto(skb, IPPROTO_IPIP);
+
 	ip_tunnel_xmit(skb, dev, tiph, IPPROTO_IPIP);
 	return NETDEV_TX_OK;
 out:
-- 
2.1.0.rc2.206.gedb03e5
