From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH] ibmvnic: Call napi_disable instead of napi_enable in
 failure path
Date: Fri, 10 Feb 2017 13:29:06 -0500
Message-ID: <20170210182906.1468.77665.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jallen@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:60571 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751014AbdBJXLY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 18:11:24 -0500
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1AIchMc172861
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 13:38:53 -0500
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
        by mx0b-001b2d01.pphosted.com with ESMTP id 28hf9xjm4c-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 13:38:53 -0500
Received: from localhost
        by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Fri, 10 Feb 2017 13:38:52 -0500
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
        by d01dlp01.pok.ibm.com (Postfix) with ESMTP id B436F38C8041
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 13:38:51 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The failure path in ibmvnic_open() mistakenly makes a second call
to napi_enable instead of calling napi_disable. This can result
in a BUG_ON for any queues that were enabled in the previous call
to napi_enable.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index c125966..a024141 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -505,7 +505,7 @@ static int ibmvnic_open(struct net_device *netdev)
 	adapter->rx_pool = NULL;
 rx_pool_arr_alloc_failed:
 	for (i = 0; i < adapter->req_rx_queues; i++)
-		napi_enable(&adapter->napi[i]);
+		napi_disable(&adapter->napi[i]);
 alloc_napi_failed:
 	return -ENOMEM;
 }
