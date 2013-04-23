From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v3 2/2] openvswitch: Use parallel_ops genl.
Date: Tue, 23 Apr 2013 10:48:48 -0700
Message-ID: <1366739328-18224-1-git-send-email-pshelar@nicira.com>
Cc: dev@openvswitch.org, jesse@nicira.com,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:46499 "HELO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756381Ab3DWRsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 13:48:55 -0400
Received: by mail-pa0-f69.google.com with SMTP id kl13so855205pab.8
        for <netdev@vger.kernel.org>; Tue, 23 Apr 2013 10:48:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OVS locking was recently changed to have private OVS lock which
simplified overall locking.  Therefore there is no need to have
another global genl lock to protect OVS data structures.  Following
patch uses of parallel_ops genl family for OVS.  This also allows
more granual OVS locking using ovs_mutex for protecting OVS data
structures, which gives more concurrencey.  E.g multiple genl
operations OVS_PACKET_CMD_EXECUTE can run in parallel, etc.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
v2-v3:
 - No change.
v1-v2:
 - Updated commit msg according comment From Jesse.
---
 net/openvswitch/datapath.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index d2f9f2e..74a5fe6 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -270,7 +270,8 @@ static struct genl_family dp_packet_genl_family = {
 	.name = OVS_PACKET_FAMILY,
 	.version = OVS_PACKET_VERSION,
 	.maxattr = OVS_PACKET_ATTR_MAX,
-	.netnsok = true
+	.netnsok = true,
+	.parallel_ops = true,
 };
 
 int ovs_dp_upcall(struct datapath *dp, struct sk_buff *skb,
@@ -836,7 +837,8 @@ static struct genl_family dp_flow_genl_family = {
 	.name = OVS_FLOW_FAMILY,
 	.version = OVS_FLOW_VERSION,
 	.maxattr = OVS_FLOW_ATTR_MAX,
-	.netnsok = true
+	.netnsok = true,
+	.parallel_ops = true,
 };
 
 static struct genl_multicast_group ovs_dp_flow_multicast_group = {
@@ -1269,7 +1271,8 @@ static struct genl_family dp_datapath_genl_family = {
 	.name = OVS_DATAPATH_FAMILY,
 	.version = OVS_DATAPATH_VERSION,
 	.maxattr = OVS_DP_ATTR_MAX,
-	.netnsok = true
+	.netnsok = true,
+	.parallel_ops = true,
 };
 
 static struct genl_multicast_group ovs_dp_datapath_multicast_group = {
@@ -1623,7 +1626,8 @@ static struct genl_family dp_vport_genl_family = {
 	.name = OVS_VPORT_FAMILY,
 	.version = OVS_VPORT_VERSION,
 	.maxattr = OVS_VPORT_ATTR_MAX,
-	.netnsok = true
+	.netnsok = true,
+	.parallel_ops = true,
 };
 
 struct genl_multicast_group ovs_dp_vport_multicast_group = {
-- 
1.7.1
