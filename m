From: frank.blaschka@de.ibm.com
Subject: [patch 3/4] qeth: Fix for possible null pointer dereference
Date: Wed, 28 May 2014 10:22:30 +0200
Message-ID: <20140528082239.887823659@de.ibm.com>
References: <20140528082227.024995099@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:41774 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754179AbaE1IWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 04:22:45 -0400
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Wed, 28 May 2014 09:22:44 +0100
Content-Disposition: inline; filename=607-qeth-null-dereference.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>

There is otherwise a risk of a possible null pointer dereference.

Was largely found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Signed-off-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core_main.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -1013,7 +1013,7 @@ static long __qeth_check_irb_error(struc
 
 	card = CARD_FROM_CDEV(cdev);
 
-	if (!IS_ERR(irb))
+	if (!card || !IS_ERR(irb))
 		return 0;
 
 	switch (PTR_ERR(irb)) {
@@ -1029,7 +1029,7 @@ static long __qeth_check_irb_error(struc
 		QETH_CARD_TEXT(card, 2, "ckirberr");
 		QETH_CARD_TEXT_(card, 2, "  rc%d", -ETIMEDOUT);
 		if (intparm == QETH_RCD_PARM) {
-			if (card && (card->data.ccwdev == cdev)) {
+			if (card->data.ccwdev == cdev) {
 				card->data.state = CH_STATE_DOWN;
 				wake_up(&card->wait_q);
 			}
