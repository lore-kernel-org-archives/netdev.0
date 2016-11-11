From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net 1/2] ibmvnic: Unmap ibmvnic_statistics structure
Date: Fri, 11 Nov 2016 11:00:45 -0600
Message-ID: <1478883646-10760-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: mwb@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:53220 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1756165AbcKKRAv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 12:00:51 -0500
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uABGx6uq130374
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 12:00:50 -0500
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
        by mx0a-001b2d01.pphosted.com with ESMTP id 26nfda3evp-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 12:00:50 -0500
Received: from localhost
        by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Fri, 11 Nov 2016 10:00:49 -0700
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
        by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 15C9D1FF0023
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 10:00:27 -0700 (MST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This structure was mapped but never subsequently unmapped.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index f6c9b6d..921c40f 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -3844,6 +3844,9 @@ static int ibmvnic_remove(struct vio_dev *dev)
 	if (adapter->debugfs_dir && !IS_ERR(adapter->debugfs_dir))
 		debugfs_remove_recursive(adapter->debugfs_dir);
 
+	dma_unmap_single(&dev->dev, adapter->stats_token,
+			 sizeof(struct ibmvnic_statistics), DMA_FROM_DEVICE);
+
 	if (adapter->ras_comps)
 		dma_free_coherent(&dev->dev,
 				  adapter->ras_comp_num *
-- 
1.8.3.1
