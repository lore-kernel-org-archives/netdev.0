From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH next]hysdn: Kill directly reference of netdev->priv
Date: Mon, 01 Dec 2008 22:28:10 +0800
Message-ID: <4933F47A.5060104@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49954 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752075AbYLAO2d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Dec 2008 09:28:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Usually, netdev->priv should point to the memory of private
data which is allocated in alloc_netdev().
netdev_priv() is used to get the address of the private data.

Change the netdev->priv pointer to another memory is wrong.
Use netdev->ml_priv for this case.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/isdn/hysdn/hysdn_net.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/hysdn/hysdn_net.c b/drivers/isdn/hysdn/hysdn_net.c
index cfa8fa5..5b4ae67 100644
--- a/drivers/isdn/hysdn/hysdn_net.c
+++ b/drivers/isdn/hysdn/hysdn_net.c
@@ -76,7 +76,7 @@ static int
 net_open(struct net_device *dev)
 {
 	struct in_device *in_dev;
-	hysdn_card *card = dev->priv;
+	hysdn_card *card = dev->ml_priv;
 	int i;
 
 	netif_start_queue(dev);	/* start tx-queueing */
@@ -159,7 +159,7 @@ net_send_packet(struct sk_buff *skb, struct net_device *dev)
 	spin_unlock_irq(&lp->lock);
 
 	if (lp->sk_count <= 3) {
-		schedule_work(&((hysdn_card *) dev->priv)->irq_queue);
+		schedule_work(&((hysdn_card *) dev->ml_priv)->irq_queue);
 	}
 	return (0);		/* success */
 }				/* net_send_packet */
@@ -295,7 +295,7 @@ hysdn_net_create(hysdn_card * card)
 		kfree(dev);
 		return (i);
 	}
-	dev->priv = card;	/* remember pointer to own data structure */
+	dev->ml_priv = card;	/* remember pointer to own data structure */
 	card->netif = dev;	/* setup the local pointer */
 
 	if (card->debug_flags & LOG_NET_INIT)
-- 
1.5.3.4


