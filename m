From: frank.blaschka@de.ibm.com
Subject: [patch 1/2] qeth: use firmware MAC-address for layer2 hsi-devices
Date: Fri, 19 Sep 2008 12:56:02 +0200
Message-ID: <20080919105702.427694000@de.ibm.com>
References: <20080919105601.986966000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:51299 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927AbYISK5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 06:57:35 -0400
Content-Disposition: inline; filename=600-qeth-mac.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

Real HiperSocket devices in layer2 mode have a firmware-created
MAC-address. This change enables the qeth driver to use this
firmware MAC-address for layer2 HiperSocket devices.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_l2_main.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_l2_main.c linux-2.6-patched/drivers/s390/net/qeth_l2_main.c
--- linux-2.6/drivers/s390/net/qeth_l2_main.c	2008-09-19 00:08:20.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l2_main.c	2008-09-19 00:08:39.000000000 +0200
@@ -559,7 +559,8 @@ static int qeth_l2_request_initial_mac(s
 			"device %s: x%x\n", CARD_BUS_ID(card), rc);
 	}
 
-	if (card->info.guestlan) {
+	if ((card->info.type == QETH_CARD_TYPE_IQD) || 
+	    (card->info.guestlan)) {
 		rc = qeth_setadpparms_change_macaddr(card);
 		if (rc) {
 			QETH_DBF_MESSAGE(2, "couldn't get MAC address on "

-- 
