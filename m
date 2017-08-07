From: John Allen <jallen@linux.vnet.ibm.com>
Subject: [PATCH net-next] ibmvnic: Report rx buffer return codes as netdev_dbg
Date: Mon, 7 Aug 2017 15:42:30 -0500
Message-ID: <21089a62-0b49-ef34-6eb0-33510a5638c0@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Nathan Fontenot <nfont@linux.vnet.ibm.com>,
        Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:52206 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752080AbdHGUmj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 16:42:39 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v77Kd4kr093257
        for <netdev@vger.kernel.org>; Mon, 7 Aug 2017 16:42:38 -0400
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2c6rw3a77b-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 16:42:38 -0400
Received: from localhost
        by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jallen@linux.vnet.ibm.com>;
        Mon, 7 Aug 2017 14:42:37 -0600
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reporting any return code for a receive buffer as an "rx error" only
produces alarming noise and the only values that have been observed to be
used in this field are not error conditions. Change this to a netdev_dbg
with a more descriptive message.

Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>
---
diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 5932160..99576ba 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1579,7 +1579,8 @@ static int ibmvnic_poll(struct napi_struct *napi, int budget)
 							  rx_comp.correlator);
 		/* do error checking */
 		if (next->rx_comp.rc) {
-			netdev_err(netdev, "rx error %x\n", next->rx_comp.rc);
+			netdev_dbg(netdev, "rx buffer returned with rc %x\n",
+				   be16_to_cpu(next->rx_comp.rc));
 			/* free the entry */
 			next->rx_comp.first = 0;
 			remove_buff_from_pool(adapter, rx_buff);
