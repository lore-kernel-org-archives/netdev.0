From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net v1 2/2] ibmvnic: Fix missing brackets in init_sub_crq_irqs
Date: Thu, 27 Oct 2016 12:28:52 -0500
Message-ID: <1477589332-513-2-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1477589332-513-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:52867 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S934688AbcJ0R27 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 13:28:59 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9RHSfgi052203
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 13:28:58 -0400
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
        by mx0b-001b2d01.pphosted.com with ESMTP id 26bmyb4w32-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 13:28:58 -0400
Received: from localhost
        by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Thu, 27 Oct 2016 11:28:57 -0600
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
        by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 7FEE83E40044
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 11:28:55 -0600 (MDT)
Received: from b03ledav006.gho.boulder.ibm.com (b03ledav006.gho.boulder.ibm.com [9.17.130.237])
        by b03cxnp07028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9RHSsQs14287354
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 10:28:55 -0700
Received: from b03ledav006.gho.boulder.ibm.com (unknown [127.0.0.1])
        by IMSVA (Postfix) with ESMTP id C2105C6043
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 11:28:53 -0600 (MDT)
Received: from tlfalcon-workstation.ibm.com (unknown [9.65.84.52])
        by b03ledav006.gho.boulder.ibm.com (Postfix) with ESMTP id 6298DC6037
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 11:28:53 -0600 (MDT)
In-Reply-To: <1477589332-513-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
v1: caught by kbuild bot with -Wmisleading-indentation after
    after submitting previous patch
---
 drivers/net/ethernet/ibm/ibmvnic.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index a922fb9..5f44c55 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1461,14 +1461,16 @@ static int init_sub_crq_irqs(struct ibmvnic_adapter *adapter)
 	return rc;
 
 req_rx_irq_failed:
-	for (j = 0; j < i; j++)
+	for (j = 0; j < i; j++) {
 		free_irq(adapter->rx_scrq[j]->irq, adapter->rx_scrq[j]);
 		irq_dispose_mapping(adapter->rx_scrq[j]->irq);
+	}
 	i = adapter->req_tx_queues;
 req_tx_irq_failed:
-	for (j = 0; j < i; j++)
+	for (j = 0; j < i; j++) {
 		free_irq(adapter->tx_scrq[j]->irq, adapter->tx_scrq[j]);
 		irq_dispose_mapping(adapter->rx_scrq[j]->irq);
+	}
 	release_sub_crqs_no_irqs(adapter);
 	return rc;
 }
-- 
2.7.4
