From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [patch 4/6] s390: qeth :allow setting of attribute "route6" to
 "no_router".
Date: Wed, 22 Mar 2006 17:42:09 +0100
Message-ID: <20060322174209.0763b174@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751371AbWCVQky@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[patch 4/6] s390: qeth :allow setting of attribute "route6" to "no_router". 

From: Ursula Braun <braunu@de.ibm.com>
	when setting route6 attribute back to no_router qeth does not
	issue an IP ASSIST command to reset router value to no_router.
	Once primary_router is set device stays in this mode.
	Issue an IP ASSIST command when no_router is set in route6.
	Device will be reset and thus will not longer run as a primary
	router.
			    
Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>

diffstat:
 qeth_main.c |    5 -----
 1 files changed, 5 deletions(-)

diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index 69329ea..021cd5d 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -7339,11 +7339,6 @@ qeth_setrouting_v6(struct qeth_card *car
 	qeth_correct_routing_type(card, &card->options.route6.type,
 				  QETH_PROT_IPV6);
 
-	if ((card->options.route6.type == NO_ROUTER) ||
-	    ((card->info.type == QETH_CARD_TYPE_OSAE) &&
-	     (card->options.route6.type == MULTICAST_ROUTER) &&
-	     !qeth_is_supported6(card,IPA_OSA_MC_ROUTER)))
-		return 0;
 	rc = qeth_send_setrouting(card, card->options.route6.type,
 				  QETH_PROT_IPV6);
 	if (rc) {
