From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH 1/5 net-next] ibmvnic: Activate disabled RX buffer pools on reset
Date: Wed, 14 Jun 2017 22:35:44 -0500
Message-ID: <1497497748-14075-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: nfont@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:60309 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751555AbdFODf7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 23:35:59 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5F3YAXC110668
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 23:35:59 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2b39wpbnwq-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 23:35:58 -0400
Received: from localhost
        by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Wed, 14 Jun 2017 23:35:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RX buffer pools are disabled while awaiting a device
reset if firmware indicates that the resource is closed.

This patch fixes a bug where pools were not being 
subsequently enabled after the device reset, causing
the device to become inoperable.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

---
 drivers/net/ethernet/ibm/ibmvnic.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 7e585fd..000cd15 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -383,6 +383,7 @@ static int reset_rx_pools(struct ibmvnic_adapter *adapter)
 		atomic_set(&rx_pool->available, 0);
 		rx_pool->next_alloc = 0;
 		rx_pool->next_free = 0;
+		rx_pool->active = 1;
 	}
 
 	return 0;
-- 
1.8.5.6
