From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 3/9] [PATCH] netiucv: invalid return code from hard_start_xmit
Date: Tue, 24 Mar 2009 13:29:07 +0100
Message-ID: <20090324124335.540737000@linux.vnet.ibm.com>
References: <20090324122904.744942000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:43468 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758480AbZCXMnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 08:43:39 -0400
Content-Disposition: inline; filename=610-netiucv-rc-warning.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

Avoid kernel warning by using the correct hard_start_xmit return
code NETDEV_TX_BUSY for skb requeuing.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 drivers/s390/net/netiucv.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -urpN linux-2.6/drivers/s390/net/netiucv.c linux-2.6-patched/drivers/s390/net/netiucv.c
--- linux-2.6/drivers/s390/net/netiucv.c	2009-03-04 15:58:03.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/netiucv.c	2009-03-04 15:58:30.000000000 +0100
@@ -1312,7 +1312,7 @@ static int netiucv_tx(struct sk_buff *sk
 
 	if (netiucv_test_and_set_busy(dev)) {
 		IUCV_DBF_TEXT(data, 2, "EBUSY from netiucv_tx\n");
-		return -EBUSY;
+		return NETDEV_TX_BUSY;
 	}
 	dev->trans_start = jiffies;
 	rc = netiucv_transmit_skb(privptr->conn, skb) != 0;

