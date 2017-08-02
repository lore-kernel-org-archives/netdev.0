From: John Allen <jallen@linux.vnet.ibm.com>
Subject: [PATCH net-next 2/4] ibmvnic: Convert vnic server reported statistics
 to cpu endian
Date: Wed, 2 Aug 2017 16:45:28 -0500
Message-ID: <f4fb844b-5c87-5ac3-3966-16cde9854269@linux.vnet.ibm.com>
References: <f89ddaab-fe27-2b3c-5b3a-3aaac1e60ae3@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
        Nathan Fontenot <nfont@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:48884 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750725AbdHBVpd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 17:45:33 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v72LZ5Dd122810
        for <netdev@vger.kernel.org>; Wed, 2 Aug 2017 17:45:32 -0400
Received: from e16.ny.us.ibm.com (e16.ny.us.ibm.com [129.33.205.206])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2c3j09e4gu-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 17:45:32 -0400
Received: from localhost
        by e16.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jallen@linux.vnet.ibm.com>;
        Wed, 2 Aug 2017 17:45:32 -0400
In-Reply-To: <f89ddaab-fe27-2b3c-5b3a-3aaac1e60ae3@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The vnic server reports the statistics buffer in big endian format and must
be converted to cpu endian in order to be displayed correctly on little
endian lpars.

Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>
---
diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index a264c6992328..285ea23bac6a 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1807,7 +1807,8 @@ static void ibmvnic_get_ethtool_stats(struct net_device *dev,
 	wait_for_completion(&adapter->stats_done);

 	for (i = 0; i < ARRAY_SIZE(ibmvnic_stats); i++)
-		data[i] = IBMVNIC_GET_STAT(adapter, ibmvnic_stats[i].offset);
+		data[i] = be64_to_cpu(IBMVNIC_GET_STAT(adapter,
+						ibmvnic_stats[i].offset));

 	for (j = 0; j < adapter->req_tx_queues; j++) {
 		data[i] = adapter->tx_stats_buffers[j].packets;
