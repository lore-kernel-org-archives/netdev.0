From: frank.blaschka@de.ibm.com
Subject: [patch 08/11] [PATCH] qeth: fix use after free for qeths debug area
Date: Tue, 22 Jun 2010 10:57:09 +0200
Message-ID: <20100622085807.926487000@de.ibm.com>
References: <20100622085701.772508000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Carsten Otte <cotte@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.17.162]:42729 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758963Ab0FVI6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 04:58:10 -0400
Content-Disposition: inline; filename=608-qeth-debug-area-free.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carsten Otte <cotte@de.ibm.com>

The function qeth_free_buffer_pool is called _after_ the per-card
debug area has been released. This debug message is not all that
usefull anyway, and thus gets removed.

Signed-off-by: Carsten Otte <cotte@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |    1 -
 1 file changed, 1 deletion(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2010-06-22 08:55:01.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2010-06-22 08:55:01.000000000 +0200
@@ -973,7 +973,6 @@ static void qeth_free_buffer_pool(struct
 {
 	struct qeth_buffer_pool_entry *pool_entry, *tmp;
 	int i = 0;
-	QETH_CARD_TEXT(card, 5, "freepool");
 	list_for_each_entry_safe(pool_entry, tmp,
 				 &card->qdio.init_pool.entry_list, init_list){
 		for (i = 0; i < QETH_MAX_BUFFER_ELEMENTS(card); ++i)

