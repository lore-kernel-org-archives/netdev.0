From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v2 net-next 1/6] bridge: Allow an ability to designate an uplink port
Date: Fri, 19 Apr 2013 16:52:45 -0400
Message-ID: <1366404770-28523-2-git-send-email-vyasevic@redhat.com>
References: <1366404770-28523-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, mst@redhat.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17510 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754462Ab3DSUwy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 16:52:54 -0400
In-Reply-To: <1366404770-28523-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set a flag on the port that designates it as an uplink.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/uapi/linux/if_link.h |    1 +
 net/bridge/br_netlink.c      |    2 ++
 net/bridge/br_private.h      |    1 +
 net/bridge/br_sysfs_if.c     |    2 ++
 4 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index e316354..0c5c76e 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -221,6 +221,7 @@ enum {
 	IFLA_BRPORT_GUARD,	/* bpdu guard              */
 	IFLA_BRPORT_PROTECT,	/* root port protection    */
 	IFLA_BRPORT_FAST_LEAVE,	/* multicast fast leave    */
+	IFLA_BRPORT_UPLINK,	/* uplink port */
 	__IFLA_BRPORT_MAX
 };
 #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 8e3abf5..1767d15 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -281,6 +281,7 @@ static const struct nla_policy ifla_brport_policy[IFLA_BRPORT_MAX + 1] = {
 	[IFLA_BRPORT_MODE]	= { .type = NLA_U8 },
 	[IFLA_BRPORT_GUARD]	= { .type = NLA_U8 },
 	[IFLA_BRPORT_PROTECT]	= { .type = NLA_U8 },
+	[IFLA_BRPORT_UPLINK]	= { .type = NLA_U8 },
 };
 
 /* Change the state of the port and notify spanning tree */
@@ -328,6 +329,7 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 	br_set_port_flag(p, tb, IFLA_BRPORT_GUARD, BR_BPDU_GUARD);
 	br_set_port_flag(p, tb, IFLA_BRPORT_FAST_LEAVE, BR_MULTICAST_FAST_LEAVE);
 	br_set_port_flag(p, tb, IFLA_BRPORT_PROTECT, BR_ROOT_BLOCK);
+	br_set_port_flag(p, tb, IFLA_BRPORT_UPLINK, BR_UPLINK);
 
 	if (tb[IFLA_BRPORT_COST]) {
 		err = br_stp_set_path_cost(p, nla_get_u32(tb[IFLA_BRPORT_COST]));
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 3cbf5be..c90ec57 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -156,6 +156,7 @@ struct net_bridge_port
 #define BR_BPDU_GUARD           0x00000002
 #define BR_ROOT_BLOCK		0x00000004
 #define BR_MULTICAST_FAST_LEAVE	0x00000008
+#define BR_UPLINK		0x00000010
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	u32				multicast_startup_queries_sent;
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index a1ef1b6..1f28cd4 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -158,6 +158,7 @@ static BRPORT_ATTR(flush, S_IWUSR, NULL, store_flush);
 BRPORT_ATTR_FLAG(hairpin_mode, BR_HAIRPIN_MODE);
 BRPORT_ATTR_FLAG(bpdu_guard, BR_BPDU_GUARD);
 BRPORT_ATTR_FLAG(root_block, BR_ROOT_BLOCK);
+BRPORT_ATTR_FLAG(uplink, BR_UPLINK);
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 static ssize_t show_multicast_router(struct net_bridge_port *p, char *buf)
@@ -195,6 +196,7 @@ static const struct brport_attribute *brport_attrs[] = {
 	&brport_attr_hairpin_mode,
 	&brport_attr_bpdu_guard,
 	&brport_attr_root_block,
+	&brport_attr_uplink,
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	&brport_attr_multicast_router,
 	&brport_attr_multicast_fast_leave,
-- 
1.7.7.6
