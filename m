From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] openvswitch: make generic netlink group const
Date: Wed, 16 Jul 2014 11:25:52 -0700
Message-ID: <20140716112552.55852dbf@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dev@openvswitch.org, netdev@vger.kernel.org
To: Pravin Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:63916 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934773AbaGPSZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 14:25:56 -0400
Received: by mail-pd0-f176.google.com with SMTP id y10so1640512pdj.7
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 11:25:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Generic netlink tables can be const.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/net/openvswitch/datapath.c	2014-07-09 03:06:11.400291765 -0700
+++ b/net/openvswitch/datapath.c	2014-07-09 03:09:35.688297236 -0700
@@ -66,16 +66,16 @@ static struct genl_family dp_packet_genl
 static struct genl_family dp_flow_genl_family;
 static struct genl_family dp_datapath_genl_family;
 
-static struct genl_multicast_group ovs_dp_flow_multicast_group = {
-	.name = OVS_FLOW_MCGROUP
+static const struct genl_multicast_group ovs_dp_flow_multicast_group = {
+	.name = OVS_FLOW_MCGROUP,
 };
 
-static struct genl_multicast_group ovs_dp_datapath_multicast_group = {
-	.name = OVS_DATAPATH_MCGROUP
+static const struct genl_multicast_group ovs_dp_datapath_multicast_group = {
+	.name = OVS_DATAPATH_MCGROUP,
 };
 
-struct genl_multicast_group ovs_dp_vport_multicast_group = {
-	.name = OVS_VPORT_MCGROUP
+static const struct genl_multicast_group ovs_dp_vport_multicast_group = {
+	.name = OVS_VPORT_MCGROUP,
 };
 
 /* Check if need to build a reply message.
@@ -1190,7 +1190,7 @@ static const struct nla_policy flow_poli
 	[OVS_FLOW_ATTR_CLEAR] = { .type = NLA_FLAG },
 };
 
-static struct genl_ops dp_flow_genl_ops[] = {
+static const struct genl_ops dp_flow_genl_ops[] = {
 	{ .cmd = OVS_FLOW_CMD_NEW,
 	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
 	  .policy = flow_policy,
@@ -1578,7 +1578,7 @@ static const struct nla_policy datapath_
 	[OVS_DP_ATTR_USER_FEATURES] = { .type = NLA_U32 },
 };
 
-static struct genl_ops dp_datapath_genl_ops[] = {
+static const struct genl_ops dp_datapath_genl_ops[] = {
 	{ .cmd = OVS_DP_CMD_NEW,
 	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
 	  .policy = datapath_policy,
@@ -1945,7 +1945,7 @@ static const struct nla_policy vport_pol
 	[OVS_VPORT_ATTR_OPTIONS] = { .type = NLA_NESTED },
 };
 
-static struct genl_ops dp_vport_genl_ops[] = {
+static const struct genl_ops dp_vport_genl_ops[] = {
 	{ .cmd = OVS_VPORT_CMD_NEW,
 	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
 	  .policy = vport_policy,
