From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net 2/4] ibmvnic: dispose irq mappings
Date: Wed,  6 Jul 2016 15:35:16 -0500
Message-ID: <1467837318-31710-3-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1467837318-31710-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: jallen@linux.vnet.ibm.com, nfont@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:46574 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755453AbcGFUf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 16:35:29 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u66KY1oD013732
	for <netdev@vger.kernel.org>; Wed, 6 Jul 2016 16:35:28 -0400
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2415xkyfbn-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 16:35:28 -0400
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
	Wed, 6 Jul 2016 14:35:27 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 0DF4A3E4004C
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2016 14:35:24 -0600 (MDT)
In-Reply-To: <1467837318-31710-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IRQ mappings were not being properly disposed when releasing sub-CRQ's.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index f04830e..79d2ab3 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1257,6 +1257,7 @@ static void release_sub_crqs(struct ibmvnic_adapter *adapter)
 			if (adapter->tx_scrq[i]) {
 				free_irq(adapter->tx_scrq[i]->irq,
 					 adapter->tx_scrq[i]);
+				irq_dispose_mapping(adapter->tx_scrq[i]->irq);
 				release_sub_crq_queue(adapter,
 						      adapter->tx_scrq[i]);
 			}
@@ -1268,6 +1269,7 @@ static void release_sub_crqs(struct ibmvnic_adapter *adapter)
 			if (adapter->rx_scrq[i]) {
 				free_irq(adapter->rx_scrq[i]->irq,
 					 adapter->rx_scrq[i]);
+				irq_dispose_mapping(adapter->rx_scrq[i]->irq);
 				release_sub_crq_queue(adapter,
 						      adapter->rx_scrq[i]);
 			}
-- 
1.8.3.1
