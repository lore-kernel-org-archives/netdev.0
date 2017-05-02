From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH v3 net-next 09/11] ibmvnic: Continue skb processing after
 skb completion error
Date: Tue, 02 May 2017 14:53:05 -0400
Message-ID: <20170502185305.28214.81278.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170502185006.28214.89072.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:54175 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751611AbdEBPEi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:04:38 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v42F3wRt078350
        for <netdev@vger.kernel.org>; Tue, 2 May 2017 11:04:22 -0400
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2a6u64vjtk-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 11:04:22 -0400
Received: from localhost
        by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Tue, 2 May 2017 11:04:21 -0400
In-Reply-To: <20170502185006.28214.89072.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is not a need to stop processing skbs if we encounter a
skb that has a receive completion error.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 2cf1b64..4b2e128 100644
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
