From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv2 NEXT 2/2] qlcnic: Remove validation for max tx and max rx queues
Date: Wed, 23 Feb 2011 05:21:25 -0800
Message-ID: <1298467285-7201-3-git-send-email-amit.salecha@qlogic.com>
References: <1298467285-7201-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:43525 "EHLO unm84.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753138Ab1BWNVk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 08:21:40 -0500
In-Reply-To: <1298467285-7201-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

Max rx queues and tx queues are governed by fimware.
So driver should not validate these values.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    4 ----
 drivers/net/qlcnic/qlcnic_main.c |    6 ++----
 2 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index fa7f794..dc44564 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -1132,14 +1132,10 @@ struct qlcnic_eswitch {
 #define MAX_BW			100	/* % of link speed */
 #define MAX_VLAN_ID		4095
 #define MIN_VLAN_ID		2
-#define MAX_TX_QUEUES		1
-#define MAX_RX_QUEUES		4
 #define DEFAULT_MAC_LEARN	1
 
 #define IS_VALID_VLAN(vlan)	(vlan >= MIN_VLAN_ID && vlan < MAX_VLAN_ID)
 #define IS_VALID_BW(bw)		(bw <= MAX_BW)
-#define IS_VALID_TX_QUEUES(que)	(que > 0 && que <= MAX_TX_QUEUES)
-#define IS_VALID_RX_QUEUES(que)	(que > 0 && que <= MAX_RX_QUEUES)
 
 struct qlcnic_pci_func_cfg {
 	u16	func_type;
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 4994b94..cd88c7e 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -3653,10 +3653,8 @@ validate_npar_config(struct qlcnic_adapter *adapter,
 		if (adapter->npars[pci_func].type != QLCNIC_TYPE_NIC)
 			return QL_STATUS_INVALID_PARAM;
 
-		if (!IS_VALID_BW(np_cfg[i].min_bw)
-				|| !IS_VALID_BW(np_cfg[i].max_bw)
-				|| !IS_VALID_RX_QUEUES(np_cfg[i].max_rx_queues)
-				|| !IS_VALID_TX_QUEUES(np_cfg[i].max_tx_queues))
+		if (!IS_VALID_BW(np_cfg[i].min_bw) ||
+		    !IS_VALID_BW(np_cfg[i].max_bw))
 			return QL_STATUS_INVALID_PARAM;
 	}
 	return 0;
-- 
1.7.3.2

