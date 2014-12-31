From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v1 07/11] net: rocker: add multicast path to
 bridging
Date: Wed, 31 Dec 2014 11:48:29 -0800
Message-ID: <20141231194828.31070.77865.stgit@nitbit.x32>
References: <20141231194057.31070.5244.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net
To: tgraf@suug.ch, sfeldma@gmail.com, jiri@resnulli.us,
	jhs@mojatatu.com, simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:51166 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751725AbaLaTsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 14:48:47 -0500
Received: by mail-ob0-f181.google.com with SMTP id gq1so49292232obb.12
        for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 11:48:46 -0800 (PST)
In-Reply-To: <20141231194057.31070.5244.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add path in table graph to send packets to the bridge table.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/ethernet/rocker/rocker_pipeline.h |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker_pipeline.h b/drivers/net/ethernet/rocker/rocker_pipeline.h
index 7e689c0..0835bcc 100644
--- a/drivers/net/ethernet/rocker/rocker_pipeline.h
+++ b/drivers/net/ethernet/rocker/rocker_pipeline.h
@@ -708,7 +708,15 @@ struct net_flow_tbl_node table_node_vlan = {
 	.uid = ROCKER_FLOW_TABLE_ID_VLAN,
 	.jump = table_node_vlan_next};
 
-struct net_flow_jump_table table_node_term_mac_next[2] = {
+struct net_flow_jump_table table_node_term_mac_next[3] = {
+	{ .field = {.instance = HEADER_INSTANCE_ETHERNET,
+		    .header = HEADER_ETHERNET,
+		    .field = HEADER_ETHERNET_DST_MAC,
+		    .mask_type = NET_FLOW_MASK_TYPE_LPM,
+		    .type = NET_FLOW_FIELD_REF_ATTR_TYPE_U64,
+		    .value_u64 = (__u64)0x1,
+		    .mask_u64 = (__u64)0x1,
+	}, .node = ROCKER_FLOW_TABLE_ID_BRIDGING},
 	{ .field = {0}, .node = ROCKER_FLOW_TABLE_ID_UNICAST_ROUTING},
 	{ .field = {0}, .node = 0},
 };
