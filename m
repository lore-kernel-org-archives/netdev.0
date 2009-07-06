From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: [patch] econet: use NET_RX_SUCCESS instead of magic number 0 for
 econet_rcv successful return
Date: Tue, 7 Jul 2009 06:35:58 +0930
Message-ID: <20090707063558.895a7fb5.lk-netdev@lk-netdev.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.adam.net.au ([202.136.110.251]:53090 "EHLO
	smtp2.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752194AbZGFVF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 17:05:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Mark Smith <markzzzsmith@yahoo.com.au>


diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index 6f479fa..f734392 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -1084,7 +1084,7 @@ static int econet_rcv(struct sk_buff *skb, struct net_device *dev, struct packet
 		skb->protocol = htons(ETH_P_IP);
 		skb_pull(skb, sizeof(struct ec_framehdr));
 		netif_rx(skb);
-		return 0;
+		return NET_RX_SUCCESS;
 	}
 
 	sk = ec_listening_socket(hdr->port, hdr->src_stn, hdr->src_net);
@@ -1095,7 +1095,7 @@ static int econet_rcv(struct sk_buff *skb, struct net_device *dev, struct packet
 			    hdr->port))
 		goto drop;
 
-	return 0;
+	return NET_RX_SUCCESS;
 
 drop:
 	kfree_skb(skb);
