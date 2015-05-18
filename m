From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 7/8] qeth: replace ENOSYS with EOPNOTSUPP
Date: Mon, 18 May 2015 14:27:58 +0200
Message-ID: <1431952079-6847-8-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1431952079-6847-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com,
	Eugene Crosser <Eugene.Crosser@ru.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp16.uk.ibm.com ([195.75.94.112]:44073 "EHLO
	e06smtp16.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754180AbbERM2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 08:28:35 -0400
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Mon, 18 May 2015 13:28:34 +0100
In-Reply-To: <1431952079-6847-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugene Crosser <Eugene.Crosser@ru.ibm.com>

Since recently, `checkpatch.pl` advices that ENOSYS should not be
used for anything other than "invalid syscall nr". This patch
replaces ENOSYS return code with EOPNOTSUPP for the "unsupported
function" conditions.

Signed-off-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 789377c..2e65b98 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -137,7 +137,7 @@ static int qeth_setdel_makerc(struct qeth_card *card, int retcode)
 		rc = 0;
 		break;
 	case IPA_RC_L2_UNSUPPORTED_CMD:
-		rc = -ENOSYS;
+		rc = -EOPNOTSUPP;
 		break;
 	case IPA_RC_L2_ADDR_TABLE_FULL:
 		rc = -ENOSPC;
@@ -1662,7 +1662,7 @@ static int qeth_bridgeport_makerc(struct qeth_card *card,
 			break;
 		case 0x2B04:
 		case 0x0004:
-			rc = -ENOSYS;
+			rc = -EOPNOTSUPP;
 			break;
 		case 0x2B0C:
 		case 0x000C: /* Not configured as bridge Port */
@@ -1717,10 +1717,10 @@ static int qeth_bridgeport_makerc(struct qeth_card *card,
 	else
 		switch (cbctl->ipa_rc) {
 		case IPA_RC_NOTSUPP:
-			rc = -ENOSYS;
+			rc = -EOPNOTSUPP;
 			break;
 		case IPA_RC_UNSUPPORTED_COMMAND:
-			rc = -ENOSYS;
+			rc = -EOPNOTSUPP;
 			break;
 		default:
 			rc = -EIO;
@@ -1948,7 +1948,7 @@ static int qeth_anset_makerc(struct qeth_card *card, int pnso_rc, u16 response)
 		case 0x0004:
 		case 0x0100:
 		case 0x0106:
-			rc = -ENOSYS;
+			rc = -EOPNOTSUPP;
 			dev_err(&card->gdev->dev,
 				"Setting address notification failed\n");
 			break;
-- 
2.3.7
