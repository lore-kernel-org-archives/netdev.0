From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next] ibmvnic: Remove netdev notify for failover resets
Date: Mon, 12 Jun 2017 20:47:45 -0400
Message-ID: <20170613004745.52815.48392.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:59416 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752065AbdFLU7u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 16:59:50 -0400
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5CKwg1M106150
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 16:59:50 -0400
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2b1w4ry8dd-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 16:59:49 -0400
Received: from localhost
        by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Mon, 12 Jun 2017 16:59:48 -0400
Received: from b01ledav001.gho.pok.ibm.com (b01ledav001.gho.pok.ibm.com [9.57.199.106])
        by b01cxnp23033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v5CKxldO16515320
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 20:59:47 GMT
Received: from b01ledav001.gho.pok.ibm.com (unknown [127.0.0.1])
        by IMSVA (Postfix) with ESMTP id 612E428041
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 16:59:41 -0400 (EDT)
Received: from ltcalpine2-lp23.aus.stglabs.ibm.com (unknown [9.40.195.232])
        by b01ledav001.gho.pok.ibm.com (Postfix) with ESMTP id 362BD2803A
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 16:59:41 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When handling a driver reset due to a failover of the backing
server on the vios, doing the netdev_notify_peers() can cause
network traffic to stall or halt. Remove the netdev notify call
for failover resets.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 7d84e20..1c647c0 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1364,7 +1364,9 @@ static int do_reset(struct ibmvnic_adapter *adapter,
 	for (i = 0; i < adapter->req_rx_queues; i++)
 		napi_schedule(&adapter->napi[i]);
 
-	netdev_notify_peers(netdev);
+	if (adapter->reset_reason != VNIC_RESET_FAILOVER)
+		netdev_notify_peers(netdev);
+
 	return 0;
 }
 
