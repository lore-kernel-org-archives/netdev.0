From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 5/5] genetlink: mark families as __ro_after_init
Date: Mon, 24 Oct 2016 14:40:05 +0200
Message-ID: <1477312805-7110-6-git-send-email-johannes@sipsolutions.net>
References: <1477312805-7110-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:51702 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S938749AbcJXMkM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Oct 2016 08:40:12 -0400
In-Reply-To: <1477312805-7110-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Now genl_register_family() is the only thing (other than the
users themselves, perhaps, but I didn't find any doing that)
writing to the family struct.

In all families that I found, genl_register_family() is only
called from __init functions (some indirectly, in which case
I've add __init annotations to clarifly things), so all can
actually be marked __ro_after_init.

This protects the data structure from accidental corruption.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
I can split this patch up and send it to all the owners of
the code later, if you prefer.
---
 drivers/acpi/event.c                  |  4 ++--
 drivers/net/gtp.c                     |  2 +-
 drivers/net/macsec.c                  |  2 +-
 drivers/net/team/team.c               |  4 ++--
 drivers/net/wireless/mac80211_hwsim.c |  4 ++--
 drivers/scsi/pmcraid.c                |  4 ++--
 drivers/target/target_core_user.c     |  2 +-
 drivers/thermal/thermal_core.c        |  4 ++--
 fs/dlm/netlink.c                      |  2 +-
 fs/quota/netlink.c                    |  2 +-
 include/linux/genl_magic_func.h       |  2 +-
 kernel/taskstats.c                    |  2 +-
 net/batman-adv/netlink.c              |  2 +-
 net/core/devlink.c                    |  2 +-
 net/core/drop_monitor.c               |  2 +-
 net/hsr/hsr_netlink.c                 |  2 +-
 net/ieee802154/netlink.c              |  2 +-
 net/ieee802154/nl802154.c             |  4 ++--
 net/ipv4/fou.c                        |  2 +-
 net/ipv4/tcp_metrics.c                |  2 +-
 net/ipv6/ila/ila_xlat.c               |  4 ++--
 net/irda/irnetlink.c                  |  4 ++--
 net/l2tp/l2tp_netlink.c               |  4 ++--
 net/netfilter/ipvs/ip_vs_ctl.c        |  2 +-
 net/netlabel/netlabel_calipso.c       |  2 +-
 net/netlabel/netlabel_cipso_v4.c      |  2 +-
 net/netlabel/netlabel_mgmt.c          |  2 +-
 net/netlabel/netlabel_unlabeled.c     |  2 +-
 net/netlink/genetlink.c               |  2 +-
 net/nfc/netlink.c                     |  2 +-
 net/openvswitch/datapath.c            | 10 +++++-----
 net/tipc/netlink.c                    |  4 ++--
 net/tipc/netlink_compat.c             |  4 ++--
 net/wimax/stack.c                     |  2 +-
 net/wireless/nl80211.c                |  4 ++--
 35 files changed, 51 insertions(+), 51 deletions(-)

diff --git a/drivers/acpi/event.c b/drivers/acpi/event.c
index 1ab12ad7d5ba..7fceb3b4691b 100644
--- a/drivers/acpi/event.c
+++ b/drivers/acpi/event.c
@@ -82,7 +82,7 @@ static const struct genl_multicast_group acpi_event_mcgrps[] = {
 	{ .name = ACPI_GENL_MCAST_GROUP_NAME, },
 };
 
-static struct genl_family acpi_event_genl_family = {
+static struct genl_family acpi_event_genl_family __ro_after_init = {
 	.module = THIS_MODULE,
 	.name = ACPI_GENL_FAMILY_NAME,
 	.version = ACPI_GENL_VERSION,
@@ -144,7 +144,7 @@ int acpi_bus_generate_netlink_event(const char *device_class,
 
 EXPORT_SYMBOL(acpi_bus_generate_netlink_event);
 
-static int acpi_event_genetlink_init(void)
+static int __init acpi_event_genetlink_init(void)
 {
 	return genl_register_family(&acpi_event_genl_family);
 }
diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 0604fd78f826..719d19f35673 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -1290,7 +1290,7 @@ static const struct genl_ops gtp_genl_ops[] = {
 	},
 };
 
-static struct genl_family gtp_genl_family = {
+static struct genl_family gtp_genl_family __ro_after_init = {
 	.name		= "gtp",
 	.version	= 0,
 	.hdrsize	= 0,
diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 63ca7a3c77cf..0a715ab9d9cc 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -2648,7 +2648,7 @@ static const struct genl_ops macsec_genl_ops[] = {
 	},
 };
 
-static struct genl_family macsec_fam = {
+static struct genl_family macsec_fam __ro_after_init = {
 	.name		= MACSEC_GENL_NAME,
 	.hdrsize	= 0,
 	.version	= MACSEC_GENL_VERSION,
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 46bf7c1216c0..bdc58567d10e 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2740,7 +2740,7 @@ static const struct genl_multicast_group team_nl_mcgrps[] = {
 	{ .name = TEAM_GENL_CHANGE_EVENT_MC_GRP_NAME, },
 };
 
-static struct genl_family team_nl_family = {
+static struct genl_family team_nl_family __ro_after_init = {
 	.name		= TEAM_GENL_NAME,
 	.version	= TEAM_GENL_VERSION,
 	.maxattr	= TEAM_ATTR_MAX,
@@ -2773,7 +2773,7 @@ static int team_nl_send_event_port_get(struct team *team,
 					  port);
 }
 
-static int team_nl_init(void)
+static int __init team_nl_init(void)
 {
 	return genl_register_family(&team_nl_family);
 }
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 5d4637e586e8..220e9dc8ccf8 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -3228,7 +3228,7 @@ static const struct genl_ops hwsim_ops[] = {
 	},
 };
 
-static struct genl_family hwsim_genl_family = {
+static struct genl_family hwsim_genl_family __ro_after_init = {
 	.name = "MAC80211_HWSIM",
 	.version = 1,
 	.maxattr = HWSIM_ATTR_MAX,
@@ -3287,7 +3287,7 @@ static struct notifier_block hwsim_netlink_notifier = {
 	.notifier_call = mac80211_hwsim_netlink_notify,
 };
 
-static int hwsim_init_netlink(void)
+static int __init hwsim_init_netlink(void)
 {
 	int rc;
 
diff --git a/drivers/scsi/pmcraid.c b/drivers/scsi/pmcraid.c
index c0ab7bb8c3ce..845affa112f7 100644
--- a/drivers/scsi/pmcraid.c
+++ b/drivers/scsi/pmcraid.c
@@ -1368,7 +1368,7 @@ static struct genl_multicast_group pmcraid_mcgrps[] = {
 	{ .name = "events", /* not really used - see ID discussion below */ },
 };
 
-static struct genl_family pmcraid_event_family = {
+static struct genl_family pmcraid_event_family __ro_after_init = {
 	.module = THIS_MODULE,
 	.name = "pmcraid",
 	.version = 1,
@@ -1384,7 +1384,7 @@ static struct genl_family pmcraid_event_family = {
  *	0 if the pmcraid_event_family is successfully registered
  *	with netlink generic, non-zero otherwise
  */
-static int pmcraid_netlink_init(void)
+static int __init pmcraid_netlink_init(void)
 {
 	int result;
 
diff --git a/drivers/target/target_core_user.c b/drivers/target/target_core_user.c
index 3483372f5562..0f173bf7dbac 100644
--- a/drivers/target/target_core_user.c
+++ b/drivers/target/target_core_user.c
@@ -147,7 +147,7 @@ static const struct genl_multicast_group tcmu_mcgrps[] = {
 };
 
 /* Our generic netlink family */
-static struct genl_family tcmu_genl_family = {
+static struct genl_family tcmu_genl_family __ro_after_init = {
 	.module = THIS_MODULE,
 	.hdrsize = 0,
 	.name = "TCM-USER",
diff --git a/drivers/thermal/thermal_core.c b/drivers/thermal/thermal_core.c
index 93b6caab2d9f..911fd964c742 100644
--- a/drivers/thermal/thermal_core.c
+++ b/drivers/thermal/thermal_core.c
@@ -2163,7 +2163,7 @@ static const struct genl_multicast_group thermal_event_mcgrps[] = {
 	{ .name = THERMAL_GENL_MCAST_GROUP_NAME, },
 };
 
-static struct genl_family thermal_event_genl_family = {
+static struct genl_family thermal_event_genl_family __ro_after_init = {
 	.module = THIS_MODULE,
 	.name = THERMAL_GENL_FAMILY_NAME,
 	.version = THERMAL_GENL_VERSION,
@@ -2235,7 +2235,7 @@ int thermal_generate_netlink_event(struct thermal_zone_device *tz,
 }
 EXPORT_SYMBOL_GPL(thermal_generate_netlink_event);
 
-static int genetlink_init(void)
+static int __init genetlink_init(void)
 {
 	return genl_register_family(&thermal_event_genl_family);
 }
diff --git a/fs/dlm/netlink.c b/fs/dlm/netlink.c
index 04042d69573c..0643ae44f342 100644
--- a/fs/dlm/netlink.c
+++ b/fs/dlm/netlink.c
@@ -72,7 +72,7 @@ static struct genl_ops dlm_nl_ops[] = {
 	},
 };
 
-static struct genl_family family = {
+static struct genl_family family __ro_after_init = {
 	.name		= DLM_GENL_NAME,
 	.version	= DLM_GENL_VERSION,
 	.ops		= dlm_nl_ops,
diff --git a/fs/quota/netlink.c b/fs/quota/netlink.c
index 9457c7b0dfa2..e99b1a72d9a7 100644
--- a/fs/quota/netlink.c
+++ b/fs/quota/netlink.c
@@ -12,7 +12,7 @@ static const struct genl_multicast_group quota_mcgrps[] = {
 };
 
 /* Netlink family structure for quota */
-static struct genl_family quota_genl_family = {
+static struct genl_family quota_genl_family __ro_after_init = {
 	.module = THIS_MODULE,
 	.hdrsize = 0,
 	.name = "VFS_DQUOT",
diff --git a/include/linux/genl_magic_func.h b/include/linux/genl_magic_func.h
index 40c2e39362c8..377257d8f7e3 100644
--- a/include/linux/genl_magic_func.h
+++ b/include/linux/genl_magic_func.h
@@ -293,7 +293,7 @@ static int CONCAT_(GENL_MAGIC_FAMILY, _genl_multicast_ ## group)(	\
 #undef GENL_mc_group
 #define GENL_mc_group(group)
 
-static struct genl_family ZZZ_genl_family __read_mostly = {
+static struct genl_family ZZZ_genl_family __ro_after_init = {
 	.name = __stringify(GENL_MAGIC_FAMILY),
 	.version = GENL_MAGIC_VERSION,
 #ifdef GENL_MAGIC_FAMILY_HDRSZ
diff --git a/kernel/taskstats.c b/kernel/taskstats.c
index 4075ece592f2..9b7f838511ce 100644
--- a/kernel/taskstats.c
+++ b/kernel/taskstats.c
@@ -646,7 +646,7 @@ static const struct genl_ops taskstats_ops[] = {
 	},
 };
 
-static struct genl_family family = {
+static struct genl_family family __ro_after_init = {
 	.name		= TASKSTATS_GENL_NAME,
 	.version	= TASKSTATS_GENL_VERSION,
 	.maxattr	= TASKSTATS_CMD_ATTR_MAX,
diff --git a/net/batman-adv/netlink.c b/net/batman-adv/netlink.c
index e28cec34a016..005012ba9b48 100644
--- a/net/batman-adv/netlink.c
+++ b/net/batman-adv/netlink.c
@@ -603,7 +603,7 @@ static struct genl_ops batadv_netlink_ops[] = {
 
 };
 
-struct genl_family batadv_netlink_family = {
+struct genl_family batadv_netlink_family __ro_after_init = {
 	.hdrsize = 0,
 	.name = BATADV_NL_NAME,
 	.version = 1,
diff --git a/net/core/devlink.c b/net/core/devlink.c
index 6f01d41b1851..3a90b5005839 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -1610,7 +1610,7 @@ static const struct genl_ops devlink_nl_ops[] = {
 	},
 };
 
-static struct genl_family devlink_nl_family = {
+static struct genl_family devlink_nl_family __ro_after_init = {
 	.name		= DEVLINK_GENL_NAME,
 	.version	= DEVLINK_GENL_VERSION,
 	.maxattr	= DEVLINK_ATTR_MAX,
diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index 80c002794ff6..8e0c0635ee97 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -346,7 +346,7 @@ static const struct genl_ops dropmon_ops[] = {
 	},
 };
 
-static struct genl_family net_drop_monitor_family = {
+static struct genl_family net_drop_monitor_family __ro_after_init = {
 	.hdrsize        = 0,
 	.name           = "NET_DM",
 	.version        = 2,
diff --git a/net/hsr/hsr_netlink.c b/net/hsr/hsr_netlink.c
index aab34c7f6f89..1ab30e7d3f99 100644
--- a/net/hsr/hsr_netlink.c
+++ b/net/hsr/hsr_netlink.c
@@ -461,7 +461,7 @@ static const struct genl_ops hsr_ops[] = {
 	},
 };
 
-static struct genl_family hsr_genl_family = {
+static struct genl_family hsr_genl_family __ro_after_init = {
 	.hdrsize = 0,
 	.name = "HSR",
 	.version = 1,
diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
index 08e62470bac2..6bde9e5a5503 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -131,7 +131,7 @@ static const struct genl_multicast_group ieee802154_mcgrps[] = {
 	[IEEE802154_BEACON_MCGRP] = { .name = IEEE802154_MCAST_BEACON_NAME, },
 };
 
-struct genl_family nl802154_family = {
+struct genl_family nl802154_family __ro_after_init = {
 	.hdrsize	= 0,
 	.name		= IEEE802154_NL_NAME,
 	.version	= 1,
diff --git a/net/ieee802154/nl802154.c b/net/ieee802154/nl802154.c
index f7e75578aedd..fc60cd061f39 100644
--- a/net/ieee802154/nl802154.c
+++ b/net/ieee802154/nl802154.c
@@ -2462,7 +2462,7 @@ static const struct genl_ops nl802154_ops[] = {
 #endif /* CONFIG_IEEE802154_NL802154_EXPERIMENTAL */
 };
 
-static struct genl_family nl802154_fam = {
+static struct genl_family nl802154_fam __ro_after_init = {
 	.name = NL802154_GENL_NAME,	/* have users key off the name instead */
 	.hdrsize = 0,			/* no private header */
 	.version = 1,			/* no particular meaning now */
@@ -2478,7 +2478,7 @@ static struct genl_family nl802154_fam = {
 };
 
 /* initialisation/exit functions */
-int nl802154_init(void)
+int __init nl802154_init(void)
 {
 	return genl_register_family(&nl802154_fam);
 }
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 5b5226a2434f..6cb57bb8692d 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -824,7 +824,7 @@ static const struct genl_ops fou_nl_ops[] = {
 	},
 };
 
-static struct genl_family fou_nl_family = {
+static struct genl_family fou_nl_family __ro_after_init = {
 	.hdrsize	= 0,
 	.name		= FOU_GENL_NAME,
 	.version	= FOU_GENL_VERSION,
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index bba3c72c4a39..d46f4d5b1c62 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -1109,7 +1109,7 @@ static const struct genl_ops tcp_metrics_nl_ops[] = {
 	},
 };
 
-static struct genl_family tcp_metrics_nl_family = {
+static struct genl_family tcp_metrics_nl_family __ro_after_init = {
 	.hdrsize	= 0,
 	.name		= TCP_METRICS_GENL_NAME,
 	.version	= TCP_METRICS_GENL_VERSION,
diff --git a/net/ipv6/ila/ila_xlat.c b/net/ipv6/ila/ila_xlat.c
index 97f7b0cc4675..628ae6d85b59 100644
--- a/net/ipv6/ila/ila_xlat.c
+++ b/net/ipv6/ila/ila_xlat.c
@@ -553,7 +553,7 @@ static const struct genl_ops ila_nl_ops[] = {
 	},
 };
 
-static struct genl_family ila_nl_family = {
+static struct genl_family ila_nl_family __ro_after_init = {
 	.hdrsize	= 0,
 	.name		= ILA_GENL_NAME,
 	.version	= ILA_GENL_VERSION,
@@ -627,7 +627,7 @@ static int ila_xlat_addr(struct sk_buff *skb, bool set_csum_neutral)
 	return 0;
 }
 
-int ila_xlat_init(void)
+int __init ila_xlat_init(void)
 {
 	int ret;
 
diff --git a/net/irda/irnetlink.c b/net/irda/irnetlink.c
index 07877347c2f7..7fc340e574cf 100644
--- a/net/irda/irnetlink.c
+++ b/net/irda/irnetlink.c
@@ -141,7 +141,7 @@ static const struct genl_ops irda_nl_ops[] = {
 
 };
 
-static struct genl_family irda_nl_family = {
+static struct genl_family irda_nl_family __ro_after_init = {
 	.name = IRDA_NL_NAME,
 	.hdrsize = 0,
 	.version = IRDA_NL_VERSION,
@@ -151,7 +151,7 @@ static struct genl_family irda_nl_family = {
 	.n_ops = ARRAY_SIZE(irda_nl_ops),
 };
 
-int irda_nl_register(void)
+int __init irda_nl_register(void)
 {
 	return genl_register_family(&irda_nl_family);
 }
diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index e4e8c0769a6b..59aa2d204e4a 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -970,7 +970,7 @@ static const struct genl_ops l2tp_nl_ops[] = {
 	},
 };
 
-static struct genl_family l2tp_nl_family = {
+static struct genl_family l2tp_nl_family __ro_after_init = {
 	.name		= L2TP_GENL_NAME,
 	.version	= L2TP_GENL_VERSION,
 	.hdrsize	= 0,
@@ -1016,7 +1016,7 @@ void l2tp_nl_unregister_ops(enum l2tp_pwtype pw_type)
 }
 EXPORT_SYMBOL_GPL(l2tp_nl_unregister_ops);
 
-static int l2tp_nl_init(void)
+static int __init l2tp_nl_init(void)
 {
 	pr_info("L2TP netlink interface\n");
 	return genl_register_family(&l2tp_nl_family);
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index ea3e8aed063f..6b85ded4f91d 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3865,7 +3865,7 @@ static const struct genl_ops ip_vs_genl_ops[] = {
 	},
 };
 
-static struct genl_family ip_vs_genl_family = {
+static struct genl_family ip_vs_genl_family __ro_after_init = {
 	.hdrsize	= 0,
 	.name		= IPVS_GENL_NAME,
 	.version	= IPVS_GENL_VERSION,
diff --git a/net/netlabel/netlabel_calipso.c b/net/netlabel/netlabel_calipso.c
index ca7c9c411a5c..d177dd066504 100644
--- a/net/netlabel/netlabel_calipso.c
+++ b/net/netlabel/netlabel_calipso.c
@@ -349,7 +349,7 @@ static const struct genl_ops netlbl_calipso_ops[] = {
 	},
 };
 
-static struct genl_family netlbl_calipso_gnl_family = {
+static struct genl_family netlbl_calipso_gnl_family __ro_after_init = {
 	.hdrsize = 0,
 	.name = NETLBL_NLTYPE_CALIPSO_NAME,
 	.version = NETLBL_PROTO_VERSION,
diff --git a/net/netlabel/netlabel_cipso_v4.c b/net/netlabel/netlabel_cipso_v4.c
index a665eae91245..4149d3e63589 100644
--- a/net/netlabel/netlabel_cipso_v4.c
+++ b/net/netlabel/netlabel_cipso_v4.c
@@ -760,7 +760,7 @@ static const struct genl_ops netlbl_cipsov4_ops[] = {
 	},
 };
 
-static struct genl_family netlbl_cipsov4_gnl_family = {
+static struct genl_family netlbl_cipsov4_gnl_family __ro_after_init = {
 	.hdrsize = 0,
 	.name = NETLBL_NLTYPE_CIPSOV4_NAME,
 	.version = NETLBL_PROTO_VERSION,
diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
index ecfe8eb149db..21e0095b1d14 100644
--- a/net/netlabel/netlabel_mgmt.c
+++ b/net/netlabel/netlabel_mgmt.c
@@ -828,7 +828,7 @@ static const struct genl_ops netlbl_mgmt_genl_ops[] = {
 	},
 };
 
-static struct genl_family netlbl_mgmt_gnl_family = {
+static struct genl_family netlbl_mgmt_gnl_family __ro_after_init = {
 	.hdrsize = 0,
 	.name = NETLBL_NLTYPE_MGMT_NAME,
 	.version = NETLBL_PROTO_VERSION,
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 5dbbad41114f..22dc1b9d6362 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -1372,7 +1372,7 @@ static const struct genl_ops netlbl_unlabel_genl_ops[] = {
 	},
 };
 
-static struct genl_family netlbl_unlabel_gnl_family = {
+static struct genl_family netlbl_unlabel_gnl_family __ro_after_init = {
 	.hdrsize = 0,
 	.name = NETLBL_NLTYPE_UNLABELED_NAME,
 	.version = NETLBL_PROTO_VERSION,
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 85659921e7b2..df0cbcddda2c 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -936,7 +936,7 @@ static const struct genl_multicast_group genl_ctrl_groups[] = {
 	{ .name = "notify", },
 };
 
-static struct genl_family genl_ctrl = {
+static struct genl_family genl_ctrl __ro_after_init = {
 	.module = THIS_MODULE,
 	.ops = genl_ctrl_ops,
 	.n_ops = ARRAY_SIZE(genl_ctrl_ops),
diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
index 450b1e5144cc..03f3d5c7beb8 100644
--- a/net/nfc/netlink.c
+++ b/net/nfc/netlink.c
@@ -1746,7 +1746,7 @@ static const struct genl_ops nfc_genl_ops[] = {
 	},
 };
 
-static struct genl_family nfc_genl_family = {
+static struct genl_family nfc_genl_family __ro_after_init = {
 	.hdrsize = 0,
 	.name = NFC_GENL_NAME,
 	.version = NFC_GENL_VERSION,
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index ad6a111a0014..fa8760176b7d 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -670,7 +670,7 @@ static const struct genl_ops dp_packet_genl_ops[] = {
 	}
 };
 
-static struct genl_family dp_packet_genl_family = {
+static struct genl_family dp_packet_genl_family __ro_after_init = {
 	.hdrsize = sizeof(struct ovs_header),
 	.name = OVS_PACKET_FAMILY,
 	.version = OVS_PACKET_VERSION,
@@ -1435,7 +1435,7 @@ static const struct genl_ops dp_flow_genl_ops[] = {
 	},
 };
 
-static struct genl_family dp_flow_genl_family = {
+static struct genl_family dp_flow_genl_family __ro_after_init = {
 	.hdrsize = sizeof(struct ovs_header),
 	.name = OVS_FLOW_FAMILY,
 	.version = OVS_FLOW_VERSION,
@@ -1821,7 +1821,7 @@ static const struct genl_ops dp_datapath_genl_ops[] = {
 	},
 };
 
-static struct genl_family dp_datapath_genl_family = {
+static struct genl_family dp_datapath_genl_family __ro_after_init = {
 	.hdrsize = sizeof(struct ovs_header),
 	.name = OVS_DATAPATH_FAMILY,
 	.version = OVS_DATAPATH_VERSION,
@@ -2243,7 +2243,7 @@ static const struct genl_ops dp_vport_genl_ops[] = {
 	},
 };
 
-struct genl_family dp_vport_genl_family = {
+struct genl_family dp_vport_genl_family __ro_after_init = {
 	.hdrsize = sizeof(struct ovs_header),
 	.name = OVS_VPORT_FAMILY,
 	.version = OVS_VPORT_VERSION,
@@ -2272,7 +2272,7 @@ static void dp_unregister_genl(int n_families)
 		genl_unregister_family(dp_genl_families[i]);
 }
 
-static int dp_register_genl(void)
+static int __init dp_register_genl(void)
 {
 	int err;
 	int i;
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index 74a405bf107b..26ca8dd64ded 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -249,7 +249,7 @@ static const struct genl_ops tipc_genl_v2_ops[] = {
 #endif
 };
 
-struct genl_family tipc_genl_family = {
+struct genl_family tipc_genl_family __ro_after_init = {
 	.name		= TIPC_GENL_V2_NAME,
 	.version	= TIPC_GENL_V2_VERSION,
 	.hdrsize	= 0,
@@ -271,7 +271,7 @@ int tipc_nlmsg_parse(const struct nlmsghdr *nlh, struct nlattr ***attr)
 	return nlmsg_parse(nlh, GENL_HDRLEN, *attr, maxattr, tipc_nl_policy);
 }
 
-int tipc_netlink_start(void)
+int __init tipc_netlink_start(void)
 {
 	int res;
 
diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
index 07b19931e458..e1ae8a8a2b8e 100644
--- a/net/tipc/netlink_compat.c
+++ b/net/tipc/netlink_compat.c
@@ -1222,7 +1222,7 @@ static struct genl_ops tipc_genl_compat_ops[] = {
 	},
 };
 
-static struct genl_family tipc_genl_compat_family = {
+static struct genl_family tipc_genl_compat_family __ro_after_init = {
 	.name		= TIPC_GENL_NAME,
 	.version	= TIPC_GENL_VERSION,
 	.hdrsize	= TIPC_GENL_HDRLEN,
@@ -1233,7 +1233,7 @@ static struct genl_family tipc_genl_compat_family = {
 	.n_ops		= ARRAY_SIZE(tipc_genl_compat_ops),
 };
 
-int tipc_netlink_compat_start(void)
+int __init tipc_netlink_compat_start(void)
 {
 	int res;
 
diff --git a/net/wimax/stack.c b/net/wimax/stack.c
index 587e1627681f..5db731512014 100644
--- a/net/wimax/stack.c
+++ b/net/wimax/stack.c
@@ -576,7 +576,7 @@ static const struct genl_multicast_group wimax_gnl_mcgrps[] = {
 	{ .name = "msg", },
 };
 
-struct genl_family wimax_gnl_family = {
+struct genl_family wimax_gnl_family __ro_after_init = {
 	.name = "WiMAX",
 	.version = WIMAX_GNL_VERSION,
 	.hdrsize = 0,
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 8e5ca3c47593..271707dacfea 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -12586,7 +12586,7 @@ static const struct genl_ops nl80211_ops[] = {
 	},
 };
 
-static struct genl_family nl80211_fam = {
+static struct genl_family nl80211_fam __ro_after_init = {
 	.name = NL80211_GENL_NAME,	/* have users key off the name instead */
 	.hdrsize = 0,			/* no private header */
 	.version = 1,			/* no particular meaning now */
@@ -14563,7 +14563,7 @@ void nl80211_send_ap_stopped(struct wireless_dev *wdev)
 
 /* initialisation/exit functions */
 
-int nl80211_init(void)
+int __init nl80211_init(void)
 {
 	int err;
 
-- 
2.8.1
