From: John Allen <jallen@linux.vnet.ibm.com>
Subject: [PATCH net] ibmvnic: Start completion queue negotiation at
 server-provided optimum values
Date: Mon, 7 Nov 2016 14:27:28 -0600
Message-ID: <7d5c1364-7167-8d69-d9d4-bc89d19f8457@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:59233 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751564AbcKGU1f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 15:27:35 -0500
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uA7KOBxV132648
        for <netdev@vger.kernel.org>; Mon, 7 Nov 2016 15:27:35 -0500
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
        by mx0a-001b2d01.pphosted.com with ESMTP id 26jvt81nce-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2016 15:27:35 -0500
Received: from localhost
        by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jallen@linux.vnet.ibm.com>;
        Mon, 7 Nov 2016 13:27:34 -0700
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
        by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id EF6711FF0029
        for <netdev@vger.kernel.org>; Mon,  7 Nov 2016 13:27:09 -0700 (MST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the opt_* fields to determine the starting point for negotiating the
number of tx/rx completion queues with the vnic server. These contain the
number of queues that the vnic server estimates that it will be able to
allocate. While renegotiation may still occur, using the opt_* fields will
reduce the number of times this needs to happen and will prevent driver
probe timeout on systems using large numbers of ibmvnic client devices per
vnic port.

Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>
---
diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index d54405b4..ee66164 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1493,9 +1493,8 @@ static void init_sub_crqs(struct ibmvnic_adapter *adapter, int retry)
 		    adapter->max_rx_add_entries_per_subcrq > entries_page ?
 		    entries_page : adapter->max_rx_add_entries_per_subcrq;

-		/* Choosing the maximum number of queues supported by firmware*/
-		adapter->req_tx_queues = adapter->max_tx_queues;
-		adapter->req_rx_queues = adapter->max_rx_queues;
+		adapter->req_tx_queues = adapter->opt_tx_comp_sub_queues;
+		adapter->req_rx_queues = adapter->opt_rx_comp_queues;
 		adapter->req_rx_add_queues = adapter->max_rx_add_queues;

 		adapter->req_mtu = adapter->max_mtu;
