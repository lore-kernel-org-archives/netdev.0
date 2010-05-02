From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] ethernet: call __skb_pull() in eth_type_trans()
Date: Mon,  3 May 2010 06:50:17 +0800
Message-ID: <1272840617-17084-1-git-send-email-xiaosuo@gmail.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:38217 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932216Ab0ECHmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 03:42:00 -0400
Received: by pxi5 with SMTP id 5so102414pxi.19
        for <netdev@vger.kernel.org>; Mon, 03 May 2010 00:42:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

call __skb_pull() in eth_type_trans().

Since the callers of eth_type_trans() always feed it long enough packets,
we can use __skb_pull() to save some cycles.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/ethernet/eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 61ec032..aacbaf7 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -162,7 +162,7 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 
 	skb->dev = dev;
 	skb_reset_mac_header(skb);
-	skb_pull_inline(skb, ETH_HLEN);
+	__skb_pull(skb, ETH_HLEN);
 	eth = eth_hdr(skb);
 
 	if (unlikely(is_multicast_ether_addr(eth->h_dest))) {
