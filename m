From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net] ibmvnic: Free tx/rx scrq pointer array when releasing
 sub-crqs
Date: Wed, 15 Mar 2017 23:38:07 -0400
Message-ID: <20170316033807.13892.10840.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jallen@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:36268 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752035AbdCOWsc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 18:48:32 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2FMiKJR121038
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:48:31 -0400
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2971ku67h2-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:48:30 -0400
Received: from localhost
        by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Wed, 15 Mar 2017 18:48:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The pointer array for the tx/rx sub crqs should be free'ed when
releasing the tx/rx sub crqs.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 5f11b4d..b23d654 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1257,6 +1257,7 @@ static void release_sub_crqs(struct ibmvnic_adapter *adapter)
 				release_sub_crq_queue(adapter,
 						      adapter->tx_scrq[i]);
 			}
+		kfree(adapter->tx_scrq);
 		adapter->tx_scrq = NULL;
 	}
 
@@ -1269,6 +1270,7 @@ static void release_sub_crqs(struct ibmvnic_adapter *adapter)
 				release_sub_crq_queue(adapter,
 						      adapter->rx_scrq[i]);
 			}
+		kfree(adapter->rx_scrq);
 		adapter->rx_scrq = NULL;
 	}
 }
