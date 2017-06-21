From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH 1/2 net-next] ibmvnic: Fix incorrectly defined ibmvnic_request_map_rsp structure
Date: Wed, 21 Jun 2017 14:53:00 -0500
Message-ID: <1498074781-17565-2-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1498074781-17565-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: nfont@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:49894 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751038AbdFUTxM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 15:53:12 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5LJnY9R037605
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 15:53:11 -0400
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2b7uyf1pux-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 15:53:11 -0400
Received: from localhost
        by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Wed, 21 Jun 2017 13:53:10 -0600
In-Reply-To: <1498074781-17565-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reserved area should be eight bytes in length instead of four.
As a result, the return codes in the REQUEST_MAP_RSP descriptors
were not being properly handled.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.h b/drivers/net/ethernet/ibm/ibmvnic.h
index 7e2300e..2d525c7 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.h
+++ b/drivers/net/ethernet/ibm/ibmvnic.h
@@ -595,7 +595,7 @@ struct ibmvnic_request_map_rsp {
 	u8 cmd;
 	u8 reserved1;
 	u8 map_id;
-	u8 reserved2[4];
+	u8 reserved2[8];
 	struct ibmvnic_rc rc;
 } __packed __aligned(8);
 
-- 
1.8.5.6
