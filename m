From: frank.blaschka@de.ibm.com
Subject: [patch 1/7] qeth: Fix default queue setting in priority queueing
Date: Mon, 28 Apr 2014 10:05:05 +0200
Message-ID: <20140428080532.845276976@de.ibm.com>
References: <20140428080504.925649066@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Stefan Raspl <raspl@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:45785 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502AbaD1IFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 04:05:37 -0400
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 28 Apr 2014 09:05:36 +0100
Content-Disposition: inline; filename=600-qeth-default-settings.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Raspl <raspl@linux.vnet.ibm.com>

The default queue for queueing modes prio_queueing_prec and
prio_queueing_tos is supposed to be QETH_DEFAULT_QUEUE. However, neither
mode will reset the default default_out_queue value when enabled, leaving
a previously set value activate as the default.
E.g. enabling one of the fixed queueing modes, e.g. no_prio_queueing:0,
and successively switching to any of the prio_queueing_* modes will
leave default_out_queue at the previous (wrong) value 0.

Signed-off-by: Stefan Raspl <raspl@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/qeth_core_sys.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/s390/net/qeth_core_sys.c b/drivers/s390/net/qeth_core_sys.c
index 425c0ec..8547de8 100644
--- a/drivers/s390/net/qeth_core_sys.c
+++ b/drivers/s390/net/qeth_core_sys.c
@@ -250,11 +250,13 @@ static ssize_t qeth_dev_prioqing_store(struct device *dev,
 	}
 
 	tmp = strsep((char **) &buf, "\n");
-	if (!strcmp(tmp, "prio_queueing_prec"))
+	if (!strcmp(tmp, "prio_queueing_prec")) {
 		card->qdio.do_prio_queueing = QETH_PRIO_Q_ING_PREC;
-	else if (!strcmp(tmp, "prio_queueing_tos"))
+		card->qdio.default_out_queue = QETH_DEFAULT_QUEUE;
+	} else if (!strcmp(tmp, "prio_queueing_tos")) {
 		card->qdio.do_prio_queueing = QETH_PRIO_Q_ING_TOS;
-	else if (!strcmp(tmp, "no_prio_queueing:0")) {
+		card->qdio.default_out_queue = QETH_DEFAULT_QUEUE;
+	} else if (!strcmp(tmp, "no_prio_queueing:0")) {
 		card->qdio.do_prio_queueing = QETH_NO_PRIO_QUEUEING;
 		card->qdio.default_out_queue = 0;
 	} else if (!strcmp(tmp, "no_prio_queueing:1")) {
