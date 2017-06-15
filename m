From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH 3/5 net-next] ibmvnic: Sanitize entire SCRQ buffer on reset
Date: Wed, 14 Jun 2017 22:35:46 -0500
Message-ID: <1497497748-14075-3-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1497497748-14075-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: nfont@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:60387 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751711AbdFODgC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 23:36:02 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5F3Y98E110625
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 23:36:01 -0400
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2b39wpbnxr-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 23:36:01 -0400
Received: from localhost
        by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Wed, 14 Jun 2017 23:36:00 -0400
In-Reply-To: <1497497748-14075-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixup a typo so that the entire SCRQ buffer is cleaned.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index d5fbf45..167b47b 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1745,7 +1745,7 @@ static int reset_one_sub_crq_queue(struct ibmvnic_adapter *adapter,
 		scrq->irq = 0;
 	}
 
-	memset(scrq->msgs, 0, 2 * PAGE_SIZE);
+	memset(scrq->msgs, 0, 4 * PAGE_SIZE);
 	scrq->cur = 0;
 
 	rc = h_reg_sub_crq(adapter->vdev->unit_address, scrq->msg_token,
-- 
1.8.5.6
