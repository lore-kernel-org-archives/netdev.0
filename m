From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH 2/3 net] ibmvnic: Fix GFP_KERNEL allocation in interrupt context
Date: Mon, 17 Oct 2016 15:28:09 -0500
Message-ID: <1476736090-13588-2-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1476736090-13588-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:42014 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1759341AbcJQU2Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 16:28:24 -0400
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9HKR07A146109
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 16:28:23 -0400
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
        by mx0a-001b2d01.pphosted.com with ESMTP id 265465v5s0-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 16:28:23 -0400
Received: from localhost
        by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Mon, 17 Oct 2016 14:28:22 -0600
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
        by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id B872D1FF002A
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 14:28:00 -0600 (MDT)
Received: from b03ledav004.gho.boulder.ibm.com (b03ledav004.gho.boulder.ibm.com [9.17.130.235])
        by b03cxnp07028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9HKSKTH15270248
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 13:28:20 -0700
Received: from b03ledav004.gho.boulder.ibm.com (unknown [127.0.0.1])
        by IMSVA (Postfix) with ESMTP id 31C407803F
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 14:28:20 -0600 (MDT)
Received: from tlfalcon-workstation.ibm.com (unknown [9.65.83.172])
        by b03ledav004.gho.boulder.ibm.com (Postfix) with ESMTP id 525D078041
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 14:28:17 -0600 (MDT)
In-Reply-To: <1476736090-13588-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index bfe17d9..928bf8a 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1190,7 +1190,7 @@ static struct ibmvnic_sub_crq_queue *init_sub_crq_queue(struct ibmvnic_adapter
 	if (!scrq)
 		return NULL;
 
-	scrq->msgs = (union sub_crq *)__get_free_pages(GFP_KERNEL, 2);
+	scrq->msgs = (union sub_crq *)__get_free_pages(GFP_ATOMIC, 2);
 	memset(scrq->msgs, 0, 4 * PAGE_SIZE);
 	if (!scrq->msgs) {
 		dev_warn(dev, "Couldn't allocate crq queue messages page\n");
-- 
2.7.4
