From: frank.blaschka@de.ibm.com
Subject: [patch 5/5] [PATCH] qeth: change checksumming default for HiperSockets
Date: Tue, 09 Mar 2010 07:36:57 +0100
Message-ID: <20100309063937.049755000@de.ibm.com>
References: <20100309063652.706791000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.17.164]:43706 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752158Ab0CIGjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Mar 2010 01:39:39 -0500
Content-Disposition: inline; filename=606-qeth-checksum-default.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

Deactivate inbound checksumming on HiperSocket is a valid but
dangerous optimization in case the frame is routed from an OSA
network to an HiperSockets network. To go for sure we change the
default to software checksumming.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |    2 --
 1 file changed, 2 deletions(-)

--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -1114,8 +1114,6 @@ static int qeth_setup_card(struct qeth_c
 	card->ipato.enabled = 0;
 	card->ipato.invert4 = 0;
 	card->ipato.invert6 = 0;
-	if (card->info.type == QETH_CARD_TYPE_IQD)
-		card->options.checksum_type = NO_CHECKSUMMING;
 	/* init QDIO stuff */
 	qeth_init_qdio_info(card);
 	return 0;

