From: frank.blaschka@de.ibm.com
Subject: [patch 1/5] qeth: layer 3 Oops in ip event handler
Date: Fri, 06 Jun 2008 12:37:44 +0200
Message-ID: <20080606103827.637655000@de.ibm.com>
References: <20080606103743.638691000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:45545 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752272AbYFFKie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 06:38:34 -0400
Content-Disposition: inline; filename=600-qeth-l3-oops.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

The ip event handler may present us non qeth network interfaces.
Add qeth card pointer check.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_l3_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_l3_main.c linux-2.6-patched/drivers/s390/net/qeth_l3_main.c
--- linux-2.6/drivers/s390/net/qeth_l3_main.c	2008-06-06 10:52:45.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l3_main.c	2008-06-06 10:53:11.000000000 +0200
@@ -2070,7 +2070,7 @@ static struct qeth_card *qeth_l3_get_car
 		card = netdev_priv(dev);
 	else if (rc == QETH_VLAN_CARD)
 		card = netdev_priv(vlan_dev_info(dev)->real_dev);
-	if (card->options.layer2)
+	if (card && card->options.layer2)
 		card = NULL;
 	QETH_DBF_TEXT_(TRACE, 4, "%d", rc);
 	return card ;

-- 
