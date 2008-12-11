From: frank.blaschka@de.ibm.com
Subject: [patch 1/4] qeth: HiperSockets mcl string conversion (pre z9 mach)
Date: Thu, 11 Dec 2008 14:23:10 +0100
Message-ID: <20081211132418.536511000@de.ibm.com>
References: <20081211132309.053505000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Klaus-Dieter Wacker <kdwacker@de.ibm.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:54243 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755650AbYLKNYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 08:24:21 -0500
Content-Disposition: inline; filename=603-qeth-mcl.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Klaus-Dieter Wacker <kdwacker@de.ibm.com>

The pre z9 machines provide an mcl string in EBCDIC format,
z9 or later provide string in ASCII format.

Signed-off-by: Klaus-Dieter Wacker <kdwacker@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2008-12-11 11:23:10.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2008-12-11 11:27:12.000000000 +0100
@@ -2250,7 +2250,8 @@ void qeth_print_status_message(struct qe
 		}
 		/* fallthrough */
 	case QETH_CARD_TYPE_IQD:
-		if (card->info.guestlan) {
+		if ((card->info.guestlan) ||
+		    (card->info.mcl_level[0] & 0x80)) {
 			card->info.mcl_level[0] = (char) _ebcasc[(__u8)
 				card->info.mcl_level[0]];
 			card->info.mcl_level[1] = (char) _ebcasc[(__u8)

-- 
