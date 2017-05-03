From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH v4 net-next 09/11] ibmvnic: Continue skb processing after
 skb completion error
Date: Wed, 03 May 2017 14:05:14 -0400
Message-ID: <20170503180513.29742.28168.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170503180246.29742.64039.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:42421 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753424AbdECOQc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 10:16:32 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v43EDYMd054326
        for <netdev@vger.kernel.org>; Wed, 3 May 2017 10:16:32 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2a7fkwvdbk-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 10:16:31 -0400
Received: from localhost
        by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Wed, 3 May 2017 10:16:31 -0400
In-Reply-To: <20170503180246.29742.64039.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is not a need to stop processing skbs if we encounter a
skb that has a receive completion error.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index f1ee377..00c9d5a 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1404,7 +1404,7 @@ static int ibmvnic_poll(struct napi_struct *napi, int budget)
 			/* free the entry */
 			next->rx_comp.first = 0;
 			remove_buff_from_pool(adapter, rx_buff);
-			break;
+			continue;
 		}
 
 		length = be32_to_cpu(next->rx_comp.len);
