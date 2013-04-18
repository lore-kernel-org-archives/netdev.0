From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 2/2] openvswitch: Use lockless genl.
Date: Thu, 18 Apr 2013 09:52:04 -0700
Message-ID: <1366303924-30701-1-git-send-email-pshelar@nicira.com>
Cc: dev@openvswitch.org, jesse@nicira.com,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog124.obsmtp.com ([74.125.149.151]:60087 "HELO
	na3sys009aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933132Ab3DRQwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 12:52:12 -0400
Received: by mail-ie0-f199.google.com with SMTP id x14so17530449ief.6
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 09:52:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch uses of lockless genl callbacks for ovs.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
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
