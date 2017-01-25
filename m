From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net 3/5] ibmvnic: Fix endian error when requesting device capabilites
Date: Wed, 25 Jan 2017 15:02:21 -0600
Message-ID: <1485378143-5084-3-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1485378143-5084-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, wvoigt@us.ibm.com,
        nfont@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:50892 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752072AbdAYVCr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 16:02:47 -0500
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0PKwsgu135210
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 16:02:31 -0500
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
        by mx0a-001b2d01.pphosted.com with ESMTP id 286ua0nw16-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 16:02:31 -0500
Received: from localhost
        by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Wed, 25 Jan 2017 16:02:30 -0500
In-Reply-To: <1485378143-5084-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a IBM VNIC client driver requests a faulty device setting, the
server returns an acceptable value for the client to request.
This 64 bit value was incorrectly being swapped as a 32 bit value,
resulting in loss of data. This patch corrects that by using
the 64 bit swap function.

Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>
Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index f95f6a4..ec4eaed 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -2388,10 +2388,10 @@ static void handle_request_cap_rsp(union ibmvnic_crq *crq,
 	case PARTIALSUCCESS:
 		dev_info(dev, "req=%lld, rsp=%ld in %s queue, retrying.\n",
 			 *req_value,
-			 (long int)be32_to_cpu(crq->request_capability_rsp.
+			 (long int)be64_to_cpu(crq->request_capability_rsp.
 					       number), name);
 		release_sub_crqs_no_irqs(adapter);
-		*req_value = be32_to_cpu(crq->request_capability_rsp.number);
+		*req_value = be64_to_cpu(crq->request_capability_rsp.number);
 		init_sub_crqs(adapter, 1);
 		return;
 	default:
-- 
1.8.3.1
