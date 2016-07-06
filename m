From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net 1/4] ibmvnic: properly start and stop tx queues
Date: Wed,  6 Jul 2016 15:35:15 -0500
Message-ID: <1467837318-31710-2-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1467837318-31710-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: jallen@linux.vnet.ibm.com, nfont@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:13457 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755783AbcGFUfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 16:35:40 -0400
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u66KY3ZH059099
	for <netdev@vger.kernel.org>; Wed, 6 Jul 2016 16:35:39 -0400
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2415xmf9t5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 16:35:39 -0400
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
	Wed, 6 Jul 2016 14:35:38 -0600
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id E21D219D803F
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2016 14:34:58 -0600 (MDT)
In-Reply-To: <1467837318-31710-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since ibmvnic uses multiple tx queues, start and stop all queues when
opening and closing devices.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index ecdb685..f04830e 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -469,7 +469,8 @@ static int ibmvnic_open(struct net_device *netdev)
 	crq.logical_link_state.link_state = IBMVNIC_LOGICAL_LNK_UP;
 	ibmvnic_send_crq(adapter, &crq);
 
-	netif_start_queue(netdev);
+	netif_tx_start_all_queues(netdev);
+
 	return 0;
 
 bounce_map_failed:
@@ -519,7 +520,7 @@ static int ibmvnic_close(struct net_device *netdev)
 	for (i = 0; i < adapter->req_rx_queues; i++)
 		napi_disable(&adapter->napi[i]);
 
-	netif_stop_queue(netdev);
+	netif_tx_stop_all_queues(netdev);
 
 	if (adapter->bounce_buffer) {
 		if (!dma_mapping_error(dev, adapter->bounce_buffer_dma)) {
-- 
1.8.3.1
