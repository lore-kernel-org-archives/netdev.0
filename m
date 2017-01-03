From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next v2 05/27] i40iw: remove use of VLAN_TAG_PRESENT
Date: Tue,  3 Jan 2017 21:52:34 +0100 (CET)
Message-ID: <119487a6fe9c0cfa563f49fc437ec7b2048c7d92.1483475202.git.mirq-linux@rere.qmqm.pl>
References: <cover.1483475202.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Faisal Latif <faisal.latif@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:34708 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935894AbdACUwj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 15:52:39 -0500
In-Reply-To: <cover.1483475202.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 drivers/infiniband/hw/i40iw/i40iw_cm.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/hw/i40iw/i40iw_cm.c b/drivers/infiniband/hw/i40iw/i40iw_cm.c
index 95a0586a4da8..125c66bf6107 100644
--- a/drivers/infiniband/hw/i40iw/i40iw_cm.c
+++ b/drivers/infiniband/hw/i40iw/i40iw_cm.c
@@ -405,7 +405,7 @@ static struct i40iw_puda_buf *i40iw_form_cm_frame(struct i40iw_cm_node *cm_node,
 	if (pdata)
 		pd_len = pdata->size;
 
-	if (cm_node->vlan_id < VLAN_TAG_PRESENT)
+	if (cm_node->vlan_id <= VLAN_VID_MASK)
 		eth_hlen += 4;
 
 	if (cm_node->ipv4)
@@ -434,7 +434,7 @@ static struct i40iw_puda_buf *i40iw_form_cm_frame(struct i40iw_cm_node *cm_node,
 
 		ether_addr_copy(ethh->h_dest, cm_node->rem_mac);
 		ether_addr_copy(ethh->h_source, cm_node->loc_mac);
-		if (cm_node->vlan_id < VLAN_TAG_PRESENT) {
+		if (cm_node->vlan_id <= VLAN_VID_MASK) {
 			((struct vlan_ethhdr *)ethh)->h_vlan_proto = htons(ETH_P_8021Q);
 			vtag = (cm_node->user_pri << VLAN_PRIO_SHIFT) | cm_node->vlan_id;
 			((struct vlan_ethhdr *)ethh)->h_vlan_TCI = htons(vtag);
@@ -464,7 +464,7 @@ static struct i40iw_puda_buf *i40iw_form_cm_frame(struct i40iw_cm_node *cm_node,
 
 		ether_addr_copy(ethh->h_dest, cm_node->rem_mac);
 		ether_addr_copy(ethh->h_source, cm_node->loc_mac);
-		if (cm_node->vlan_id < VLAN_TAG_PRESENT) {
+		if (cm_node->vlan_id <= VLAN_VID_MASK) {
 			((struct vlan_ethhdr *)ethh)->h_vlan_proto = htons(ETH_P_8021Q);
 			vtag = (cm_node->user_pri << VLAN_PRIO_SHIFT) | cm_node->vlan_id;
 			((struct vlan_ethhdr *)ethh)->h_vlan_TCI = htons(vtag);
@@ -3260,7 +3260,7 @@ static void i40iw_init_tcp_ctx(struct i40iw_cm_node *cm_node,
 
 	tcp_info->flow_label = 0;
 	tcp_info->snd_mss = cpu_to_le32(((u32)cm_node->tcp_cntxt.mss));
-	if (cm_node->vlan_id < VLAN_TAG_PRESENT) {
+	if (cm_node->vlan_id <= VLAN_VID_MASK) {
 		tcp_info->insert_vlan_tag = true;
 		tcp_info->vlan_tag = cpu_to_le16(cm_node->vlan_id);
 	}
-- 
2.11.0
