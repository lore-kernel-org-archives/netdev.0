From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 04/13] qeth: fill netdevice->gso_* attributes accurately
Date: Thu, 16 Jun 2016 16:18:54 +0200
Message-ID: <1466086743-55484-5-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1466086743-55484-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:30623 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754379AbcFPOTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 10:19:30 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5GEIwpi105622
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:19:29 -0400
Received: from e06smtp09.uk.ibm.com (e06smtp09.uk.ibm.com [195.75.94.105])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23kqt276w0-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:19:29 -0400
Received: from localhost
	by e06smtp09.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Thu, 16 Jun 2016 15:19:28 +0100
In-Reply-To: <1466086743-55484-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugene Crosser <Eugene.Crosser@ru.ibm.com>

Use QETH_MAX_BUFFER_ELEMENTS(card) instead of constant 16.
Also fill gso_max_segs and gso_min_segs.

Signed-off-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l3_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 86b3bc2..76ddd18 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3217,7 +3217,9 @@ static int qeth_l3_setup_netdev(struct qeth_card *card)
 				NETIF_F_HW_VLAN_CTAG_RX |
 				NETIF_F_HW_VLAN_CTAG_FILTER;
 	netif_keep_dst(card->dev);
-	card->dev->gso_max_size = 15 * PAGE_SIZE;
+	card->dev->gso_max_size = (QETH_MAX_BUFFER_ELEMENTS(card) - 1) *
+				  PAGE_SIZE;
+	card->dev->gso_max_segs = (QETH_MAX_BUFFER_ELEMENTS(card) - 1);
 
 	SET_NETDEV_DEV(card->dev, &card->gdev->dev);
 	netif_napi_add(card->dev, &card->napi, qeth_l3_poll, QETH_NAPI_WEIGHT);
-- 
2.6.6
