From: frank.blaschka@de.ibm.com
Subject: [patch 2/8] qeth: Clear mac_bits field when switching between Layer 2 and Layer 3
Date: Fri, 23 Jul 2010 11:15:04 +0200
Message-ID: <20100723091549.866454000@de.ibm.com>
References: <20100723091502.678949000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Carsten Otte <cotte@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.17.164]:40015 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754698Ab0GWJPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 05:15:52 -0400
Content-Disposition: inline; filename=613-qeth-clear-mac-bits.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carsten Otte <cotte@de.ibm.com>

This patch fixes a problem that occurs when switching from layer 3 to layer 2
mode. Resetting this mac_bits makes sure that we retrieve our mac address from
the card, otherwise the interface simply would'nt work.

Signed-off-by: Carsten Otte <cotte@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_sys.c |    1 +
 1 file changed, 1 insertion(+)

diff -urpN linux-2.6/drivers/s390/net/qeth_core_sys.c linux-2.6-patched/drivers/s390/net/qeth_core_sys.c
--- linux-2.6/drivers/s390/net/qeth_core_sys.c	2010-07-22 10:22:12.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core_sys.c	2010-07-22 10:22:34.000000000 +0200
@@ -433,6 +433,7 @@ static ssize_t qeth_dev_layer2_store(str
 	if (card->options.layer2 == newdis)
 		goto out;
 	else {
+		card->info.mac_bits  = 0;
 		if (card->discipline.ccwgdriver) {
 			card->discipline.ccwgdriver->remove(card->gdev);
 			qeth_core_free_discipline(card);

