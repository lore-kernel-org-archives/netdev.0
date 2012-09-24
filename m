From: frank.blaschka@de.ibm.com
Subject: [patch 2/5] [PATCH] lcs: ensure proper ccw setup
Date: Mon, 24 Sep 2012 16:24:24 +0200
Message-ID: <20120924142501.136612532@de.ibm.com>
References: <20120924142422.001953152@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Sebastian Ott <sebott@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:51511 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755651Ab2IXOZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 10:25:09 -0400
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 24 Sep 2012 15:25:07 +0100
Content-Disposition: inline; filename=601-lcs-ccw-memset.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Ott <sebott@linux.vnet.ibm.com>

Make sure that all ccws used for writing are initialized with
zeros - especially since the last ccw contains a TIC for which
the unused fields have to be zeros.

Signed-off-by: Sebastian Ott <sebott@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/lcs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/s390/net/lcs.c b/drivers/s390/net/lcs.c
index a3adf4b..2ca0f1d 100644
--- a/drivers/s390/net/lcs.c
+++ b/drivers/s390/net/lcs.c
@@ -282,7 +282,7 @@ lcs_setup_write_ccws(struct lcs_card *card)
 
 	LCS_DBF_TEXT(3, setup, "iwritccw");
 	/* Setup write ccws. */
-	memset(card->write.ccws, 0, sizeof(struct ccw1) * LCS_NUM_BUFFS + 1);
+	memset(card->write.ccws, 0, sizeof(struct ccw1) * (LCS_NUM_BUFFS + 1));
 	for (cnt = 0; cnt < LCS_NUM_BUFFS; cnt++) {
 		card->write.ccws[cnt].cmd_code = LCS_CCW_WRITE;
 		card->write.ccws[cnt].count = 0;
-- 
1.7.11.7
