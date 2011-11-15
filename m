From: frank.blaschka@de.ibm.com
Subject: [patch 2/5] [PATCH] qeth: remove WARN_ON leftover
Date: Tue, 15 Nov 2011 13:31:13 +0100
Message-ID: <20111115123152.363081795@de.ibm.com>
References: <20111115123111.128739986@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Christian Borntraeger <borntraeger@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([194.196.100.162]:37404 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752132Ab1KOMbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 07:31:55 -0500
Content-Disposition: inline; filename=620-qeth-warnon.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Borntraeger <borntraeger@de.ibm.com>

The patch "qeth: exploit asynchronous delivery of storage blocks"
added a WARN_ON in qeth_schedule_recovery. A device recovery should
not cause a kernel warning. This is obviously a debugging  left-over
that we forgot to remove.

Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |    1 -
 1 file changed, 1 deletion(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2011-11-14 18:26:56.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2011-11-14 18:27:17.000000000 +0100
@@ -881,7 +881,6 @@ EXPORT_SYMBOL_GPL(qeth_do_run_thread);
 void qeth_schedule_recovery(struct qeth_card *card)
 {
 	QETH_CARD_TEXT(card, 2, "startrec");
-	WARN_ON(1);
 	if (qeth_set_thread_start_bit(card, QETH_RECOVER_THREAD) == 0)
 		schedule_work(&card->kernel_thread_starter);
 }
