From: frank.blaschka@de.ibm.com
Subject: [patch 06/11] [PATCH] qeth: Fold qeth_misc debug area
Date: Tue, 22 Jun 2010 10:57:07 +0200
Message-ID: <20100622085807.666019000@de.ibm.com>
References: <20100622085701.772508000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Carsten Otte <cotte@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.17.167]:48352 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758958Ab0FVI6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 04:58:09 -0400
Content-Disposition: inline; filename=606-qeth-misc-debug.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carsten Otte <cotte@de.ibm.com>

This patch removes the misc debug area. Instead of logging the entire skb
we just log a pointer to it into the card's local debug area in
qeth_core_get_next_skb. Other then that, this debug area is not used anywhere.

Signed-off-by: Carsten Otte <cotte@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core.h      |    1 -
 drivers/s390/net/qeth_core_main.c |    4 +---
 2 files changed, 1 insertion(+), 4 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core.h linux-2.6-patched/drivers/s390/net/qeth_core.h
--- linux-2.6/drivers/s390/net/qeth_core.h	2010-06-22 08:55:00.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core.h	2010-06-22 08:55:00.000000000 +0200
@@ -42,7 +42,6 @@ enum qeth_dbf_names {
 	QETH_DBF_SETUP,
 	QETH_DBF_QERR,
 	QETH_DBF_MSG,
-	QETH_DBF_MISC,
 	QETH_DBF_CTRL,
 	QETH_DBF_INFOS	/* must be last element */
 };
diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2010-06-22 08:55:00.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2010-06-22 08:55:00.000000000 +0200
@@ -36,8 +36,6 @@ struct qeth_dbf_info qeth_dbf[QETH_DBF_I
 				2, 1,   8, 2, &debug_hex_ascii_view, NULL},
 	[QETH_DBF_MSG]   = {"qeth_msg",
 				8, 1, 128, 3, &debug_sprintf_view,   NULL},
-	[QETH_DBF_MISC]	 = {"qeth_misc",
-				2, 1, 256, 2, &debug_hex_ascii_view, NULL},
 	[QETH_DBF_CTRL]  = {"qeth_control",
 		8, 1, QETH_DBF_CTRL_LEN, 5, &debug_hex_ascii_view, NULL},
 };
@@ -4117,7 +4115,7 @@ struct sk_buff *qeth_core_get_next_skb(s
 				QETH_DBF_TEXT(QERR, 2, "unexeob");
 				QETH_DBF_TEXT_(QERR, 2, "%s",
 					CARD_BUS_ID(card));
-				QETH_DBF_HEX(MISC, 4, buffer, sizeof(*buffer));
+				QETH_CARD_HEX(card, 2, buffer, sizeof(void *));
 				dev_kfree_skb_any(skb);
 				card->stats.rx_errors++;
 				return NULL;

