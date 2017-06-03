From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next] openvswitch: add macro MODULE_ALIAS_VPORT_TYPE for vport type alias
Date: Sat,  3 Jun 2017 21:47:35 +0800
Message-ID: <1496497655-24810-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: pshelar@nicira.com, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:53063 "EHLO
        cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750765AbdFCNrq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Jun 2017 09:47:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new macro MODULE_ALIAS_VPORT_TYPE to unify and simplify the
declaration of vport type alias, and replace magic numbers with
symbolic constants.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 net/openvswitch/vport-geneve.c | 2 +-
 net/openvswitch/vport-gre.c    | 2 +-
 net/openvswitch/vport-vxlan.c  | 2 +-
 net/openvswitch/vport.h        | 3 +++
 4 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
index 5aaf3ba..1c068d6 100644
--- a/net/openvswitch/vport-geneve.c
+++ b/net/openvswitch/vport-geneve.c
@@ -141,4 +141,4 @@ static void __exit ovs_geneve_tnl_exit(void)
 
 MODULE_DESCRIPTION("OVS: Geneve switching port");
 MODULE_LICENSE("GPL");
-MODULE_ALIAS("vport-type-5");
+MODULE_ALIAS_VPORT_TYPE(OVS_VPORT_TYPE_GENEVE);
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index 0e72d95..48a5852 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -113,4 +113,4 @@ static void __exit ovs_gre_tnl_exit(void)
 
 MODULE_DESCRIPTION("OVS: GRE switching port");
 MODULE_LICENSE("GPL");
-MODULE_ALIAS("vport-type-3");
+MODULE_ALIAS_VPORT_TYPE(OVS_VPORT_TYPE_GRE);
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index 869acb3..b6257bb 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -179,4 +179,4 @@ static void __exit ovs_vxlan_tnl_exit(void)
 
 MODULE_DESCRIPTION("OVS: VXLAN switching port");
 MODULE_LICENSE("GPL");
-MODULE_ALIAS("vport-type-4");
+MODULE_ALIAS_VPORT_TYPE(OVS_VPORT_TYPE_VXLAN);
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index cda66c2..1d1584f 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -199,4 +199,7 @@ static inline const char *ovs_vport_name(struct vport *vport)
 void ovs_vport_ops_unregister(struct vport_ops *ops);
 void ovs_vport_send(struct vport *vport, struct sk_buff *skb, u8 mac_proto);
 
+#define MODULE_ALIAS_VPORT_TYPE(type) \
+	MODULE_ALIAS("vport-type-" __stringify(type))
+
 #endif /* vport.h */
-- 
1.8.3.1
