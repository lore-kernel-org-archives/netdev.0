From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next] ibmvnic: Report errors when failing to release
 sub-crqs
Date: Fri, 14 Apr 2017 12:45:17 -0400
Message-ID: <20170414164517.50438.14612.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:58931 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752529AbdDNM4O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 08:56:14 -0400
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3ECrUSF119131
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 08:56:13 -0400
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29tp4b92nq-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 08:56:12 -0400
Received: from localhost
        by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Fri, 14 Apr 2017 08:56:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

Add reporting of errors when releasing sub-crqs fails.

Signed-off-by: Thomas Falcon <tlfalcon@us.ibm.com>
Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 7ba43cf..7bf3507 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1309,6 +1309,12 @@ static void release_sub_crq_queue(struct ibmvnic_adapter *adapter,
 					scrq->crq_num);
 	} while (rc == H_BUSY || H_IS_LONG_BUSY(rc));
 
+	if (rc) {
+		netdev_err(adapter->netdev,
+			   "Failed to release sub-CRQ %16lx, rc = %ld\n",
+			   scrq->crq_num, rc);
+	}
+
 	dma_unmap_single(dev, scrq->msg_token, 4 * PAGE_SIZE,
 			 DMA_BIDIRECTIONAL);
 	free_pages((unsigned long)scrq->msgs, 2);
