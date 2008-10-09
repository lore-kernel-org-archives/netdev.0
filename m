From: Brice Goglin <brice@myri.com>
Subject: [PATCH net-next] myri10ge: remove over-paranoid queue number modulus
Date: Thu, 09 Oct 2008 16:10:13 +0200
Message-ID: <48EE10C5.5030609@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1874 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752738AbYJIOIu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Oct 2008 10:08:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to modulus the queue number in ->hard_start_xmit() since the
core is going to do that for you modulus ->real_num_tx_queues.

Signed-off-by: Brice Goglin <brice@myri.com>

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index ab7755a..8cec6f3 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -2643,8 +2643,6 @@ static int myri10ge_xmit(struct sk_buff *skb, struct net_device *dev)
 	u8 flags, odd_flag;
 
 	queue = skb_get_queue_mapping(skb);
-	queue &= (mgp->num_slices - 1);
-
 	ss = &mgp->ss[queue];
 	netdev_queue = netdev_get_tx_queue(mgp->dev, queue);
 	tx = &ss->tx;


