From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/2] rocker: introduce be put/get variants and use it when appropriate
Date: Wed,  3 Dec 2014 11:32:32 +0100
Message-ID: <1417602753-3084-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:55316 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751560AbaLCKch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 05:32:37 -0500
Received: by mail-wi0-f179.google.com with SMTP id ex7so23891045wid.6
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 02:32:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This kills the sparse warnings.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/rocker/rocker.c | 79 ++++++++++++++++++++++--------------
 1 file changed, 48 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index fded127..4b060fb 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -648,6 +648,11 @@ static u16 rocker_tlv_get_u16(const struct rocker_tlv *tlv)
 	return *(u16 *) rocker_tlv_data(tlv);
 }
 
+static __be16 rocker_tlv_get_be16(const struct rocker_tlv *tlv)
+{
+	return *(__be16 *) rocker_tlv_data(tlv);
+}
+
 static u32 rocker_tlv_get_u32(const struct rocker_tlv *tlv)
 {
 	return *(u32 *) rocker_tlv_data(tlv);
@@ -726,12 +731,24 @@ static int rocker_tlv_put_u16(struct rocker_desc_info *desc_info,
 	return rocker_tlv_put(desc_info, attrtype, sizeof(u16), &value);
 }
 
+static int rocker_tlv_put_be16(struct rocker_desc_info *desc_info,
+			       int attrtype, __be16 value)
+{
+	return rocker_tlv_put(desc_info, attrtype, sizeof(__be16), &value);
+}
+
 static int rocker_tlv_put_u32(struct rocker_desc_info *desc_info,
 			      int attrtype, u32 value)
 {
 	return rocker_tlv_put(desc_info, attrtype, sizeof(u32), &value);
 }
 
+static int rocker_tlv_put_be32(struct rocker_desc_info *desc_info,
+			       int attrtype, __be32 value)
+{
+	return rocker_tlv_put(desc_info, attrtype, sizeof(__be32), &value);
+}
+
 static int rocker_tlv_put_u64(struct rocker_desc_info *desc_info,
 			      int attrtype, u64 value)
 {
@@ -1343,7 +1360,7 @@ static int rocker_event_mac_vlan_seen(struct rocker *rocker,
 	port_number =
 		rocker_tlv_get_u32(attrs[ROCKER_TLV_EVENT_MAC_VLAN_LPORT]) - 1;
 	addr = rocker_tlv_data(attrs[ROCKER_TLV_EVENT_MAC_VLAN_MAC]);
-	vlan_id = rocker_tlv_get_u16(attrs[ROCKER_TLV_EVENT_MAC_VLAN_VLAN_ID]);
+	vlan_id = rocker_tlv_get_be16(attrs[ROCKER_TLV_EVENT_MAC_VLAN_VLAN_ID]);
 
 	if (port_number >= rocker->port_count)
 		return -EINVAL;
@@ -1717,18 +1734,18 @@ static int rocker_cmd_flow_tbl_add_vlan(struct rocker_desc_info *desc_info,
 	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_LPORT,
 			       entry->key.vlan.in_lport))
 		return -EMSGSIZE;
-	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
-			       entry->key.vlan.vlan_id))
+	if (rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
+				entry->key.vlan.vlan_id))
 		return -EMSGSIZE;
-	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID_MASK,
-			       entry->key.vlan.vlan_id_mask))
+	if (rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID_MASK,
+				entry->key.vlan.vlan_id_mask))
 		return -EMSGSIZE;
 	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_GOTO_TABLE_ID,
 			       entry->key.vlan.goto_tbl))
 		return -EMSGSIZE;
 	if (entry->key.vlan.untagged &&
-	    rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_NEW_VLAN_ID,
-			       entry->key.vlan.new_vlan_id))
+	    rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_NEW_VLAN_ID,
+				entry->key.vlan.new_vlan_id))
 		return -EMSGSIZE;
 
 	return 0;
@@ -1743,8 +1760,8 @@ static int rocker_cmd_flow_tbl_add_term_mac(struct rocker_desc_info *desc_info,
 	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_LPORT_MASK,
 			       entry->key.term_mac.in_lport_mask))
 		return -EMSGSIZE;
-	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_ETHERTYPE,
-			       entry->key.term_mac.eth_type))
+	if (rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_ETHERTYPE,
+				entry->key.term_mac.eth_type))
 		return -EMSGSIZE;
 	if (rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_DST_MAC,
 			   ETH_ALEN, entry->key.term_mac.eth_dst))
@@ -1752,11 +1769,11 @@ static int rocker_cmd_flow_tbl_add_term_mac(struct rocker_desc_info *desc_info,
 	if (rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_DST_MAC_MASK,
 			   ETH_ALEN, entry->key.term_mac.eth_dst_mask))
 		return -EMSGSIZE;
-	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
-			       entry->key.term_mac.vlan_id))
+	if (rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
+				entry->key.term_mac.vlan_id))
 		return -EMSGSIZE;
-	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID_MASK,
-			       entry->key.term_mac.vlan_id_mask))
+	if (rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID_MASK,
+				entry->key.term_mac.vlan_id_mask))
 		return -EMSGSIZE;
 	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_GOTO_TABLE_ID,
 			       entry->key.term_mac.goto_tbl))
@@ -1773,14 +1790,14 @@ static int
 rocker_cmd_flow_tbl_add_ucast_routing(struct rocker_desc_info *desc_info,
 				      struct rocker_flow_tbl_entry *entry)
 {
-	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_ETHERTYPE,
-			       entry->key.ucast_routing.eth_type))
+	if (rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_ETHERTYPE,
+				entry->key.ucast_routing.eth_type))
 		return -EMSGSIZE;
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_DST_IP,
-			       entry->key.ucast_routing.dst4))
+	if (rocker_tlv_put_be32(desc_info, ROCKER_TLV_OF_DPA_DST_IP,
+				entry->key.ucast_routing.dst4))
 		return -EMSGSIZE;
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_DST_IP_MASK,
-			       entry->key.ucast_routing.dst4_mask))
+	if (rocker_tlv_put_be32(desc_info, ROCKER_TLV_OF_DPA_DST_IP_MASK,
+				entry->key.ucast_routing.dst4_mask))
 		return -EMSGSIZE;
 	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_GOTO_TABLE_ID,
 			       entry->key.ucast_routing.goto_tbl))
@@ -1804,8 +1821,8 @@ static int rocker_cmd_flow_tbl_add_bridge(struct rocker_desc_info *desc_info,
 			   ETH_ALEN, entry->key.bridge.eth_dst_mask))
 		return -EMSGSIZE;
 	if (entry->key.bridge.vlan_id &&
-	    rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
-			       entry->key.bridge.vlan_id))
+	    rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
+				entry->key.bridge.vlan_id))
 		return -EMSGSIZE;
 	if (entry->key.bridge.tunnel_id &&
 	    rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_TUNNEL_ID,
@@ -1846,14 +1863,14 @@ static int rocker_cmd_flow_tbl_add_acl(struct rocker_desc_info *desc_info,
 	if (rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_DST_MAC_MASK,
 			   ETH_ALEN, entry->key.acl.eth_dst_mask))
 		return -EMSGSIZE;
-	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_ETHERTYPE,
-			       entry->key.acl.eth_type))
+	if (rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_ETHERTYPE,
+				entry->key.acl.eth_type))
 		return -EMSGSIZE;
-	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
-			       entry->key.acl.vlan_id))
+	if (rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
+				entry->key.acl.vlan_id))
 		return -EMSGSIZE;
-	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID_MASK,
-			       entry->key.acl.vlan_id_mask))
+	if (rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID_MASK,
+				entry->key.acl.vlan_id_mask))
 		return -EMSGSIZE;
 
 	switch (ntohs(entry->key.acl.eth_type)) {
@@ -2002,8 +2019,8 @@ rocker_cmd_group_tbl_add_l2_rewrite(struct rocker_desc_info *desc_info,
 			   ETH_ALEN, entry->l2_rewrite.eth_dst))
 		return -EMSGSIZE;
 	if (entry->l2_rewrite.vlan_id &&
-	    rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
-			       entry->l2_rewrite.vlan_id))
+	    rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
+				entry->l2_rewrite.vlan_id))
 		return -EMSGSIZE;
 
 	return 0;
@@ -2048,8 +2065,8 @@ rocker_cmd_group_tbl_add_l3_unicast(struct rocker_desc_info *desc_info,
 			   ETH_ALEN, entry->l3_unicast.eth_dst))
 		return -EMSGSIZE;
 	if (entry->l3_unicast.vlan_id &&
-	    rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
-			       entry->l3_unicast.vlan_id))
+	    rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
+				entry->l3_unicast.vlan_id))
 		return -EMSGSIZE;
 	if (rocker_tlv_put_u8(desc_info, ROCKER_TLV_OF_DPA_TTL_CHECK,
 			      entry->l3_unicast.ttl_check))
-- 
1.9.3
