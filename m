From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH next] s390_net: Kill directly reference of netdev->priv
Date: Fri, 05 Dec 2008 23:09:55 +0800
Message-ID: <49394443.1020402@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: ursula.braun@de.ibm.com, blaschka@linux.vnet.ibm.com,
	linux390@de.ibm.com, NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63338 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752528AbYLEPK1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Dec 2008 10:10:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The private data comes from ccwgroup_device.
So just don't allocate private data memory when do alloc_netdev()
and use netdev->ml_priv to reference private data.

Not do compile-test. Because have no s390 box.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/s390/net/lcs.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/s390/net/lcs.c b/drivers/s390/net/lcs.c
index 0825be8..c7a036a 100644
--- a/drivers/s390/net/lcs.c
+++ b/drivers/s390/net/lcs.c
@@ -1290,7 +1290,7 @@ lcs_set_multicast_list(struct net_device *dev)
         struct lcs_card *card;
 
         LCS_DBF_TEXT(4, trace, "setmulti");
-        card = (struct lcs_card *) dev->priv;
+        card = (struct lcs_card *) dev->ml_priv;
 
         if (!lcs_set_thread_start_bit(card, LCS_SET_MC_THREAD))
 		schedule_work(&card->kernel_thread_starter);
@@ -1607,7 +1607,7 @@ lcs_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	int rc;
 
 	LCS_DBF_TEXT(5, trace, "pktxmit");
-	card = (struct lcs_card *) dev->priv;
+	card = (struct lcs_card *) dev->ml_priv;
 	rc = __lcs_start_xmit(card, skb, dev);
 	return rc;
 }
@@ -1863,7 +1863,7 @@ lcs_getstats(struct net_device *dev)
 	struct lcs_card *card;
 
 	LCS_DBF_TEXT(4, trace, "netstats");
-	card = (struct lcs_card *) dev->priv;
+	card = (struct lcs_card *) dev->ml_priv;
 	return &card->stats;
 }
 
@@ -1878,7 +1878,7 @@ lcs_stop_device(struct net_device *dev)
 	int rc;
 
 	LCS_DBF_TEXT(2, trace, "stopdev");
-	card   = (struct lcs_card *) dev->priv;
+	card   = (struct lcs_card *) dev->ml_priv;
 	netif_carrier_off(dev);
 	netif_tx_disable(dev);
 	dev->flags &= ~IFF_UP;
@@ -1901,7 +1901,7 @@ lcs_open_device(struct net_device *dev)
 	int rc;
 
 	LCS_DBF_TEXT(2, trace, "opendev");
-	card = (struct lcs_card *) dev->priv;
+	card = (struct lcs_card *) dev->ml_priv;
 	/* initialize statistics */
 	rc = lcs_detect(card);
 	if (rc) {
@@ -2150,7 +2150,7 @@ lcs_new_device(struct ccwgroup_device *ccwgdev)
 	if (!dev)
 		goto out;
 	card->dev = dev;
-	card->dev->priv = card;
+	card->dev->ml_priv = card;
 	card->dev->open = lcs_open_device;
 	card->dev->stop = lcs_stop_device;
 	card->dev->hard_start_xmit = lcs_start_xmit;
-- 
1.5.3.4


