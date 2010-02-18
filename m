From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] const: struct nla_policy
Date: Thu, 18 Feb 2010 20:14:31 +0200
Message-ID: <20100218181431.GC21184@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:42130 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751364Ab0BRSOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 13:14:30 -0500
Received: by fxm20 with SMTP id 20so9317601fxm.21
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2010 10:14:29 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make remaining netlink policies as const.
Fixup coding style where needed.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netlink.h    |    2 +-
 kernel/taskstats.c       |    6 ++----
 net/dcb/dcbnl.c          |   16 ++++++++--------
 net/irda/irnetlink.c     |    2 +-
 net/wimax/op-msg.c       |    3 +--
 net/wimax/op-reset.c     |    3 +--
 net/wimax/op-rfkill.c    |    3 +--
 net/wimax/op-state-get.c |    3 +--
 net/wimax/stack.c        |    3 +--
 net/wireless/nl80211.c   |   14 +++++---------
 10 files changed, 22 insertions(+), 33 deletions(-)

--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -196,7 +196,7 @@ enum {
  *    All other            Exact length of attribute payload
  *
  * Example:
- * static struct nla_policy my_policy[ATTR_MAX+1] __read_mostly = {
+ * static const struct nla_policy my_policy[ATTR_MAX+1] = {
  * 	[ATTR_FOO] = { .type = NLA_U16 },
  *	[ATTR_BAR] = { .type = NLA_STRING, .len = BARSIZ },
  *	[ATTR_BAZ] = { .len = sizeof(struct mystruct) },
--- a/kernel/taskstats.c
+++ b/kernel/taskstats.c
@@ -46,15 +46,13 @@ static struct genl_family family = {
 	.maxattr	= TASKSTATS_CMD_ATTR_MAX,
 };
 
-static struct nla_policy taskstats_cmd_get_policy[TASKSTATS_CMD_ATTR_MAX+1]
-__read_mostly = {
+static const struct nla_policy taskstats_cmd_get_policy[TASKSTATS_CMD_ATTR_MAX+1] = {
 	[TASKSTATS_CMD_ATTR_PID]  = { .type = NLA_U32 },
 	[TASKSTATS_CMD_ATTR_TGID] = { .type = NLA_U32 },
 	[TASKSTATS_CMD_ATTR_REGISTER_CPUMASK] = { .type = NLA_STRING },
 	[TASKSTATS_CMD_ATTR_DEREGISTER_CPUMASK] = { .type = NLA_STRING },};
 
-static struct nla_policy
-cgroupstats_cmd_get_policy[CGROUPSTATS_CMD_ATTR_MAX+1] __read_mostly = {
+static const struct nla_policy cgroupstats_cmd_get_policy[CGROUPSTATS_CMD_ATTR_MAX+1] = {
 	[CGROUPSTATS_CMD_ATTR_FD] = { .type = NLA_U32 },
 };
 
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -54,7 +54,7 @@ MODULE_LICENSE("GPL");
 /**************** DCB attribute policies *************************************/
 
 /* DCB netlink attributes policy */
-static struct nla_policy dcbnl_rtnl_policy[DCB_ATTR_MAX + 1] = {
+static const struct nla_policy dcbnl_rtnl_policy[DCB_ATTR_MAX + 1] = {
 	[DCB_ATTR_IFNAME]      = {.type = NLA_NUL_STRING, .len = IFNAMSIZ - 1},
 	[DCB_ATTR_STATE]       = {.type = NLA_U8},
 	[DCB_ATTR_PFC_CFG]     = {.type = NLA_NESTED},
@@ -68,7 +68,7 @@ static struct nla_policy dcbnl_rtnl_policy[DCB_ATTR_MAX + 1] = {
 };
 
 /* DCB priority flow control to User Priority nested attributes */
-static struct nla_policy dcbnl_pfc_up_nest[DCB_PFC_UP_ATTR_MAX + 1] = {
+static const struct nla_policy dcbnl_pfc_up_nest[DCB_PFC_UP_ATTR_MAX + 1] = {
 	[DCB_PFC_UP_ATTR_0]   = {.type = NLA_U8},
 	[DCB_PFC_UP_ATTR_1]   = {.type = NLA_U8},
 	[DCB_PFC_UP_ATTR_2]   = {.type = NLA_U8},
@@ -81,7 +81,7 @@ static struct nla_policy dcbnl_pfc_up_nest[DCB_PFC_UP_ATTR_MAX + 1] = {
 };
 
 /* DCB priority grouping nested attributes */
-static struct nla_policy dcbnl_pg_nest[DCB_PG_ATTR_MAX + 1] = {
+static const struct nla_policy dcbnl_pg_nest[DCB_PG_ATTR_MAX + 1] = {
 	[DCB_PG_ATTR_TC_0]      = {.type = NLA_NESTED},
 	[DCB_PG_ATTR_TC_1]      = {.type = NLA_NESTED},
 	[DCB_PG_ATTR_TC_2]      = {.type = NLA_NESTED},
@@ -103,7 +103,7 @@ static struct nla_policy dcbnl_pg_nest[DCB_PG_ATTR_MAX + 1] = {
 };
 
 /* DCB traffic class nested attributes. */
-static struct nla_policy dcbnl_tc_param_nest[DCB_TC_ATTR_PARAM_MAX + 1] = {
+static const struct nla_policy dcbnl_tc_param_nest[DCB_TC_ATTR_PARAM_MAX + 1] = {
 	[DCB_TC_ATTR_PARAM_PGID]            = {.type = NLA_U8},
 	[DCB_TC_ATTR_PARAM_UP_MAPPING]      = {.type = NLA_U8},
 	[DCB_TC_ATTR_PARAM_STRICT_PRIO]     = {.type = NLA_U8},
@@ -112,7 +112,7 @@ static struct nla_policy dcbnl_tc_param_nest[DCB_TC_ATTR_PARAM_MAX + 1] = {
 };
 
 /* DCB capabilities nested attributes. */
-static struct nla_policy dcbnl_cap_nest[DCB_CAP_ATTR_MAX + 1] = {
+static const struct nla_policy dcbnl_cap_nest[DCB_CAP_ATTR_MAX + 1] = {
 	[DCB_CAP_ATTR_ALL]     = {.type = NLA_FLAG},
 	[DCB_CAP_ATTR_PG]      = {.type = NLA_U8},
 	[DCB_CAP_ATTR_PFC]     = {.type = NLA_U8},
@@ -124,14 +124,14 @@ static struct nla_policy dcbnl_cap_nest[DCB_CAP_ATTR_MAX + 1] = {
 };
 
 /* DCB capabilities nested attributes. */
-static struct nla_policy dcbnl_numtcs_nest[DCB_NUMTCS_ATTR_MAX + 1] = {
+static const struct nla_policy dcbnl_numtcs_nest[DCB_NUMTCS_ATTR_MAX + 1] = {
 	[DCB_NUMTCS_ATTR_ALL]     = {.type = NLA_FLAG},
 	[DCB_NUMTCS_ATTR_PG]      = {.type = NLA_U8},
 	[DCB_NUMTCS_ATTR_PFC]     = {.type = NLA_U8},
 };
 
 /* DCB BCN nested attributes. */
-static struct nla_policy dcbnl_bcn_nest[DCB_BCN_ATTR_MAX + 1] = {
+static const struct nla_policy dcbnl_bcn_nest[DCB_BCN_ATTR_MAX + 1] = {
 	[DCB_BCN_ATTR_RP_0]         = {.type = NLA_U8},
 	[DCB_BCN_ATTR_RP_1]         = {.type = NLA_U8},
 	[DCB_BCN_ATTR_RP_2]         = {.type = NLA_U8},
@@ -160,7 +160,7 @@ static struct nla_policy dcbnl_bcn_nest[DCB_BCN_ATTR_MAX + 1] = {
 };
 
 /* DCB APP nested attributes. */
-static struct nla_policy dcbnl_app_nest[DCB_APP_ATTR_MAX + 1] = {
+static const struct nla_policy dcbnl_app_nest[DCB_APP_ATTR_MAX + 1] = {
 	[DCB_APP_ATTR_IDTYPE]       = {.type = NLA_U8},
 	[DCB_APP_ATTR_ID]           = {.type = NLA_U16},
 	[DCB_APP_ATTR_PRIORITY]     = {.type = NLA_U8},
--- a/net/irda/irnetlink.c
+++ b/net/irda/irnetlink.c
@@ -124,7 +124,7 @@ static int irda_nl_get_mode(struct sk_buff *skb, struct genl_info *info)
 	return ret;
 }
 
-static struct nla_policy irda_nl_policy[IRDA_NL_ATTR_MAX + 1] = {
+static const struct nla_policy irda_nl_policy[IRDA_NL_ATTR_MAX + 1] = {
 	[IRDA_NL_ATTR_IFNAME] = { .type = NLA_NUL_STRING,
 				  .len = IFNAMSIZ-1 },
 	[IRDA_NL_ATTR_MODE] = { .type = NLA_U32 },
--- a/net/wimax/op-msg.c
+++ b/net/wimax/op-msg.c
@@ -320,8 +320,7 @@ int wimax_msg(struct wimax_dev *wimax_dev, const char *pipe_name,
 EXPORT_SYMBOL_GPL(wimax_msg);
 
 
-static const
-struct nla_policy wimax_gnl_msg_policy[WIMAX_GNL_ATTR_MAX + 1] = {
+static const struct nla_policy wimax_gnl_msg_policy[WIMAX_GNL_ATTR_MAX + 1] = {
 	[WIMAX_GNL_MSG_IFIDX] = {
 		.type = NLA_U32,
 	},
--- a/net/wimax/op-reset.c
+++ b/net/wimax/op-reset.c
@@ -91,8 +91,7 @@ int wimax_reset(struct wimax_dev *wimax_dev)
 EXPORT_SYMBOL(wimax_reset);
 
 
-static const
-struct nla_policy wimax_gnl_reset_policy[WIMAX_GNL_ATTR_MAX + 1] = {
+static const struct nla_policy wimax_gnl_reset_policy[WIMAX_GNL_ATTR_MAX + 1] = {
 	[WIMAX_GNL_RESET_IFIDX] = {
 		.type = NLA_U32,
 	},
--- a/net/wimax/op-rfkill.c
+++ b/net/wimax/op-rfkill.c
@@ -410,8 +410,7 @@ void wimax_rfkill_rm(struct wimax_dev *wimax_dev)
  * just query).
  */
 
-static const
-struct nla_policy wimax_gnl_rfkill_policy[WIMAX_GNL_ATTR_MAX + 1] = {
+static const struct nla_policy wimax_gnl_rfkill_policy[WIMAX_GNL_ATTR_MAX + 1] = {
 	[WIMAX_GNL_RFKILL_IFIDX] = {
 		.type = NLA_U32,
 	},
--- a/net/wimax/op-state-get.c
+++ b/net/wimax/op-state-get.c
@@ -33,8 +33,7 @@
 #include "debug-levels.h"
 
 
-static const
-struct nla_policy wimax_gnl_state_get_policy[WIMAX_GNL_ATTR_MAX + 1] = {
+static const struct nla_policy wimax_gnl_state_get_policy[WIMAX_GNL_ATTR_MAX + 1] = {
 	[WIMAX_GNL_STGET_IFIDX] = {
 		.type = NLA_U32,
 	},
--- a/net/wimax/stack.c
+++ b/net/wimax/stack.c
@@ -75,8 +75,7 @@ MODULE_PARM_DESC(debug,
  * close to where the data is generated.
  */
 /*
-static const
-struct nla_policy wimax_gnl_re_status_change[WIMAX_GNL_ATTR_MAX + 1] = {
+static const struct nla_policy wimax_gnl_re_status_change[WIMAX_GNL_ATTR_MAX + 1] = {
 	[WIMAX_GNL_STCH_STATE_OLD] = { .type = NLA_U8 },
 	[WIMAX_GNL_STCH_STATE_NEW] = { .type = NLA_U8 },
 };
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -58,7 +58,7 @@ static int get_rdev_dev_by_info_ifindex(struct genl_info *info,
 }
 
 /* policy for the attributes */
-static struct nla_policy nl80211_policy[NL80211_ATTR_MAX+1] __read_mostly = {
+static const struct nla_policy nl80211_policy[NL80211_ATTR_MAX+1] = {
 	[NL80211_ATTR_WIPHY] = { .type = NLA_U32 },
 	[NL80211_ATTR_WIPHY_NAME] = { .type = NLA_NUL_STRING,
 				      .len = 20-1 },
@@ -148,8 +148,7 @@ static struct nla_policy nl80211_policy[NL80211_ATTR_MAX+1] __read_mostly = {
 };
 
 /* policy for the attributes */
-static struct nla_policy
-nl80211_key_policy[NL80211_KEY_MAX + 1] __read_mostly = {
+static const struct nla_policy nl80211_key_policy[NL80211_KEY_MAX + 1] = {
 	[NL80211_KEY_DATA] = { .type = NLA_BINARY, .len = WLAN_MAX_KEY_LEN },
 	[NL80211_KEY_IDX] = { .type = NLA_U8 },
 	[NL80211_KEY_CIPHER] = { .type = NLA_U32 },
@@ -2501,8 +2500,7 @@ static int nl80211_set_bss(struct sk_buff *skb, struct genl_info *info)
 	return err;
 }
 
-static const struct nla_policy
-	reg_rule_policy[NL80211_REG_RULE_ATTR_MAX + 1] = {
+static const struct nla_policy reg_rule_policy[NL80211_REG_RULE_ATTR_MAX + 1] = {
 	[NL80211_ATTR_REG_RULE_FLAGS]		= { .type = NLA_U32 },
 	[NL80211_ATTR_FREQ_RANGE_START]		= { .type = NLA_U32 },
 	[NL80211_ATTR_FREQ_RANGE_END]		= { .type = NLA_U32 },
@@ -2671,8 +2669,7 @@ do {\
 	} \
 } while (0);\
 
-static struct nla_policy
-nl80211_meshconf_params_policy[NL80211_MESHCONF_ATTR_MAX+1] __read_mostly = {
+static const struct nla_policy nl80211_meshconf_params_policy[NL80211_MESHCONF_ATTR_MAX+1] = {
 	[NL80211_MESHCONF_RETRY_TIMEOUT] = { .type = NLA_U16 },
 	[NL80211_MESHCONF_CONFIRM_TIMEOUT] = { .type = NLA_U16 },
 	[NL80211_MESHCONF_HOLDING_TIMEOUT] = { .type = NLA_U16 },
@@ -4470,8 +4467,7 @@ static u32 rateset_to_mask(struct ieee80211_supported_band *sband,
 	return mask;
 }
 
-static struct nla_policy
-nl80211_txattr_policy[NL80211_TXRATE_MAX + 1] __read_mostly = {
+static const struct nla_policy nl80211_txattr_policy[NL80211_TXRATE_MAX + 1] = {
 	[NL80211_TXRATE_LEGACY] = { .type = NLA_BINARY,
 				    .len = NL80211_MAX_SUPP_RATES },
 };
