From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 6/7] ibmvnic: Validate napi exist before disabling
 them
Date: Fri, 21 Apr 2017 15:39:10 -0400
Message-ID: <20170421193910.11030.9896.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170421193627.11030.34813.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:34108 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1041556AbdDUScC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:32:02 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3LFmxe9010875
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 11:50:14 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
        by mx0b-001b2d01.pphosted.com with ESMTP id 29ygefq1g2-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 11:50:14 -0400
Received: from localhost
        by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Fri, 21 Apr 2017 11:50:13 -0400
In-Reply-To: <20170421193627.11030.34813.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Validate that the napi structs exist before trying to disable them
at driver close.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 115f216..5a916a2 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -729,8 +729,10 @@ static int ibmvnic_close(struct net_device *netdev)
 	adapter->closing = true;
 	disable_sub_crqs(adapter);
 
-	for (i = 0; i < adapter->req_rx_queues; i++)
-		napi_disable(&adapter->napi[i]);
+	if (adapter->napi) {
+		for (i = 0; i < adapter->req_rx_queues; i++)
+			napi_disable(&adapter->napi[i]);
+	}
 
 	if (!adapter->failover)
 		netif_tx_stop_all_queues(netdev);
