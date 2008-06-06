From: frank.blaschka@de.ibm.com
Subject: [patch 5/5] qeth: start dev queue after tx drop error
Date: Fri, 06 Jun 2008 12:37:48 +0200
Message-ID: <20080606103830.766673000@de.ibm.com>
References: <20080606103743.638691000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:28116 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754833AbYFFKit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 06:38:49 -0400
Content-Disposition: inline; filename=604-qeth-txdrop.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

In case the xmit function drop out with an error, we have to wake
the netdevice queue to start another xmit.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 drivers/s390/net/qeth_l2_main.c |    1 +
 drivers/s390/net/qeth_l3_main.c |    1 +
 2 files changed, 2 insertions(+)

diff -urpN linux-2.6/drivers/s390/net/qeth_l2_main.c linux-2.6-patched/drivers/s390/net/qeth_l2_main.c
--- linux-2.6/drivers/s390/net/qeth_l2_main.c	2008-06-06 11:36:26.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l2_main.c	2008-06-06 11:36:27.000000000 +0200
@@ -721,6 +721,7 @@ tx_drop:
 	if ((new_skb != skb) && new_skb)
 		dev_kfree_skb_any(new_skb);
 	dev_kfree_skb_any(skb);
+	netif_wake_queue(dev);
 	return NETDEV_TX_OK;
 }
 
diff -urpN linux-2.6/drivers/s390/net/qeth_l3_main.c linux-2.6-patched/drivers/s390/net/qeth_l3_main.c
--- linux-2.6/drivers/s390/net/qeth_l3_main.c	2008-06-06 11:36:26.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l3_main.c	2008-06-06 11:36:27.000000000 +0200
@@ -2764,6 +2764,7 @@ tx_drop:
 	if ((new_skb != skb) && new_skb)
 		dev_kfree_skb_any(new_skb);
 	dev_kfree_skb_any(skb);
+	netif_wake_queue(dev);
 	return NETDEV_TX_OK;
 }
 

-- 
