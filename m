From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 09/12] net: rocker: add multicast path to
 bridging
Date: Tue, 13 Jan 2015 13:38:58 -0800
Message-ID: <20150113213856.13874.59343.stgit@nitbit.x32>
References: <20150113212941.13874.48692.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gerlitz.or@gmail.com, jhs@mojatatu.com,
	andy@greyhouse.net, davem@davemloft.net
To: tgraf@suug.ch, simon.horman@netronome.com, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:54747 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753788AbbAMVjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 16:39:16 -0500
Received: by mail-ob0-f178.google.com with SMTP id gq1so4890894obb.9
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 13:39:15 -0800 (PST)
In-Reply-To: <20150113212941.13874.48692.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add path in table graph to send packets to the bridge table.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/ethernet/rocker/rocker_pipeline.h |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker_pipeline.h b/drivers/net/ethernet/rocker/rocker_pipeline.h
index 6d1e2ee..1a3dcdb 100644
--- a/drivers/net/ethernet/rocker/rocker_pipeline.h
+++ b/drivers/net/ethernet/rocker/rocker_pipeline.h
@@ -511,6 +511,14 @@ struct net_flow_tbl_node rocker_table_node_vlan = {
 	.jump = rocker_table_node_vlan_next};
 
 struct net_flow_jump_table rocker_table_node_term_mac_next[] = {
+	{ .field = {.instance = ROCKER_HEADER_INSTANCE_ETHERNET,
+		    .header = HEADER_ETHERNET,
+		    .field = HEADER_ETHERNET_DST_MAC,
+		    .mask_type = NFL_MASK_TYPE_LPM,
+		    .type = NFL_FIELD_REF_ATTR_TYPE_U64,
+		    .value_u64 = (__u64)0x1,
+		    .mask_u64 = (__u64)0x1,
+	}, .node = ROCKER_FLOW_TABLE_ID_BRIDGING},
 	{ .field = {0}, .node = ROCKER_FLOW_TABLE_ID_UNICAST_ROUTING},
 	{ .field = {0}, .node = 0},
 };
