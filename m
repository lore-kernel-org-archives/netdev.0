From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 06/13] qeth: enable scatter/gather by default
Date: Thu, 16 Jun 2016 16:18:56 +0200
Message-ID: <1466086743-55484-7-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1466086743-55484-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:48615 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754469AbcFPOTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 10:19:34 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5GEIw7S115110
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:19:33 -0400
Received: from e06smtp09.uk.ibm.com (e06smtp09.uk.ibm.com [195.75.94.105])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23krwbw0g4-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:19:33 -0400
Received: from localhost
	by e06smtp09.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Thu, 16 Jun 2016 15:19:30 +0100
In-Reply-To: <1466086743-55484-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugene Crosser <Eugene.Crosser@ru.ibm.com>

Set scatter/gather ON by default on OSA, for both layer 2 and
layer 3 modes. We always use fragmentation over QDIO anyway,
so let the upper layers of the stack take advantage of that.

Signed-off-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Lakhvich Dmitriy <ldmitriy@ru.ibm.com>
Reviewed-by: Thomas Richter <tmricht@de.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c | 4 ++--
 drivers/s390/net/qeth_l3_main.c | 3 ++-
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index ec163e4..e24627f 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -1140,8 +1140,8 @@ static int qeth_l2_setup_netdev(struct qeth_card *card)
 	if (card->info.type == QETH_CARD_TYPE_OSD && !card->info.guestlan) {
 		card->dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
 					 NETIF_F_SG;
-		/* Turn on RX offloading per default */
-		card->dev->features |= NETIF_F_RXCSUM;
+		/* Turn on RX offloading and SG per default */
+		card->dev->features |= NETIF_F_RXCSUM | NETIF_F_SG;
 	}
 	card->info.broadcast_capable = 1;
 	qeth_l2_request_initial_mac(card);
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 76ddd18..0afdb14 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3191,7 +3191,8 @@ static int qeth_l3_setup_netdev(struct qeth_card *card)
 				card->dev->hw_features = NETIF_F_SG |
 					NETIF_F_RXCSUM | NETIF_F_IP_CSUM |
 					NETIF_F_TSO;
-				card->dev->features = NETIF_F_RXCSUM;
+				card->dev->features = NETIF_F_RXCSUM |
+						      NETIF_F_SG;
 			}
 		}
 	} else if (card->info.type == QETH_CARD_TYPE_IQD) {
-- 
2.6.6
