From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 4/7] ibmvnic: Unmap longer term buffer before free
Date: Sun, 09 Apr 2017 00:11:50 -0400
Message-ID: <20170409041150.47642.41260.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
References: <20170409040328.47642.33535.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, muvic@linux.vnet.ibm.com
To: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:44739 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751125AbdDIEWr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Apr 2017 00:22:47 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v394ImcM024620
        for <netdev@vger.kernel.org>; Sun, 9 Apr 2017 00:22:41 -0400
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29q19scaf9-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sun, 09 Apr 2017 00:22:41 -0400
Received: from localhost
        by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Sun, 9 Apr 2017 00:22:41 -0400
In-Reply-To: <20170409040328.47642.33535.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian King <brking@linux.vnet.ibm.com>

Make sure we unregister long term buffers from the adapter
prior to DMA unmapping it and freeing the buffer. Failure
to do so could result in a DMA to a now invalid address.

Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 2e4d787..5f9aad8 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -193,9 +193,9 @@ static void free_long_term_buff(struct ibmvnic_adapter *adapter,
 	if (!ltb->buff)
 		return;
 
-	dma_free_coherent(dev, ltb->size, ltb->buff, ltb->addr);
 	if (!adapter->failover)
 		send_request_unmap(adapter, ltb->map_id);
+	dma_free_coherent(dev, ltb->size, ltb->buff, ltb->addr);
 }
 
 static void replenish_rx_pool(struct ibmvnic_adapter *adapter,
