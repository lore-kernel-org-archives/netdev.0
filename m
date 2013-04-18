From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 2/2] openvswitch: Use lockless genl.
Date: Thu, 18 Apr 2013 14:30:53 -0700
Message-ID: <1366320653-16941-1-git-send-email-pshelar@nicira.com>
Cc: dev@openvswitch.org, jesse@nicira.com,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog130.obsmtp.com ([74.125.149.143]:34339 "HELO
	na3sys009aog130.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751781Ab3DRVa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 17:30:57 -0400
Received: by mail-ob0-f199.google.com with SMTP id va7so17593507obc.6
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 14:30:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OVS locking was recently changed to have private OVS lock which
simplified overall locking.  Therefore there is no need to have
another global genl lock to protect OVS data structures.  Following
patch uses of lockless genl family for OVS.  This also allows
more granual OVS locking using ovs_mutex for protecting OVS data
structures, which gives more concurrencey.  E.g multiple genl
operations OVS_PACKET_CMD_EXECUTE can run in parallel, etc.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
Updated commit msg according comment From Jesse.
---
 net/openvswitch/datapath.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index b7d0b7c..b2c966e 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -270,7 +270,8 @@ static struct genl_family dp_packet_genl_family = {
 	.name = OVS_PACKET_FAMILY,
 	.version = OVS_PACKET_VERSION,
 	.maxattr = OVS_PACKET_ATTR_MAX,
-	.netnsok = true
+	.netnsok = true,
+	.lockless = true,
 };
 
 int ovs_dp_upcall(struct datapath *dp, struct sk_buff *skb,
@@ -836,7 +837,8 @@ static struct genl_family dp_flow_genl_family = {
 	.name = OVS_FLOW_FAMILY,
 	.version = OVS_FLOW_VERSION,
 	.maxattr = OVS_FLOW_ATTR_MAX,
-	.netnsok = true
+	.netnsok = true,
+	.lockless = true,
 };
 
 static struct genl_multicast_group ovs_dp_flow_multicast_group = {
@@ -1269,7 +1271,8 @@ static struct genl_family dp_datapath_genl_family = {
 	.name = OVS_DATAPATH_FAMILY,
 	.version = OVS_DATAPATH_VERSION,
 	.maxattr = OVS_DP_ATTR_MAX,
-	.netnsok = true
+	.netnsok = true,
+	.lockless = true,
 };
 
 static struct genl_multicast_group ovs_dp_datapath_multicast_group = {
@@ -1623,7 +1626,8 @@ static struct genl_family dp_vport_genl_family = {
 	.name = OVS_VPORT_FAMILY,
 	.version = OVS_VPORT_VERSION,
 	.maxattr = OVS_VPORT_ATTR_MAX,
-	.netnsok = true
+	.netnsok = true,
+	.lockless = true,
 };
 
 struct genl_multicast_group ovs_dp_vport_multicast_group = {
-- 
1.7.1
