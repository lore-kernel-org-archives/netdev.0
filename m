From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] vxlan: expose COLLECT_METADATA flag to user space
Date: Thu, 30 Jul 2015 20:10:22 -0700
Message-ID: <1438312222-7130-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:36023 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884AbbGaDK3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 23:10:29 -0400
Received: by pdjr16 with SMTP id r16so35292171pdj.3
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 20:10:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two vxlan driver flags FLOWBASED and COLLECT_METADATA need to be set to
make use of its new flow mode. The former already exposed. Expose the latter.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 drivers/net/vxlan.c          |    5 +++++
 include/uapi/linux/if_link.h |    1 +
 2 files changed, 6 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 81f0f24b2cfb..1205729fcc56 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2463,6 +2463,7 @@ static const struct nla_policy vxlan_policy[IFLA_VXLAN_MAX + 1] = {
 	[IFLA_VXLAN_L2MISS]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_L3MISS]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_FLOWBASED]	= { .type = NLA_U8 },
+	[IFLA_VXLAN_COLLECT_METADATA]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_PORT]	= { .type = NLA_U16 },
 	[IFLA_VXLAN_UDP_CSUM]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_UDP_ZERO_CSUM6_TX]	= { .type = NLA_U8 },
@@ -2817,6 +2818,10 @@ static int vxlan_newlink(struct net *src_net, struct net_device *dev,
 	    nla_get_u8(data[IFLA_VXLAN_FLOWBASED]))
 		conf.flags |= VXLAN_F_FLOW_BASED;
 
+	if (data[IFLA_VXLAN_COLLECT_METADATA] &&
+	    nla_get_u8(data[IFLA_VXLAN_COLLECT_METADATA]))
+		conf.flags |= VXLAN_F_COLLECT_METADATA;
+
 	if (data[IFLA_VXLAN_PORT_RANGE]) {
 		const struct ifla_vxlan_port_range *p
 			= nla_data(data[IFLA_VXLAN_PORT_RANGE]);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 9eeb5d9cf8f0..24e22cd4be79 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -383,6 +383,7 @@ enum {
 	IFLA_VXLAN_GBP,
 	IFLA_VXLAN_REMCSUM_NOPARTIAL,
 	IFLA_VXLAN_FLOWBASED,
+	IFLA_VXLAN_COLLECT_METADATA,
 	__IFLA_VXLAN_MAX
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
-- 
1.7.9.5
