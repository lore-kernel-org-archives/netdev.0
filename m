From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 5/9] [PATCH] ctcm: invalid return code from hard_start_xmit
Date: Tue, 24 Mar 2009 13:29:09 +0100
Message-ID: <20090324124335.930878000@linux.vnet.ibm.com>
References: <20090324122904.744942000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.17.162]:57244 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758041AbZCXMnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 08:43:39 -0400
Content-Disposition: inline; filename=612-ctcm-rc-warning.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

Avoid kernel warning by using the correct hard_start_xmit return
code NETDEV_TX_BUSY for skb requeuing.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 drivers/s390/net/ctcm_main.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/ctcm_main.c linux-2.6-patched/drivers/s390/net/ctcm_main.c
--- linux-2.6/drivers/s390/net/ctcm_main.c	2009-03-04 15:58:03.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/ctcm_main.c	2009-03-04 15:58:31.000000000 +0100
@@ -906,11 +906,11 @@ static int ctcm_tx(struct sk_buff *skb, 
 	}
 
 	if (ctcm_test_and_set_busy(dev))
-		return -EBUSY;
+		return NETDEV_TX_BUSY;
 
 	dev->trans_start = jiffies;
 	if (ctcm_transmit_skb(priv->channel[WRITE], skb) != 0)
-		return 1;
+		return NETDEV_TX_BUSY;
 	return 0;
 }
 

