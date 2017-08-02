From: John Allen <jallen@linux.vnet.ibm.com>
Subject: [PATCH net-next 3/4] ibmvnic: Implement .get_ringparam
Date: Wed, 2 Aug 2017 16:46:30 -0500
Message-ID: <140273c8-0329-851d-8363-c53efa99bf2d@linux.vnet.ibm.com>
References: <f89ddaab-fe27-2b3c-5b3a-3aaac1e60ae3@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
        Nathan Fontenot <nfont@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:39751 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751600AbdHBVqg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 17:46:36 -0400
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v72Lk26r129333
        for <netdev@vger.kernel.org>; Wed, 2 Aug 2017 17:46:36 -0400
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2c3ft6w80a-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 17:46:35 -0400
Received: from localhost
        by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jallen@linux.vnet.ibm.com>;
        Wed, 2 Aug 2017 17:46:34 -0400
In-Reply-To: <f89ddaab-fe27-2b3c-5b3a-3aaac1e60ae3@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement .get_ringparam (ethtool -g) functionality

Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>
---
diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 285ea23bac6a..1cc5db94e40f 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1729,12 +1729,14 @@ static u32 ibmvnic_get_link(struct net_device *netdev)
 static void ibmvnic_get_ringparam(struct net_device *netdev,
 				  struct ethtool_ringparam *ring)
 {
-	ring->rx_max_pending = 0;
-	ring->tx_max_pending = 0;
+	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
+
+	ring->rx_max_pending = adapter->max_rx_add_entries_per_subcrq;
+	ring->tx_max_pending = adapter->max_tx_entries_per_subcrq;
 	ring->rx_mini_max_pending = 0;
 	ring->rx_jumbo_max_pending = 0;
-	ring->rx_pending = 0;
-	ring->tx_pending = 0;
+	ring->rx_pending = adapter->req_rx_add_entries_per_subcrq;
+	ring->tx_pending = adapter->req_tx_entries_per_subcrq;
 	ring->rx_mini_pending = 0;
 	ring->rx_jumbo_pending = 0;
 }
