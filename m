From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 6/8] tun: implement byte queue limits
Date: Mon, 29 Oct 2012 17:57:37 -0700
Message-ID: <20121030005835.726919547@vyatta.com>
References: <20121030005731.843020405@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:35110 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759045Ab2J3BGO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 21:06:14 -0400
Content-Disposition: inline; filename=tap-bql.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add byte queue limits for tun device transmit.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/tun.c	2012-10-26 14:29:51.172647696 -0700
+++ b/drivers/net/tun.c	2012-10-26 14:31:46.663487824 -0700
@@ -421,6 +421,9 @@ static netdev_tx_t tun_net_xmit(struct s
 		goto drop;
 	skb_orphan(skb);
 
+	/* Update byte queue limits */
+	netdev_sent_queue(dev, skb->len);
+
 	/* Enqueue packet */
 	skb_queue_tail(&tun->socket.sk->sk_receive_queue, skb);
 
@@ -991,6 +994,8 @@ static ssize_t tun_do_read(struct tun_st
 		netif_wake_queue(tun->dev);
 
 		ret = tun_put_user(tun, skb, iv, len);
+
+		netdev_completed_queue(tun->dev, 1, skb->len);
 		kfree_skb(skb);
 		break;
 	}
