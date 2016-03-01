From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net] ibmvnic: Fix ibmvnic_capability struct
Date: Tue,  1 Mar 2016 10:20:09 -0600
Message-ID: <1456849209-4992-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:39784 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075AbcCAQUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 11:20:17 -0500
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
	Tue, 1 Mar 2016 09:20:15 -0700
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id EE9E73E4004C
	for <netdev@vger.kernel.org>; Tue,  1 Mar 2016 09:20:11 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u21GKBpl27197542
	for <netdev@vger.kernel.org>; Tue, 1 Mar 2016 09:20:11 -0700
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u21GKBZi004722
	for <netdev@vger.kernel.org>; Tue, 1 Mar 2016 09:20:11 -0700
Received: from tlfalcon-workstation.austin.ibm.com (tlfalcon-workstation.austin.ibm.com [9.41.92.209])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVin) with ESMTP id u21GK9qk004564
	for <netdev@vger.kernel.org>; Tue, 1 Mar 2016 09:20:10 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ibmvnic_capability struct was defined incorrectly. The last two
elements of the struct are in the wrong order.  In addition, the number
element should be 64-bit. Byteswapping functions are updated
as well.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 62 +++++++++++++++++++-------------------
 drivers/net/ethernet/ibm/ibmvnic.h |  4 +--
 2 files changed, 32 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 7d657084..6e9e16ee 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1348,44 +1348,44 @@ static void init_sub_crqs(struct ibmvnic_adapter *adapter, int retry)
 	crq.request_capability.cmd = REQUEST_CAPABILITY;
 
 	crq.request_capability.capability = cpu_to_be16(REQ_TX_QUEUES);
-	crq.request_capability.number = cpu_to_be32(adapter->req_tx_queues);
+	crq.request_capability.number = cpu_to_be64(adapter->req_tx_queues);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.request_capability.capability = cpu_to_be16(REQ_RX_QUEUES);
-	crq.request_capability.number = cpu_to_be32(adapter->req_rx_queues);
+	crq.request_capability.number = cpu_to_be64(adapter->req_rx_queues);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.request_capability.capability = cpu_to_be16(REQ_RX_ADD_QUEUES);
-	crq.request_capability.number = cpu_to_be32(adapter->req_rx_add_queues);
+	crq.request_capability.number = cpu_to_be64(adapter->req_rx_add_queues);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.request_capability.capability =
 	    cpu_to_be16(REQ_TX_ENTRIES_PER_SUBCRQ);
 	crq.request_capability.number =
-	    cpu_to_be32(adapter->req_tx_entries_per_subcrq);
+	    cpu_to_be64(adapter->req_tx_entries_per_subcrq);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.request_capability.capability =
 	    cpu_to_be16(REQ_RX_ADD_ENTRIES_PER_SUBCRQ);
 	crq.request_capability.number =
-	    cpu_to_be32(adapter->req_rx_add_entries_per_subcrq);
+	    cpu_to_be64(adapter->req_rx_add_entries_per_subcrq);
 	ibmvnic_send_crq(adapter, &crq);
 
 	crq.request_capability.capability = cpu_to_be16(REQ_MTU);
-	crq.request_capability.number = cpu_to_be32(adapter->req_mtu);
+	crq.request_capability.number = cpu_to_be64(adapter->req_mtu);
 	ibmvnic_send_crq(adapter, &crq);
 
 	if (adapter->netdev->flags & IFF_PROMISC) {
 		if (adapter->promisc_supported) {
 			crq.request_capability.capability =
 			    cpu_to_be16(PROMISC_REQUESTED);
-			crq.request_capability.number = cpu_to_be32(1);
+			crq.request_capability.number = cpu_to_be64(1);
 			ibmvnic_send_crq(adapter, &crq);
 		}
 	} else {
 		crq.request_capability.capability =
 		    cpu_to_be16(PROMISC_REQUESTED);
-		crq.request_capability.number = cpu_to_be32(0);
+		crq.request_capability.number = cpu_to_be64(0);
 		ibmvnic_send_crq(adapter, &crq);
 	}
 
@@ -2312,93 +2312,93 @@ static void handle_query_cap_rsp(union ibmvnic_crq *crq,
 	switch (be16_to_cpu(crq->query_capability.capability)) {
 	case MIN_TX_QUEUES:
 		adapter->min_tx_queues =
-		    be32_to_cpu(crq->query_capability.number);
+		    be64_to_cpu(crq->query_capability.number);
 		netdev_dbg(netdev, "min_tx_queues = %lld\n",
 			   adapter->min_tx_queues);
 		break;
 	case MIN_RX_QUEUES:
 		adapter->min_rx_queues =
-		    be32_to_cpu(crq->query_capability.number);
+		    be64_to_cpu(crq->query_capability.number);
 		netdev_dbg(netdev, "min_rx_queues = %lld\n",
 			   adapter->min_rx_queues);
 		break;
 	case MIN_RX_ADD_QUEUES:
 		adapter->min_rx_add_queues =
-		    be32_to_cpu(crq->query_capability.number);
+		    be64_to_cpu(crq->query_capability.number);
 		netdev_dbg(netdev, "min_rx_add_queues = %lld\n",
 			   adapter->min_rx_add_queues);
 		break;
 	case MAX_TX_QUEUES:
 		adapter->max_tx_queues =
-		    be32_to_cpu(crq->query_capability.number);
+		    be64_to_cpu(crq->query_capability.number);
 		netdev_dbg(netdev, "max_tx_queues = %lld\n",
 			   adapter->max_tx_queues);
 		break;
 	case MAX_RX_QUEUES:
 		adapter->max_rx_queues =
-		    be32_to_cpu(crq->query_capability.number);
+		    be64_to_cpu(crq->query_capability.number);
 		netdev_dbg(netdev, "max_rx_queues = %lld\n",
 			   adapter->max_rx_queues);
 		break;
 	case MAX_RX_ADD_QUEUES:
 		adapter->max_rx_add_queues =
-		    be32_to_cpu(crq->query_capability.number);
+		    be64_to_cpu(crq->query_capability.number);
 		netdev_dbg(netdev, "max_rx_add_queues = %lld\n",
 			   adapter->max_rx_add_queues);
 		break;
 	case MIN_TX_ENTRIES_PER_SUBCRQ:
 		adapter->min_tx_entries_per_subcrq =
-		    be32_to_cpu(crq->query_capability.number);
+		    be64_to_cpu(crq->query_capability.number);
 		netdev_dbg(netdev, "min_tx_entries_per_subcrq = %lld\n",
 			   adapter->min_tx_entries_per_subcrq);
 		break;
 	case MIN_RX_ADD_ENTRIES_PER_SUBCRQ:
 		adapter->min_rx_add_entries_per_subcrq =
-		    be32_to_cpu(crq->query_capability.number);
+		    be64_to_cpu(crq->query_capability.number);
 		netdev_dbg(netdev, "min_rx_add_entrs_per_subcrq = %lld\n",
 			   adapter->min_rx_add_entries_per_subcrq);
 		break;
 	case MAX_TX_ENTRIES_PER_SUBCRQ:
 		adapter->max_tx_entries_per_subcrq =
-		    be32_to_cpu(crq->query_capability.number);
+		    be64_to_cpu(crq->query_capability.number);
 		netdev_dbg(netdev, "max_tx_entries_per_subcrq = %lld\n",
 			   adapter->max_tx_entries_per_subcrq);
 		break;
 	case MAX_RX_ADD_ENTRIES_PER_SUBCRQ:
 		adapter->max_rx_add_entries_per_subcrq =
-		    be32_to_cpu(crq->query_capability.number);
+		    be64_to_cpu(crq->query_capability.number);
 		netdev_dbg(netdev, "max_rx_add_entrs_per_subcrq = %lld\n",
 			   adapter->max_rx_add_entries_per_subcrq);
 		break;
 	case TCP_IP_OFFLOAD:
 		adapter->tcp_ip_offload =
-		    be32_to_cpu(crq->query_capability.number);
+		    be64_to_cpu(crq->query_capability.number);
 		netdev_dbg(netdev, "tcp_ip_offload = %lld\n",
 			   adapter->tcp_ip_offload);
 		break;
 	case PROMISC_SUPPORTED:
 		adapter->promisc_supported =
-		    be32_to_cpu(crq->query_capability.number);
+		    be64_to_cpu(crq->query_capability.number);
 		netdev_dbg(netdev, "promisc_supported = %lld\n",
 			   adapter->promisc_supported);
 		break;
 	case MIN_MTU:
-		adapter->min_mtu = be32_to_cpu(crq->query_capability.number);
+		adapter->min_mtu = be64_to_cpu(crq->query_capability.number);
 		netdev_dbg(netdev, "min_mtu = %lld\n", adapter->min_mtu);
 		break;
 	case MAX_MTU:
-		adapter->max_mtu = be32_to_cpu(crq->query_capability.number);
+		adapter->max_mtu = be64_to_cpu(crq->query_capability.number);
 		netdev_dbg(netdev, "max_mtu = %lld\n", adapter->max_mtu);
 		break;
 	case MAX_MULTICAST_FILTERS:
 		adapter->max_multicast_filters =
-		    be32_to_cpu(crq->query_capability.number);
+		    be64_to_cpu(crq->query_capability.number);
 		netdev_dbg(netdev, "max_multicast_filters = %lld\n",
 			   adapter->max_multicast_filters);
 		break;
 	case VLAN_HEADER_INSERTION:
 		adapter->vlan_header_insertion =
-		    be32_to_cpu(crq->query_capability.number);
+		    be64_to_cpu(crq->query_capability.number);
 		if (adapter->vlan_header_insertion)
 			netdev->features |= NETIF_F_HW_VLAN_STAG_TX;
 		netdev_dbg(netdev, "vlan_header_insertion = %lld\n",
@@ -2406,43 +2406,43 @@ static void handle_query_cap_rsp(union ibmvnic_crq *crq,
 		break;
 	case MAX_TX_SG_ENTRIES:
 		adapter->max_tx_sg_entries =
-		    be32_to_cpu(crq->query_capability.number);
+		    be64_to_cpu(crq->query_capability.number);
 		netdev_dbg(netdev, "max_tx_sg_entries = %lld\n",
 			   adapter->max_tx_sg_entries);
 		break;
 	case RX_SG_SUPPORTED:
 		adapter->rx_sg_supported =
-		    be32_to_cpu(crq->query_capability.number);
+		    be64_to_cpu(crq->query_capability.number);
 		netdev_dbg(netdev, "rx_sg_supported = %lld\n",
 			   adapter->rx_sg_supported);
 		break;
 	case OPT_TX_COMP_SUB_QUEUES:
 		adapter->opt_tx_comp_sub_queues =
-		    be32_to_cpu(crq->query_capability.number);
+		    be64_to_cpu(crq->query_capability.number);
 		netdev_dbg(netdev, "opt_tx_comp_sub_queues = %lld\n",
 			   adapter->opt_tx_comp_sub_queues);
 		break;
 	case OPT_RX_COMP_QUEUES:
 		adapter->opt_rx_comp_queues =
-		    be32_to_cpu(crq->query_capability.number);
+		    be64_to_cpu(crq->query_capability.number);
 		netdev_dbg(netdev, "opt_rx_comp_queues = %lld\n",
 			   adapter->opt_rx_comp_queues);
 		break;
 	case OPT_RX_BUFADD_Q_PER_RX_COMP_Q:
 		adapter->opt_rx_bufadd_q_per_rx_comp_q =
-		    be32_to_cpu(crq->query_capability.number);
+		    be64_to_cpu(crq->query_capability.number);
 		netdev_dbg(netdev, "opt_rx_bufadd_q_per_rx_comp_q = %lld\n",
 			   adapter->opt_rx_bufadd_q_per_rx_comp_q);
 		break;
 	case OPT_TX_ENTRIES_PER_SUBCRQ:
 		adapter->opt_tx_entries_per_subcrq =
-		    be32_to_cpu(crq->query_capability.number);
+		    be64_to_cpu(crq->query_capability.number);
 		netdev_dbg(netdev, "opt_tx_entries_per_subcrq = %lld\n",
 			   adapter->opt_tx_entries_per_subcrq);
 		break;
 	case OPT_RXBA_ENTRIES_PER_SUBCRQ:
 		adapter->opt_rxba_entries_per_subcrq =
-		    be32_to_cpu(crq->query_capability.number);
+		    be64_to_cpu(crq->query_capability.number);
 		netdev_dbg(netdev, "opt_rxba_entries_per_subcrq = %lld\n",
 			   adapter->opt_rxba_entries_per_subcrq);
 		break;
diff --git a/drivers/net/ethernet/ibm/ibmvnic.h b/drivers/net/ethernet/ibm/ibmvnic.h
index 1242925..1a9993c 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.h
+++ b/drivers/net/ethernet/ibm/ibmvnic.h
@@ -319,10 +319,8 @@ struct ibmvnic_capability {
 	u8 first;
 	u8 cmd;
 	__be16 capability; /* one of ibmvnic_capabilities */
+	__be64 number;
 	struct ibmvnic_rc rc;
-	__be32 number; /*FIX: should be __be64, but I'm getting the least
-			* significant word first
-			*/
 } __packed __aligned(8);
 
 struct ibmvnic_login {
-- 
1.8.3.1
