From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/13] i40e: rename index to port to avoid confusion
Date: Sun, 30 Apr 2017 06:24:41 -0700
Message-ID: <20170430132451.68494-4-jeffrey.t.kirsher@intel.com>
References: <20170430132451.68494-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15380 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1163110AbdD3NY5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Apr 2017 09:24:57 -0400
In-Reply-To: <20170430132451.68494-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The .index field of i40e_udp_port_config represents the udp port number.
Rename this variable to port so that it is more obvious.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c | 10 +++++-----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 70f9458f7a01..0f22c03ec726 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -245,7 +245,7 @@ struct i40e_tc_configuration {
 
 struct i40e_udp_port_config {
 	/* AdminQ command interface expects port number in Host byte order */
-	u16 index;
+	u16 port;
 	u8 type;
 };
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 8f47a31cb2c8..063044268170 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7349,7 +7349,7 @@ static void i40e_sync_udp_filters_subtask(struct i40e_pf *pf)
 	for (i = 0; i < I40E_MAX_PF_UDP_OFFLOAD_PORTS; i++) {
 		if (pf->pending_udp_bitmap & BIT_ULL(i)) {
 			pf->pending_udp_bitmap &= ~BIT_ULL(i);
-			port = pf->udp_ports[i].index;
+			port = pf->udp_ports[i].port;
 			if (port)
 				ret = i40e_aq_add_udp_tunnel(hw, port,
 							pf->udp_ports[i].type,
@@ -7366,7 +7366,7 @@ static void i40e_sync_udp_filters_subtask(struct i40e_pf *pf)
 					i40e_stat_str(&pf->hw, ret),
 					i40e_aq_str(&pf->hw,
 						    pf->hw.aq.asq_last_status));
-				pf->udp_ports[i].index = 0;
+				pf->udp_ports[i].port = 0;
 			}
 		}
 	}
@@ -8953,7 +8953,7 @@ static u8 i40e_get_udp_port_idx(struct i40e_pf *pf, u16 port)
 	u8 i;
 
 	for (i = 0; i < I40E_MAX_PF_UDP_OFFLOAD_PORTS; i++) {
-		if (pf->udp_ports[i].index == port)
+		if (pf->udp_ports[i].port == port)
 			return i;
 	}
 
@@ -9006,7 +9006,7 @@ static void i40e_udp_tunnel_add(struct net_device *netdev,
 	}
 
 	/* New port: add it and mark its index in the bitmap */
-	pf->udp_ports[next_idx].index = port;
+	pf->udp_ports[next_idx].port = port;
 	pf->pending_udp_bitmap |= BIT_ULL(next_idx);
 	pf->flags |= I40E_FLAG_UDP_FILTER_SYNC;
 }
@@ -9047,7 +9047,7 @@ static void i40e_udp_tunnel_del(struct net_device *netdev,
 	/* if port exists, set it to 0 (mark for deletion)
 	 * and make it pending
 	 */
-	pf->udp_ports[idx].index = 0;
+	pf->udp_ports[idx].port = 0;
 	pf->pending_udp_bitmap |= BIT_ULL(idx);
 	pf->flags |= I40E_FLAG_UDP_FILTER_SYNC;
 
-- 
2.12.2
