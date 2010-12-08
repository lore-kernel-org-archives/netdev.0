From: frank.blaschka@de.ibm.com
Subject: [patch 2/4] [PATCH] qeth: support VIPA add/del in offline mode
Date: Wed, 08 Dec 2010 13:57:59 +0100
Message-ID: <20101208125844.490694187@de.ibm.com>
References: <20101208125757.726629855@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Einar Lueck <elelueck@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([194.196.100.166]:51179 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754408Ab0LHM6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 07:58:46 -0500
Content-Disposition: inline; filename=605-qeth-vipa-offline.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Einar Lueck <elelueck@de.ibm.com>

Only work through the IP adddress to do list if the card is UP or
SOFTSETUP. Enables to configure VIPA add/del in offline mode.

Signed-off-by: Einar Lueck <elelueck@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_l3_main.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -456,8 +456,11 @@ static void qeth_l3_set_ip_addr_list(str
 	QETH_CARD_TEXT(card, 2, "sdiplist");
 	QETH_CARD_HEX(card, 2, &card, sizeof(void *));
 
-	if (card->options.sniffer)
+	if ((card->state != CARD_STATE_UP &&
+	     card->state != CARD_STATE_SOFTSETUP) || card->options.sniffer) {
 		return;
+	}
+
 	spin_lock_irqsave(&card->ip_lock, flags);
 	tbd_list = card->ip_tbd_list;
 	card->ip_tbd_list = kmalloc(sizeof(struct list_head), GFP_ATOMIC);

