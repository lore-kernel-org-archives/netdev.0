From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 3/5] ipip: Set inner IP protocol in ipip
Date: Fri, 26 Sep 2014 09:22:32 -0700
Message-ID: <1411748554-7346-4-git-send-email-therbert@google.com>
References: <1411748554-7346-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:51780 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755241AbaIZQW7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 12:22:59 -0400
Received: by mail-pd0-f178.google.com with SMTP id ft15so13131188pdb.9
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 09:22:58 -0700 (PDT)
In-Reply-To: <1411748554-7346-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call skb_set_inner_ipproto to set inner IP protocol to IPPROTO_IPV4
before tunnel_xmit. This is needed if UDP encapsulation (fou) is
being done.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/ipip.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index bfec31d..ea88ab3 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -224,6 +224,8 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (IS_ERR(skb))
 		goto out;
 
+	skb_set_inner_ipproto(skb, IPPROTO_IPIP);
+
 	ip_tunnel_xmit(skb, dev, tiph, tiph->protocol);
 	return NETDEV_TX_OK;
 
-- 
2.1.0.rc2.206.gedb03e5
