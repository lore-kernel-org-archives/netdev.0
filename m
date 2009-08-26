From: frank.blaschka@de.ibm.com
Subject: [patch 2/5] [PATCH] qeth: scheduling while atomic during ifconfig online sequence
Date: Wed, 26 Aug 2009 14:01:07 +0200
Message-ID: <20090826120136.122811000@de.ibm.com>
References: <20090826120105.727838000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8-bp.emea.ibm.com ([195.212.17.168]:41126 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756078AbZHZMBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 08:01:35 -0400
Content-Disposition: inline; filename=606-qeth-online-sequence.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

In case the IP address list contains entries (not removed when the device was set
offline) this entries should be registered next time the device is brought online.
In the past this was done implicitly with the device open call but since we wait
in the set IPv4 IPA and the device open common code holds various locks this
does not work any longer.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_l3_main.c |    1 +
 1 file changed, 1 insertion(+)

Index: git_net-next/drivers/s390/net/qeth_l3_main.c
===================================================================
--- git_net-next.orig/drivers/s390/net/qeth_l3_main.c
+++ git_net-next/drivers/s390/net/qeth_l3_main.c
@@ -3180,6 +3180,7 @@ static int __qeth_l3_set_online(struct c
 	netif_carrier_on(card->dev);
 
 	qeth_set_allowed_threads(card, 0xffffffff, 0);
+	qeth_l3_set_ip_addr_list(card);
 	if (recover_flag == CARD_STATE_RECOVER) {
 		if (recovery_mode)
 			qeth_l3_open(card->dev);

