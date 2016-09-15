From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 6/7] qeth: do not turn on SG per default
Date: Thu, 15 Sep 2016 14:39:26 +0200
Message-ID: <20160915123927.86579-7-ubraun@linux.vnet.ibm.com>
References: <20160915123927.86579-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:43989 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934275AbcIOMjk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 08:39:40 -0400
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8FCXKw4023689
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 08:39:40 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
        by mx0a-001b2d01.pphosted.com with ESMTP id 25fu1du7e7-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 08:39:39 -0400
Received: from localhost
        by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 15 Sep 2016 13:39:37 +0100
In-Reply-To: <20160915123927.86579-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to recent performance measurements, turning on net_device
feature NETIF_F_SG only behaves well, but turning on feature
NETIF_F_GSO shows bad results. Since the kernel activates NETIF_F_GSO
automatically as soon as the driver configures feature NETIF_F_SG, qeth
should not activate feature NETIF_F_SG per default, until the qeth
problems with NETIF_F_GSO are solved.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c | 2 --
 drivers/s390/net/qeth_l3_main.c | 1 -
 2 files changed, 3 deletions(-)

diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 2081c18..bb27058 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -1124,8 +1124,6 @@ static int qeth_l2_setup_netdev(struct qeth_card *card)
 			card->dev->hw_features |= NETIF_F_RXCSUM;
 			card->dev->vlan_features |= NETIF_F_RXCSUM;
 		}
-		/* Turn on SG per default */
-		card->dev->features |= NETIF_F_SG;
 	}
 	card->info.broadcast_capable = 1;
 	qeth_l2_request_initial_mac(card);
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 0cbbc80..c00f6db 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3120,7 +3120,6 @@ static int qeth_l3_setup_netdev(struct qeth_card *card)
 				card->dev->vlan_features = NETIF_F_SG |
 					NETIF_F_RXCSUM | NETIF_F_IP_CSUM |
 					NETIF_F_TSO;
-				card->dev->features = NETIF_F_SG;
 			}
 		}
 	} else if (card->info.type == QETH_CARD_TYPE_IQD) {
-- 
2.8.4
