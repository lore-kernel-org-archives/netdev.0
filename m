From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v3 09/12] net: rocker: add multicast path to
 bridging
Date: Tue, 20 Jan 2015 12:30:09 -0800
Message-ID: <20150120203008.1741.60789.stgit@nitbit.x32>
References: <20150120202404.1741.8658.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, davem@davemloft.net,
	gerlitz.or@gmail.com, andy@greyhouse.net, ast@plumgrid.com
To: tgraf@suug.ch, simon.horman@netronome.com, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:40171 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753448AbbATUaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 15:30:30 -0500
Received: by mail-oi0-f52.google.com with SMTP id h136so12233823oig.11
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 12:30:29 -0800 (PST)
In-Reply-To: <20150120202404.1741.8658.stgit@nitbit.x32>
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
