From: John Allen <jallen@linux.vnet.ibm.com>
Subject: [PATCH net-next 4/4] ibmvnic: Implement .get_channels
Date: Wed, 2 Aug 2017 16:47:17 -0500
Message-ID: <68feac4e-73d3-a689-6199-d42c72785c14@linux.vnet.ibm.com>
References: <f89ddaab-fe27-2b3c-5b3a-3aaac1e60ae3@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
        Nathan Fontenot <nfont@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:44111 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751161AbdHBVrX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 17:47:23 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v72LYQkP026844
        for <netdev@vger.kernel.org>; Wed, 2 Aug 2017 17:47:22 -0400
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2c3nyutn4j-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 17:47:22 -0400
Received: from localhost
        by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jallen@linux.vnet.ibm.com>;
        Wed, 2 Aug 2017 17:47:21 -0400
In-Reply-To: <f89ddaab-fe27-2b3c-5b3a-3aaac1e60ae3@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement .get_channels (ethtool -l) functionality

Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>
---
diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 1cc5db94e40f..130aee7b5c32 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1741,6 +1741,21 @@ static void ibmvnic_get_ringparam(struct net_device *netdev,
 	ring->rx_jumbo_pending = 0;
 }

+static void ibmvnic_get_channels(struct net_device *netdev,
+				 struct ethtool_channels *channels)
+{
+	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
+
+	channels->max_rx = adapter->max_rx_queues;
+	channels->max_tx = adapter->max_tx_queues;
+	channels->max_other = 0;
+	channels->max_combined = 0;
+	channels->rx_count = adapter->req_rx_queues;
+	channels->tx_count = adapter->req_tx_queues;
+	channels->other_count = 0;
+	channels->combined_count = 0;
+}
+
 static void ibmvnic_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 {
 	struct ibmvnic_adapter *adapter = netdev_priv(dev);
@@ -1837,6 +1852,7 @@ static const struct ethtool_ops ibmvnic_ethtool_ops = {
 	.set_msglevel		= ibmvnic_set_msglevel,
 	.get_link		= ibmvnic_get_link,
 	.get_ringparam		= ibmvnic_get_ringparam,
+	.get_channels		= ibmvnic_get_channels,
 	.get_strings            = ibmvnic_get_strings,
 	.get_sset_count         = ibmvnic_get_sset_count,
 	.get_ethtool_stats	= ibmvnic_get_ethtool_stats,
