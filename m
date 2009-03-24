From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 2/9] [PATCH] lcs: invalid return codes from hard_start_xmit.
Date: Tue, 24 Mar 2009 14:27:44 +0100
Message-ID: <20090324133048.969199000@linux.vnet.ibm.com>
References: <20090324132742.300929000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Klaus-Dieter Wacker <kdwacker@de.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.17.161]:53715 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759966AbZCXNaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 09:30:52 -0400
Content-Disposition: inline; filename=608-lcs-rc.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Klaus-Dieter Wacker <kdwacker@de.ibm.com>

Lcs hard_start_xmit routine issued return codes other than
defined for this interface. Now lcs returns only either
NETDEV_TX_OK or NETDEV_TX_BUSY.

Signed-off-by: Klaus-Dieter Wacker <kdwacker@de.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 drivers/s390/net/lcs.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/lcs.c linux-2.6-patched/drivers/s390/net/lcs.c
--- linux-2.6/drivers/s390/net/lcs.c	2009-03-04 15:58:28.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/lcs.c	2009-03-04 15:58:29.000000000 +0100
@@ -1562,7 +1562,7 @@ __lcs_start_xmit(struct lcs_card *card, 
 	if (skb == NULL) {
 		card->stats.tx_dropped++;
 		card->stats.tx_errors++;
-		return -EIO;
+		return 0;
 	}
 	if (card->state != DEV_STATE_UP) {
 		dev_kfree_skb(skb);
@@ -1587,7 +1587,7 @@ __lcs_start_xmit(struct lcs_card *card, 
 		card->tx_buffer = lcs_get_buffer(&card->write);
 		if (card->tx_buffer == NULL) {
 			card->stats.tx_dropped++;
-			rc = -EBUSY;
+			rc = NETDEV_TX_BUSY;
 			goto out;
 		}
 		card->tx_buffer->callback = lcs_txbuffer_cb;

