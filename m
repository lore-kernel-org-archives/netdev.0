From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net-next 3/3] ibmvnic: Let users change net device features
Date: Tue, 17 Oct 2017 12:36:56 -0500
Message-ID: <1508261816-3145-4-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1508261816-3145-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:50316 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1755745AbdJQRhP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 13:37:15 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9HHapgJ051670
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 13:37:14 -0400
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2dnkbrhtbc-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 13:37:14 -0400
Received: from localhost
        by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Tue, 17 Oct 2017 11:37:13 -0600
In-Reply-To: <1508261816-3145-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index aedb81c..b991703 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -3019,6 +3019,8 @@ static void handle_query_ip_offload_rsp(struct ibmvnic_adapter *adapter)
 	if (buf->large_tx_ipv6)
 		adapter->netdev->features |= NETIF_F_TSO6;
 
+	adapter->netdev->hw_features |= adapter->netdev->features;
+
 	memset(&crq, 0, sizeof(crq));
 	crq.control_ip_offload.first = IBMVNIC_CRQ_CMD;
 	crq.control_ip_offload.cmd = CONTROL_IP_OFFLOAD;
-- 
1.8.3.1
