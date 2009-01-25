From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 2/2] netxen: reduce memory footprint
Date: Sat, 24 Jan 2009 20:02:59 -0800
Message-ID: <1232856179-15153-2-git-send-email-dhananjay@netxen.com>
References: <1232856179-15153-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:52637 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756541AbZAYEDE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Jan 2009 23:03:04 -0500
In-Reply-To: <1232856179-15153-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o reduce rx ring size from 8192 to 4096.
o cut down old huge lro buffers.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h         |   12 ++++++------
 drivers/net/netxen/netxen_nic_ethtool.c |    5 ++++-
 2 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index c11c568..a75a310 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -146,7 +146,7 @@
 
 #define MAX_RX_BUFFER_LENGTH		1760
 #define MAX_RX_JUMBO_BUFFER_LENGTH 	8062
-#define MAX_RX_LRO_BUFFER_LENGTH	((48*1024)-512)
+#define MAX_RX_LRO_BUFFER_LENGTH	(8062)
 #define RX_DMA_MAP_LEN			(MAX_RX_BUFFER_LENGTH - 2)
 #define RX_JUMBO_DMA_MAP_LEN	\
 	(MAX_RX_JUMBO_BUFFER_LENGTH - 2)
@@ -207,11 +207,11 @@
 
 #define MAX_CMD_DESCRIPTORS		4096
 #define MAX_RCV_DESCRIPTORS		16384
-#define MAX_CMD_DESCRIPTORS_HOST	(MAX_CMD_DESCRIPTORS / 4)
-#define MAX_RCV_DESCRIPTORS_1G		(MAX_RCV_DESCRIPTORS / 4)
-#define MAX_RCV_DESCRIPTORS_10G		8192
-#define MAX_JUMBO_RCV_DESCRIPTORS	1024
-#define MAX_LRO_RCV_DESCRIPTORS		64
+#define MAX_CMD_DESCRIPTORS_HOST	1024
+#define MAX_RCV_DESCRIPTORS_1G		2048
+#define MAX_RCV_DESCRIPTORS_10G		4096
+#define MAX_JUMBO_RCV_DESCRIPTORS	512
+#define MAX_LRO_RCV_DESCRIPTORS		8
 #define MAX_RCVSTATUS_DESCRIPTORS	MAX_RCV_DESCRIPTORS
 #define MAX_JUMBO_RCV_DESC	MAX_JUMBO_RCV_DESCRIPTORS
 #define MAX_RCV_DESC		MAX_RCV_DESCRIPTORS
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index c0bd40f..0894a7b 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -561,7 +561,10 @@ netxen_nic_get_ringparam(struct net_device *dev, struct ethtool_ringparam *ring)
 	}
 	ring->tx_pending = adapter->max_tx_desc_count;
 
-	ring->rx_max_pending = MAX_RCV_DESCRIPTORS;
+	if (adapter->ahw.board_type == NETXEN_NIC_GBE)
+		ring->rx_max_pending = MAX_RCV_DESCRIPTORS_1G;
+	else
+		ring->rx_max_pending = MAX_RCV_DESCRIPTORS_10G;
 	ring->tx_max_pending = MAX_CMD_DESCRIPTORS_HOST;
 	ring->rx_jumbo_max_pending = MAX_JUMBO_RCV_DESCRIPTORS;
 	ring->rx_mini_max_pending = 0;
-- 
1.6.0.2

