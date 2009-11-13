From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 4/4] [PATCH] netiucv: displayed TX bytes value much too high
Date: Fri, 13 Nov 2009 08:46:30 +0100
Message-ID: <20091113075050.863396000@linux.vnet.ibm.com>
References: <20091113074626.078348000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.17.166]:43513 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752667AbZKMHuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 02:50:46 -0500
Content-Disposition: inline; filename=616-netiucv-tx-bytes.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

tx_bytes value must be updated by skb length before skb is freed.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 drivers/s390/net/netiucv.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-next-uschi/drivers/s390/net/netiucv.c
===================================================================
--- linux-next-uschi.orig/drivers/s390/net/netiucv.c
+++ linux-next-uschi/drivers/s390/net/netiucv.c
@@ -739,13 +739,13 @@ static void conn_action_txdone(fsm_insta
 	if (single_flag) {
 		if ((skb = skb_dequeue(&conn->commit_queue))) {
 			atomic_dec(&skb->users);
-			dev_kfree_skb_any(skb);
 			if (privptr) {
 				privptr->stats.tx_packets++;
 				privptr->stats.tx_bytes +=
 					(skb->len - NETIUCV_HDRLEN
-					 	  - NETIUCV_HDRLEN);
+						  - NETIUCV_HDRLEN);
 			}
+			dev_kfree_skb_any(skb);
 		}
 	}
 	conn->tx_buff->data = conn->tx_buff->head;

