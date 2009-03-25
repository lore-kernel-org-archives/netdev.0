From: frank.blaschka@de.ibm.com
Subject: [patch 4/6] [PATCH] qeth: unregister MAC addresses during recovery.
Date: Wed, 25 Mar 2009 07:57:17 +0100
Message-ID: <20090325065809.091751000@de.ibm.com>
References: <20090325065713.054133000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Klaus-Dieter Wacker <kdwacker@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:47650 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755453AbZCYG6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 02:58:12 -0400
Content-Disposition: inline; filename=609-qeth-unreg-macs.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Klaus-Dieter Wacker <kdwacker@de.ibm.com>

qeth: Unregister MAC addresses from device (layer 2) during
recovery cycle. When the device is set online the MAC
addresses are registered again on the device.

Signed-off-by: Klaus-Dieter Wacker <kdwacker@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_l2_main.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_l2_main.c linux-2.6-patched/drivers/s390/net/qeth_l2_main.c
--- linux-2.6/drivers/s390/net/qeth_l2_main.c	2009-02-18 12:06:32.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/qeth_l2_main.c	2009-02-18 12:06:32.000000000 +0100
@@ -378,7 +378,8 @@ static int qeth_l2_stop_card(struct qeth
 			dev_close(card->dev);
 			rtnl_unlock();
 		}
-		if (!card->use_hard_stop) {
+		if (!card->use_hard_stop ||
+			recovery_mode) {
 			__u8 *mac = &card->dev->dev_addr[0];
 			rc = qeth_l2_send_delmac(card, mac);
 			QETH_DBF_TEXT_(SETUP, 2, "Lerr%d", rc);
@@ -387,7 +388,8 @@ static int qeth_l2_stop_card(struct qeth
 	}
 	if (card->state == CARD_STATE_SOFTSETUP) {
 		qeth_l2_process_vlans(card, 1);
-		if (!card->use_hard_stop)
+		if (!card->use_hard_stop ||
+			recovery_mode)
 			qeth_l2_del_all_mc(card);
 		qeth_clear_ipacmd_list(card);
 		card->state = CARD_STATE_HARDSETUP;

