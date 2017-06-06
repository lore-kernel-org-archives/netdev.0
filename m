From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 7/9] s390/qeth: silence qeth_fix_features()
Date: Tue,  6 Jun 2017 14:33:48 +0200
Message-ID: <20170606123350.13781-8-jwi@linux.vnet.ibm.com>
References: <20170606123350.13781-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:56336 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751538AbdFFMeQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 08:34:16 -0400
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v56CXiFR110906
        for <netdev@vger.kernel.org>; Tue, 6 Jun 2017 08:34:10 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2awkwp832v-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 08:34:10 -0400
Received: from localhost
        by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Tue, 6 Jun 2017 13:34:06 +0100
In-Reply-To: <20170606123350.13781-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Noting the lack of TSO support on every feature change is just silly,
in particular since the requested features might not even affect
NETIF_F_TSO.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core_main.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index a159eb900d03..3cc802cff9d1 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -6390,11 +6390,8 @@ netdev_features_t qeth_fix_features(struct net_device *dev,
 		features &= ~NETIF_F_IP_CSUM;
 	if (!qeth_is_supported(card, IPA_INBOUND_CHECKSUM))
 		features &= ~NETIF_F_RXCSUM;
-	if (!qeth_is_supported(card, IPA_OUTBOUND_TSO)) {
+	if (!qeth_is_supported(card, IPA_OUTBOUND_TSO))
 		features &= ~NETIF_F_TSO;
-		dev_info(&card->gdev->dev, "Outbound TSO not supported on %s\n",
-			 QETH_CARD_IFNAME(card));
-	}
 	/* if the card isn't up, remove features that require hw changes */
 	if (card->state == CARD_STATE_DOWN ||
 	    card->state == CARD_STATE_RECOVER)
-- 
2.11.2
