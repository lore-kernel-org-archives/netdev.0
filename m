From: frank.blaschka@de.ibm.com
Subject: [patch 4/5] [PATCH] qeth: display service_level info only when valid.
Date: Wed, 26 Aug 2009 14:01:09 +0200
Message-ID: <20090826120136.382656000@de.ibm.com>
References: <20090826120105.727838000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Klaus-Dieter Wacker <kdwacker@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.17.167]:44178 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752903AbZHZMBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 08:01:38 -0400
Content-Disposition: inline; filename=610-qeth-service-level.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Klaus-Dieter Wacker <kdwacker@de.ibm.com>

qeth displayed an entry in /proc/service_level even when no valid
MCL-string was available (the MCL info is blank). The change is to
create an entry in /proc/service_level only when MCL-string is
non-zero.

Signed-off-by: Klaus-Dieter Wacker <kdwacker@de.ibm.com> 
---

 drivers/s390/net/qeth_core_main.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: git_net-next/drivers/s390/net/qeth_core_main.c
===================================================================
--- git_net-next.orig/drivers/s390/net/qeth_core_main.c
+++ git_net-next/drivers/s390/net/qeth_core_main.c
@@ -1160,8 +1160,9 @@ static void qeth_core_sl_print(struct se
 {
 	struct qeth_card *card = container_of(slr, struct qeth_card,
 					qeth_service_level);
-	seq_printf(m, "qeth: %s firmware level %s\n", CARD_BUS_ID(card),
-			card->info.mcl_level);
+	if (card->info.mcl_level[0])
+		seq_printf(m, "qeth: %s firmware level %s\n",
+			CARD_BUS_ID(card), card->info.mcl_level);
 }
 
 static struct qeth_card *qeth_alloc_card(void)

