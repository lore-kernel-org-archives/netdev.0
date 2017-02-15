From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net] ibmvnic: Fix endian error when requesting device capabilities
Date: Wed, 15 Feb 2017 10:32:11 -0600
Message-ID: <1487176331-16256-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: nfont@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:52281 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751223AbdBOQcY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 11:32:24 -0500
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1FGTF9Z071349
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 11:32:23 -0500
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
        by mx0a-001b2d01.pphosted.com with ESMTP id 28mq9k1spa-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 11:32:22 -0500
Received: from localhost
        by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Wed, 15 Feb 2017 09:32:21 -0700
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
        by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 427C93E40048
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 09:32:18 -0700 (MST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a vNIC client driver requests a faulty device setting, the
server returns an acceptable value for the client to request.
This 64 bit value was incorrectly being swapped as a 32 bit value,
resulting in loss of data. This patch corrects that by using
the 64 bit swap function.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 5b66b4f..158b49a 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -2389,10 +2389,10 @@ static void handle_request_cap_rsp(union ibmvnic_crq *crq,
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
