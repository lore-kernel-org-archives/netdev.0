From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net v2 2/4] ibmvnic: dispose irq mappings
Date: Fri,  8 Jul 2016 02:09:04 -0500
Message-ID: <1467961746-26023-3-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1467961746-26023-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: jallen@linux.vnet.ibm.com, nfont@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:40488 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753518AbcGHHJS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 03:09:18 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u68795l4141713
	for <netdev@vger.kernel.org>; Fri, 8 Jul 2016 03:09:16 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2415xp11jg-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 03:09:16 -0400
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
	Fri, 8 Jul 2016 01:09:15 -0600
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 874AE19D801C
	for <netdev@vger.kernel.org>; Fri,  8 Jul 2016 01:08:49 -0600 (MDT)
In-Reply-To: <1467961746-26023-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
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
