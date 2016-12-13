From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next 05/27] i40iw: remove use of VLAN_TAG_PRESENT
Date: Tue, 13 Dec 2016 01:12:33 +0100 (CET)
Message-ID: <2c6e6dd5d5f148baf06ead5f836c9143c89c9d53.1481586602.git.mirq-linux@rere.qmqm.pl>
References: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Faisal Latif <faisal.latif@intel.com> (supporter:INTEL RDMA RNIC
        DRIVER)
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:50210 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753339AbcLMAMi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 19:12:38 -0500
In-Reply-To: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 drivers/infiniband/hw/i40iw/i40iw_cm.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/hw/i40iw/i40iw_cm.c b/drivers/infiniband/hw/i40iw/i40iw_cm.c
index 8563769..25cf689 100644
--- a/drivers/infiniband/hw/i40iw/i40iw_cm.c
+++ b/drivers/infiniband/hw/i40iw/i40iw_cm.c
@@ -414,7 +414,7 @@ static struct i40iw_puda_buf *i40iw_form_cm_frame(struct i40iw_cm_node *cm_node,
 			pd_len += MPA_ZERO_PAD_LEN;
 	}
 
-	if (cm_node->vlan_id < VLAN_TAG_PRESENT)
+	if (cm_node->vlan_id <= VLAN_VID_MASK)
 		eth_hlen += 4;
 
 	if (cm_node->ipv4)
@@ -443,7 +443,7 @@ static struct i40iw_puda_buf *i40iw_form_cm_frame(struct i40iw_cm_node *cm_node,
 
 		ether_addr_copy(ethh->h_dest, cm_node->rem_mac);
 		ether_addr_copy(ethh->h_source, cm_node->loc_mac);
-		if (cm_node->vlan_id < VLAN_TAG_PRESENT) {
+		if (cm_node->vlan_id <= VLAN_VID_MASK) {
 			((struct vlan_ethhdr *)ethh)->h_vlan_proto = htons(ETH_P_8021Q);
 			((struct vlan_ethhdr *)ethh)->h_vlan_TCI = htons(cm_node->vlan_id);
 
@@ -472,7 +472,7 @@ static struct i40iw_puda_buf *i40iw_form_cm_frame(struct i40iw_cm_node *cm_node,
 
 		ether_addr_copy(ethh->h_dest, cm_node->rem_mac);
 		ether_addr_copy(ethh->h_source, cm_node->loc_mac);
-		if (cm_node->vlan_id < VLAN_TAG_PRESENT) {
+		if (cm_node->vlan_id <= VLAN_VID_MASK) {
 			((struct vlan_ethhdr *)ethh)->h_vlan_proto = htons(ETH_P_8021Q);
 			((struct vlan_ethhdr *)ethh)->h_vlan_TCI = htons(cm_node->vlan_id);
 			((struct vlan_ethhdr *)ethh)->h_vlan_encapsulated_proto = htons(ETH_P_IPV6);
@@ -3235,7 +3235,7 @@ static void i40iw_init_tcp_ctx(struct i40iw_cm_node *cm_node,
 
 	tcp_info->flow_label = 0;
 	tcp_info->snd_mss = cpu_to_le32(((u32)cm_node->tcp_cntxt.mss));
-	if (cm_node->vlan_id < VLAN_TAG_PRESENT) {
+	if (cm_node->vlan_id <= VLAN_VID_MASK) {
 		tcp_info->insert_vlan_tag = true;
 		tcp_info->vlan_tag = cpu_to_le16(cm_node->vlan_id);
 	}
-- 
2.10.2
