From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next] openvswitch: remove unnecessary EXPORT_SYMBOLs
Date: Tue, 18 Oct 2016 13:47:46 +0200
Message-ID: <5be1d459a2508bbce591ee82f9a2eb147dceedb7.1476791224.git.jbenc@redhat.com>
Cc: dev@openvswitch.org, Pravin Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58852 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753243AbcJRLsY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Oct 2016 07:48:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many symbols exported to other modules are really used only by
openvswitch.ko. Remove the exports.

Tested by loading all 4 openvswitch modules, nothing breaks.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 net/openvswitch/datapath.c     | 2 --
 net/openvswitch/vport-netdev.c | 1 -
 net/openvswitch/vport.c        | 2 --
 3 files changed, 5 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 4d67ea856067..194435aa1165 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -59,7 +59,6 @@
 #include "vport-netdev.h"
 
 int ovs_net_id __read_mostly;
-EXPORT_SYMBOL_GPL(ovs_net_id);
 
 static struct genl_family dp_packet_genl_family;
 static struct genl_family dp_flow_genl_family;
@@ -131,7 +130,6 @@ int lockdep_ovsl_is_held(void)
 	else
 		return 1;
 }
-EXPORT_SYMBOL_GPL(lockdep_ovsl_is_held);
 #endif
 
 static struct vport *new_vport(const struct vport_parms *);
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 4e3972344aa6..e825753de1e0 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -162,7 +162,6 @@ void ovs_netdev_detach_dev(struct vport *vport)
 				netdev_master_upper_dev_get(vport->dev));
 	dev_set_promiscuity(vport->dev, -1);
 }
-EXPORT_SYMBOL_GPL(ovs_netdev_detach_dev);
 
 static void netdev_destroy(struct vport *vport)
 {
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 7387418ac514..f7d4390829af 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -463,7 +463,6 @@ int ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
 	ovs_dp_process_packet(skb, &key);
 	return 0;
 }
-EXPORT_SYMBOL_GPL(ovs_vport_receive);
 
 static void free_vport_rcu(struct rcu_head *rcu)
 {
@@ -479,7 +478,6 @@ void ovs_vport_deferred_free(struct vport *vport)
 
 	call_rcu(&vport->rcu, free_vport_rcu);
 }
-EXPORT_SYMBOL_GPL(ovs_vport_deferred_free);
 
 static unsigned int packet_length(const struct sk_buff *skb)
 {
-- 
1.8.3.1
