From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 8/9] genetlink: make all genl_ops users const
Date: Thu, 14 Nov 2013 17:14:46 +0100
Message-ID: <1384445687-30948-9-git-send-email-johannes@sipsolutions.net>
References: <1384420486-8713-1-git-send-email-johannes@sipsolutions.net>
 <1384445687-30948-1-git-send-email-johannes@sipsolutions.net>
Cc: linux-wimax@intel.com, Balbir Singh <bsingharora@gmail.com>,
	netfilter-devel@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1384445687-30948-1-git-send-email-johannes@sipsolutions.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg@intel.com>

Now that genl_ops are no longer modified in place when
registering, they can be made const. This patch was done
mostly with spatch:

@@
identifier ops;
@@
+const
 struct genl_ops ops[] = {
 ...
 };

(except the struct thing in net/openvswitch/datapath.c)

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 drivers/net/team/team.c               |  2 +-
 drivers/net/wireless/mac80211_hwsim.c |  2 +-
 kernel/taskstats.c                    |  2 +-
 net/core/drop_monitor.c               |  2 +-
 net/hsr/hsr_netlink.c                 |  2 +-
 net/ieee802154/netlink.c              |  2 +-
 net/ipv4/tcp_metrics.c                |  2 +-
 net/irda/irnetlink.c                  |  2 +-
 net/l2tp/l2tp_netlink.c               |  2 +-
 net/netfilter/ipvs/ip_vs_ctl.c        |  2 +-
 net/netlabel/netlabel_cipso_v4.c      |  2 +-
 net/netlabel/netlabel_mgmt.c          |  2 +-
 net/netlabel/netlabel_unlabeled.c     |  2 +-
 net/nfc/netlink.c                     |  2 +-
 net/openvswitch/datapath.c            | 10 +++++-----
 net/wimax/stack.c                     |  2 +-
 net/wireless/nl80211.c                |  2 +-
 17 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 50e43e6..6390254 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2644,7 +2644,7 @@ static int team_nl_cmd_port_list_get(struct sk_buff *skb,
 	return err;
 }
 
-static struct genl_ops team_nl_ops[] = {
+static const struct genl_ops team_nl_ops[] = {
 	{
 		.cmd = TEAM_CMD_NOOP,
 		.doit = team_nl_cmd_noop,
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index de0df86..cfc3fda 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -2097,7 +2097,7 @@ out:
 }
 
 /* Generic Netlink operations array */
-static struct genl_ops hwsim_ops[] = {
+static const struct genl_ops hwsim_ops[] = {
 	{
 		.cmd = HWSIM_CMD_REGISTER,
 		.policy = hwsim_genl_policy,
diff --git a/kernel/taskstats.c b/kernel/taskstats.c
index 609e77f..76595cd 100644
--- a/kernel/taskstats.c
+++ b/kernel/taskstats.c
@@ -673,7 +673,7 @@ err:
 	nlmsg_free(rep_skb);
 }
 
-static struct genl_ops taskstats_ops[] = {
+static const struct genl_ops taskstats_ops[] = {
 	{
 		.cmd		= TASKSTATS_CMD_GET,
 		.doit		= taskstats_user_cmd,
diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index 5e78d44..f9fe2f2 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -333,7 +333,7 @@ out:
 	return NOTIFY_DONE;
 }
 
-static struct genl_ops dropmon_ops[] = {
+static const struct genl_ops dropmon_ops[] = {
 	{
 		.cmd = NET_DM_CMD_CONFIG,
 		.doit = net_dm_cmd_config,
diff --git a/net/hsr/hsr_netlink.c b/net/hsr/hsr_netlink.c
index 8f52a9f..79d72ca 100644
--- a/net/hsr/hsr_netlink.c
+++ b/net/hsr/hsr_netlink.c
@@ -389,7 +389,7 @@ fail:
 }
 
 
-static struct genl_ops hsr_ops[] = {
+static const struct genl_ops hsr_ops[] = {
 	{
 		.cmd = HSR_C_GET_NODE_STATUS,
 		.flags = 0,
diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
index eb9faef..3ffcdbb 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -109,7 +109,7 @@ out:
 	return -ENOBUFS;
 }
 
-static struct genl_ops ieee8021154_ops[] = {
+static const struct genl_ops ieee8021154_ops[] = {
 	/* see nl-phy.c */
 	IEEE802154_DUMP(IEEE802154_LIST_PHY, ieee802154_list_phy,
 			ieee802154_dump_phy),
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 2ab09cb..9b780c1 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -988,7 +988,7 @@ static int tcp_metrics_nl_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	return 0;
 }
 
-static struct genl_ops tcp_metrics_nl_ops[] = {
+static const struct genl_ops tcp_metrics_nl_ops[] = {
 	{
 		.cmd = TCP_METRICS_CMD_GET,
 		.doit = tcp_metrics_nl_cmd_get,
diff --git a/net/irda/irnetlink.c b/net/irda/irnetlink.c
index c3297126..bf5d7d4 100644
--- a/net/irda/irnetlink.c
+++ b/net/irda/irnetlink.c
@@ -131,7 +131,7 @@ static const struct nla_policy irda_nl_policy[IRDA_NL_ATTR_MAX + 1] = {
 	[IRDA_NL_ATTR_MODE] = { .type = NLA_U32 },
 };
 
-static struct genl_ops irda_nl_ops[] = {
+static const struct genl_ops irda_nl_ops[] = {
 	{
 		.cmd = IRDA_NL_CMD_SET_MODE,
 		.doit = irda_nl_set_mode,
diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index be446d5..57db66e 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -793,7 +793,7 @@ static struct nla_policy l2tp_nl_policy[L2TP_ATTR_MAX + 1] = {
 	},
 };
 
-static struct genl_ops l2tp_nl_ops[] = {
+static const struct genl_ops l2tp_nl_ops[] = {
 	{
 		.cmd = L2TP_CMD_NOOP,
 		.doit = l2tp_nl_cmd_noop,
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 62786a4..fc8a04e 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3567,7 +3567,7 @@ out:
 }
 
 
-static struct genl_ops ip_vs_genl_ops[] __read_mostly = {
+static const struct genl_ops ip_vs_genl_ops[] __read_mostly = {
 	{
 		.cmd	= IPVS_CMD_NEW_SERVICE,
 		.flags	= GENL_ADMIN_PERM,
diff --git a/net/netlabel/netlabel_cipso_v4.c b/net/netlabel/netlabel_cipso_v4.c
index a110064..7066917 100644
--- a/net/netlabel/netlabel_cipso_v4.c
+++ b/net/netlabel/netlabel_cipso_v4.c
@@ -737,7 +737,7 @@ static int netlbl_cipsov4_remove(struct sk_buff *skb, struct genl_info *info)
  * NetLabel Generic NETLINK Command Definitions
  */
 
-static struct genl_ops netlbl_cipsov4_ops[] = {
+static const struct genl_ops netlbl_cipsov4_ops[] = {
 	{
 	.cmd = NLBL_CIPSOV4_C_ADD,
 	.flags = GENL_ADMIN_PERM,
diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
index dd1c37d..7de6f66 100644
--- a/net/netlabel/netlabel_mgmt.c
+++ b/net/netlabel/netlabel_mgmt.c
@@ -705,7 +705,7 @@ version_failure:
  * NetLabel Generic NETLINK Command Definitions
  */
 
-static struct genl_ops netlbl_mgmt_genl_ops[] = {
+static const struct genl_ops netlbl_mgmt_genl_ops[] = {
 	{
 	.cmd = NLBL_MGMT_C_ADD,
 	.flags = GENL_ADMIN_PERM,
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 8f08974..76ee925 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -1323,7 +1323,7 @@ unlabel_staticlistdef_return:
  * NetLabel Generic NETLINK Command Definitions
  */
 
-static struct genl_ops netlbl_unlabel_genl_ops[] = {
+static const struct genl_ops netlbl_unlabel_genl_ops[] = {
 	{
 	.cmd = NLBL_UNLABEL_C_STATICADD,
 	.flags = GENL_ADMIN_PERM,
diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
index 84b7e3e..f558561 100644
--- a/net/nfc/netlink.c
+++ b/net/nfc/netlink.c
@@ -1364,7 +1364,7 @@ static int nfc_genl_se_io(struct sk_buff *skb, struct genl_info *info)
 	return dev->ops->se_io(dev, se_idx, apdu, apdu_len, se_io_cb, ctx);
 }
 
-static struct genl_ops nfc_genl_ops[] = {
+static const struct genl_ops nfc_genl_ops[] = {
 	{
 		.cmd = NFC_CMD_GET_DEVICE,
 		.doit = nfc_genl_get_device,
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 1408adc..91e1c92 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -557,7 +557,7 @@ static const struct nla_policy packet_policy[OVS_PACKET_ATTR_MAX + 1] = {
 	[OVS_PACKET_ATTR_ACTIONS] = { .type = NLA_NESTED },
 };
 
-static struct genl_ops dp_packet_genl_ops[] = {
+static const struct genl_ops dp_packet_genl_ops[] = {
 	{ .cmd = OVS_PACKET_CMD_EXECUTE,
 	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
 	  .policy = packet_policy,
@@ -1034,7 +1034,7 @@ static int ovs_flow_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	return skb->len;
 }
 
-static struct genl_ops dp_flow_genl_ops[] = {
+static const struct genl_ops dp_flow_genl_ops[] = {
 	{ .cmd = OVS_FLOW_CMD_NEW,
 	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
 	  .policy = flow_policy,
@@ -1392,7 +1392,7 @@ static int ovs_dp_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	return skb->len;
 }
 
-static struct genl_ops dp_datapath_genl_ops[] = {
+static const struct genl_ops dp_datapath_genl_ops[] = {
 	{ .cmd = OVS_DP_CMD_NEW,
 	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
 	  .policy = datapath_policy,
@@ -1753,7 +1753,7 @@ out:
 	return skb->len;
 }
 
-static struct genl_ops dp_vport_genl_ops[] = {
+static const struct genl_ops dp_vport_genl_ops[] = {
 	{ .cmd = OVS_VPORT_CMD_NEW,
 	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
 	  .policy = vport_policy,
@@ -1779,7 +1779,7 @@ static struct genl_ops dp_vport_genl_ops[] = {
 
 struct genl_family_and_ops {
 	struct genl_family *family;
-	struct genl_ops *ops;
+	const struct genl_ops *ops;
 	int n_ops;
 	struct genl_multicast_group *group;
 };
diff --git a/net/wimax/stack.c b/net/wimax/stack.c
index 4b7f15a..47170c9 100644
--- a/net/wimax/stack.c
+++ b/net/wimax/stack.c
@@ -415,7 +415,7 @@ static const struct nla_policy wimax_gnl_policy[WIMAX_GNL_ATTR_MAX + 1] = {
 	},
 };
 
-static struct genl_ops wimax_gnl_ops[] = {
+static const struct genl_ops wimax_gnl_ops[] = {
 	{
 		.cmd = WIMAX_GNL_OP_MSG_FROM_USER,
 		.flags = GENL_ADMIN_PERM,
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 3fef559..58c43c8 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -8937,7 +8937,7 @@ static void nl80211_post_doit(const struct genl_ops *ops, struct sk_buff *skb,
 		rtnl_unlock();
 }
 
-static struct genl_ops nl80211_ops[] = {
+static const struct genl_ops nl80211_ops[] = {
 	{
 		.cmd = NL80211_CMD_GET_WIPHY,
 		.doit = nl80211_get_wiphy,
-- 
1.8.4.rc3

