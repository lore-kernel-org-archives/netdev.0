From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH v3 4/5] netlink: pass extended ACK struct to parsing functions
Date: Sat,  8 Apr 2017 22:24:33 +0200
Message-ID: <20170408202434.12018-5-johannes@sipsolutions.net>
References: <20170408202434.12018-1-johannes@sipsolutions.net>
Cc: pablo@netfilter.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Benc <jbenc@redhat.com>,
        David Ahern <dsa@cumulusnetworks.com>, jiri@resnulli.us,
        Johannes Berg <johannes.berg@intel.com>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:40658 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752415AbdDHUYq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 8 Apr 2017 16:24:46 -0400
In-Reply-To: <20170408202434.12018-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Pass the new extended ACK reporting struct to all of the
generic netlink parsing functions. For now, pass NULL in
almost all callers (except for some in the core.)

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 crypto/crypto_user.c                              |  2 +-
 drivers/block/drbd/drbd_nla.c                     |  2 +-
 drivers/infiniband/core/addr.c                    |  2 +-
 drivers/infiniband/core/iwpm_util.c               |  6 +-
 drivers/infiniband/core/sa_query.c                |  4 +-
 drivers/net/macsec.c                              | 10 +--
 drivers/net/team/team.c                           |  2 +-
 drivers/net/veth.c                                |  3 +-
 drivers/net/wireless/ath/ath10k/testmode.c        |  4 +-
 drivers/net/wireless/ath/ath6kl/testmode.c        |  4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c |  3 +-
 drivers/net/wireless/mac80211_hwsim.c             |  4 +-
 drivers/net/wireless/marvell/mwifiex/cfg80211.c   |  4 +-
 drivers/net/wireless/ti/wlcore/testmode.c         |  3 +-
 drivers/net/wireless/ti/wlcore/vendor_cmd.c       |  4 +-
 include/net/genetlink.h                           |  8 ++-
 include/net/netlink.h                             | 33 +++++++---
 include/net/rtnetlink.h                           |  3 +-
 lib/nlattr.c                                      | 28 +++++---
 net/8021q/vlan_netlink.c                          |  3 +-
 net/bridge/br_mdb.c                               |  3 +-
 net/bridge/br_netlink.c                           |  4 +-
 net/bridge/br_netlink_tunnel.c                    |  4 +-
 net/can/gw.c                                      |  2 +-
 net/core/fib_rules.c                              |  4 +-
 net/core/lwt_bpf.c                                |  5 +-
 net/core/neighbour.c                              |  8 +--
 net/core/net_namespace.c                          |  4 +-
 net/core/rtnetlink.c                              | 47 ++++++++------
 net/dcb/dcbnl.c                                   | 57 ++++++++---------
 net/decnet/dn_dev.c                               |  4 +-
 net/decnet/dn_fib.c                               |  6 +-
 net/decnet/dn_route.c                             |  2 +-
 net/ieee802154/nl802154.c                         | 29 ++++-----
 net/ipv4/devinet.c                                | 12 ++--
 net/ipv4/fib_frontend.c                           |  3 +-
 net/ipv4/ip_tunnel_core.c                         |  5 +-
 net/ipv4/ipmr.c                                   |  3 +-
 net/ipv4/route.c                                  |  3 +-
 net/ipv6/addrconf.c                               | 16 +++--
 net/ipv6/addrlabel.c                              |  4 +-
 net/ipv6/ila/ila_lwt.c                            |  3 +-
 net/ipv6/route.c                                  |  6 +-
 net/ipv6/seg6_iptunnel.c                          |  2 +-
 net/mpls/af_mpls.c                                |  5 +-
 net/mpls/mpls_iptunnel.c                          |  2 +-
 net/netfilter/ipset/ip_set_core.c                 | 27 ++++----
 net/netfilter/ipvs/ip_vs_ctl.c                    | 12 ++--
 net/netfilter/nf_conntrack_netlink.c              | 27 ++++----
 net/netfilter/nf_conntrack_proto_dccp.c           |  2 +-
 net/netfilter/nf_conntrack_proto_sctp.c           |  6 +-
 net/netfilter/nf_conntrack_proto_tcp.c            |  3 +-
 net/netfilter/nf_nat_core.c                       |  5 +-
 net/netfilter/nf_tables_api.c                     | 27 ++++----
 net/netfilter/nfnetlink.c                         | 11 ++--
 net/netfilter/nfnetlink_acct.c                    |  3 +-
 net/netfilter/nfnetlink_cthelper.c                | 12 ++--
 net/netfilter/nfnetlink_cttimeout.c               |  3 +-
 net/netfilter/nfnetlink_queue.c                   |  2 +-
 net/netfilter/nft_compat.c                        |  2 +-
 net/netlabel/netlabel_cipso_v4.c                  | 19 +++---
 net/netlink/genetlink.c                           |  2 +-
 net/nfc/netlink.c                                 |  5 +-
 net/openvswitch/datapath.c                        |  2 +-
 net/openvswitch/flow_netlink.c                    |  4 +-
 net/openvswitch/vport-vxlan.c                     |  3 +-
 net/phonet/pn_netlink.c                           |  6 +-
 net/qrtr/qrtr.c                                   |  2 +-
 net/sched/act_api.c                               | 20 +++---
 net/sched/act_bpf.c                               |  2 +-
 net/sched/act_connmark.c                          |  3 +-
 net/sched/act_csum.c                              |  2 +-
 net/sched/act_gact.c                              |  2 +-
 net/sched/act_ife.c                               |  4 +-
 net/sched/act_ipt.c                               |  2 +-
 net/sched/act_mirred.c                            |  2 +-
 net/sched/act_nat.c                               |  2 +-
 net/sched/act_pedit.c                             |  4 +-
 net/sched/act_police.c                            |  2 +-
 net/sched/act_sample.c                            |  2 +-
 net/sched/act_simple.c                            |  2 +-
 net/sched/act_skbedit.c                           |  2 +-
 net/sched/act_skbmod.c                            |  2 +-
 net/sched/act_tunnel_key.c                        |  3 +-
 net/sched/act_vlan.c                              |  2 +-
 net/sched/cls_api.c                               |  2 +-
 net/sched/cls_basic.c                             |  2 +-
 net/sched/cls_bpf.c                               |  3 +-
 net/sched/cls_cgroup.c                            |  2 +-
 net/sched/cls_flow.c                              |  2 +-
 net/sched/cls_flower.c                            |  3 +-
 net/sched/cls_fw.c                                |  2 +-
 net/sched/cls_matchall.c                          |  4 +-
 net/sched/cls_route.c                             |  2 +-
 net/sched/cls_rsvp.h                              |  2 +-
 net/sched/cls_tcindex.c                           |  2 +-
 net/sched/cls_u32.c                               |  2 +-
 net/sched/em_meta.c                               |  2 +-
 net/sched/ematch.c                                |  2 +-
 net/sched/sch_api.c                               | 10 +--
 net/sched/sch_atm.c                               |  2 +-
 net/sched/sch_cbq.c                               |  4 +-
 net/sched/sch_choke.c                             |  2 +-
 net/sched/sch_codel.c                             |  2 +-
 net/sched/sch_drr.c                               |  2 +-
 net/sched/sch_dsmark.c                            |  4 +-
 net/sched/sch_fq.c                                |  2 +-
 net/sched/sch_fq_codel.c                          |  3 +-
 net/sched/sch_gred.c                              |  4 +-
 net/sched/sch_hfsc.c                              |  2 +-
 net/sched/sch_hhf.c                               |  2 +-
 net/sched/sch_htb.c                               |  4 +-
 net/sched/sch_netem.c                             |  2 +-
 net/sched/sch_pie.c                               |  2 +-
 net/sched/sch_qfq.c                               |  3 +-
 net/sched/sch_red.c                               |  2 +-
 net/sched/sch_sfb.c                               |  2 +-
 net/sched/sch_tbf.c                               |  2 +-
 net/switchdev/switchdev.c                         |  2 +-
 net/tipc/bearer.c                                 | 14 ++--
 net/tipc/link.c                                   |  2 +-
 net/tipc/net.c                                    |  4 +-
 net/tipc/netlink.c                                |  3 +-
 net/tipc/netlink_compat.c                         | 32 +++++-----
 net/tipc/node.c                                   | 12 ++--
 net/tipc/socket.c                                 |  2 +-
 net/tipc/udp_media.c                              |  7 +-
 net/wireless/nl80211.c                            | 78 ++++++++++++-----------
 net/xfrm/xfrm_user.c                              |  6 +-
 129 files changed, 477 insertions(+), 391 deletions(-)

diff --git a/crypto/crypto_user.c b/crypto/crypto_user.c
index 4a44830741c1..fc79906c1fe7 100644
--- a/crypto/crypto_user.c
+++ b/crypto/crypto_user.c
@@ -523,7 +523,7 @@ static int crypto_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 	}
 
 	err = nlmsg_parse(nlh, crypto_msg_min[type], attrs, CRYPTOCFGA_MAX,
-			  crypto_policy);
+			  crypto_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/drivers/block/drbd/drbd_nla.c b/drivers/block/drbd/drbd_nla.c
index b2d4791498a6..6bf806df60dc 100644
--- a/drivers/block/drbd/drbd_nla.c
+++ b/drivers/block/drbd/drbd_nla.c
@@ -34,7 +34,7 @@ int drbd_nla_parse_nested(struct nlattr *tb[], int maxtype, struct nlattr *nla,
 
 	err = drbd_nla_check_mandatory(maxtype, nla);
 	if (!err)
-		err = nla_parse_nested(tb, maxtype, nla, policy);
+		err = nla_parse_nested(tb, maxtype, nla, policy, NULL);
 
 	return err;
 }
diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
index 0f58f46dbad7..329d08c884f6 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -88,7 +88,7 @@ static inline bool ib_nl_is_good_ip_resp(const struct nlmsghdr *nlh)
 		return false;
 
 	ret = nla_parse(tb, LS_NLA_TYPE_MAX - 1, nlmsg_data(nlh),
-			nlmsg_len(nlh), ib_nl_addr_policy);
+			nlmsg_len(nlh), ib_nl_addr_policy, NULL);
 	if (ret)
 		return false;
 
diff --git a/drivers/infiniband/core/iwpm_util.c b/drivers/infiniband/core/iwpm_util.c
index 3ef51a96bbf1..f13870e69ccd 100644
--- a/drivers/infiniband/core/iwpm_util.c
+++ b/drivers/infiniband/core/iwpm_util.c
@@ -472,12 +472,14 @@ int iwpm_parse_nlmsg(struct netlink_callback *cb, int policy_max,
 	int ret;
 	const char *err_str = "";
 
-	ret = nlmsg_validate(cb->nlh, nlh_len, policy_max-1, nlmsg_policy);
+	ret = nlmsg_validate(cb->nlh, nlh_len, policy_max - 1, nlmsg_policy,
+			     NULL);
 	if (ret) {
 		err_str = "Invalid attribute";
 		goto parse_nlmsg_error;
 	}
-	ret = nlmsg_parse(cb->nlh, nlh_len, nltb, policy_max-1, nlmsg_policy);
+	ret = nlmsg_parse(cb->nlh, nlh_len, nltb, policy_max - 1,
+			  nlmsg_policy, NULL);
 	if (ret) {
 		err_str = "Unable to parse the nlmsg";
 		goto parse_nlmsg_error;
diff --git a/drivers/infiniband/core/sa_query.c b/drivers/infiniband/core/sa_query.c
index 81b742ca1639..ceae153997d0 100644
--- a/drivers/infiniband/core/sa_query.c
+++ b/drivers/infiniband/core/sa_query.c
@@ -808,7 +808,7 @@ int ib_nl_handle_set_timeout(struct sk_buff *skb,
 		return -EPERM;
 
 	ret = nla_parse(tb, LS_NLA_TYPE_MAX - 1, nlmsg_data(nlh),
-			nlmsg_len(nlh), ib_nl_policy);
+			nlmsg_len(nlh), ib_nl_policy, NULL);
 	attr = (const struct nlattr *)tb[LS_NLA_TYPE_TIMEOUT];
 	if (ret || !attr)
 		goto settimeout_out;
@@ -860,7 +860,7 @@ static inline int ib_nl_is_good_resolve_resp(const struct nlmsghdr *nlh)
 		return 0;
 
 	ret = nla_parse(tb, LS_NLA_TYPE_MAX - 1, nlmsg_data(nlh),
-			nlmsg_len(nlh), ib_nl_policy);
+			nlmsg_len(nlh), ib_nl_policy, NULL);
 	if (ret)
 		return 0;
 
diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index ff0a5ed3ca80..9eb7a69be92a 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -1590,8 +1590,9 @@ static int parse_sa_config(struct nlattr **attrs, struct nlattr **tb_sa)
 	if (!attrs[MACSEC_ATTR_SA_CONFIG])
 		return -EINVAL;
 
-	if (nla_parse_nested(tb_sa, MACSEC_SA_ATTR_MAX, attrs[MACSEC_ATTR_SA_CONFIG],
-			     macsec_genl_sa_policy))
+	if (nla_parse_nested(tb_sa, MACSEC_SA_ATTR_MAX,
+			     attrs[MACSEC_ATTR_SA_CONFIG],
+			     macsec_genl_sa_policy, NULL))
 		return -EINVAL;
 
 	return 0;
@@ -1602,8 +1603,9 @@ static int parse_rxsc_config(struct nlattr **attrs, struct nlattr **tb_rxsc)
 	if (!attrs[MACSEC_ATTR_RXSC_CONFIG])
 		return -EINVAL;
 
-	if (nla_parse_nested(tb_rxsc, MACSEC_RXSC_ATTR_MAX, attrs[MACSEC_ATTR_RXSC_CONFIG],
-			     macsec_genl_rxsc_policy))
+	if (nla_parse_nested(tb_rxsc, MACSEC_RXSC_ATTR_MAX,
+			     attrs[MACSEC_ATTR_RXSC_CONFIG],
+			     macsec_genl_rxsc_policy, NULL))
 		return -EINVAL;
 
 	return 0;
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 1b52520715ae..86f227124ba1 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2471,7 +2471,7 @@ static int team_nl_cmd_options_set(struct sk_buff *skb, struct genl_info *info)
 			goto team_put;
 		}
 		err = nla_parse_nested(opt_attrs, TEAM_ATTR_OPTION_MAX,
-				       nl_option, team_nl_option_policy);
+				       nl_option, team_nl_option_policy, NULL);
 		if (err)
 			goto team_put;
 		if (!opt_attrs[TEAM_ATTR_OPTION_NAME] ||
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 317103680675..38f0f03a29c8 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -368,7 +368,8 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 		ifmp = nla_data(nla_peer);
 		err = rtnl_nla_parse_ifla(peer_tb,
 					  nla_data(nla_peer) + sizeof(struct ifinfomsg),
-					  nla_len(nla_peer) - sizeof(struct ifinfomsg));
+					  nla_len(nla_peer) - sizeof(struct ifinfomsg),
+					  NULL);
 		if (err < 0)
 			return err;
 
diff --git a/drivers/net/wireless/ath/ath10k/testmode.c b/drivers/net/wireless/ath/ath10k/testmode.c
index 8bb36c18a749..d8564624415c 100644
--- a/drivers/net/wireless/ath/ath10k/testmode.c
+++ b/drivers/net/wireless/ath/ath10k/testmode.c
@@ -420,8 +420,8 @@ int ath10k_tm_cmd(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
 	struct nlattr *tb[ATH10K_TM_ATTR_MAX + 1];
 	int ret;
 
-	ret = nla_parse(tb, ATH10K_TM_ATTR_MAX, data, len,
-			ath10k_tm_policy);
+	ret = nla_parse(tb, ATH10K_TM_ATTR_MAX, data, len, ath10k_tm_policy,
+			NULL);
 	if (ret)
 		return ret;
 
diff --git a/drivers/net/wireless/ath/ath6kl/testmode.c b/drivers/net/wireless/ath/ath6kl/testmode.c
index d67170ea1038..d8dcacda9add 100644
--- a/drivers/net/wireless/ath/ath6kl/testmode.c
+++ b/drivers/net/wireless/ath/ath6kl/testmode.c
@@ -74,8 +74,8 @@ int ath6kl_tm_cmd(struct wiphy *wiphy, struct wireless_dev *wdev,
 	int err, buf_len;
 	void *buf;
 
-	err = nla_parse(tb, ATH6KL_TM_ATTR_MAX, data, len,
-			ath6kl_tm_policy);
+	err = nla_parse(tb, ATH6KL_TM_ATTR_MAX, data, len, ath6kl_tm_policy,
+			NULL);
 	if (err)
 		return err;
 
diff --git a/drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c b/drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c
index 486dcceed17a..841bfdff8750 100644
--- a/drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c
+++ b/drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c
@@ -3711,7 +3711,8 @@ static int __iwl_mvm_mac_testmode_cmd(struct iwl_mvm *mvm,
 	int err;
 	u32 noa_duration;
 
-	err = nla_parse(tb, IWL_MVM_TM_ATTR_MAX, data, len, iwl_mvm_tm_policy);
+	err = nla_parse(tb, IWL_MVM_TM_ATTR_MAX, data, len, iwl_mvm_tm_policy,
+			NULL);
 	if (err)
 		return err;
 
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 50c219fb1a52..84a0e242ffdb 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -389,7 +389,7 @@ static int mac80211_hwsim_vendor_cmd_test(struct wiphy *wiphy,
 	u32 val;
 
 	err = nla_parse(tb, QCA_WLAN_VENDOR_ATTR_MAX, data, data_len,
-			hwsim_vendor_test_policy);
+			hwsim_vendor_test_policy, NULL);
 	if (err)
 		return err;
 	if (!tb[QCA_WLAN_VENDOR_ATTR_TEST])
@@ -1852,7 +1852,7 @@ static int mac80211_hwsim_testmode_cmd(struct ieee80211_hw *hw,
 	int err, ps;
 
 	err = nla_parse(tb, HWSIM_TM_ATTR_MAX, data, len,
-			hwsim_testmode_policy);
+			hwsim_testmode_policy, NULL);
 	if (err)
 		return err;
 
diff --git a/drivers/net/wireless/marvell/mwifiex/cfg80211.c b/drivers/net/wireless/marvell/mwifiex/cfg80211.c
index 1e3bd435a694..2d38f4a0aee3 100644
--- a/drivers/net/wireless/marvell/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/marvell/mwifiex/cfg80211.c
@@ -3997,8 +3997,8 @@ static int mwifiex_tm_cmd(struct wiphy *wiphy, struct wireless_dev *wdev,
 	if (!priv)
 		return -EINVAL;
 
-	err = nla_parse(tb, MWIFIEX_TM_ATTR_MAX, data, len,
-			mwifiex_tm_policy);
+	err = nla_parse(tb, MWIFIEX_TM_ATTR_MAX, data, len, mwifiex_tm_policy,
+			NULL);
 	if (err)
 		return err;
 
diff --git a/drivers/net/wireless/ti/wlcore/testmode.c b/drivers/net/wireless/ti/wlcore/testmode.c
index ddad58f614da..009ec07c4cec 100644
--- a/drivers/net/wireless/ti/wlcore/testmode.c
+++ b/drivers/net/wireless/ti/wlcore/testmode.c
@@ -366,7 +366,8 @@ int wl1271_tm_cmd(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
 	u32 nla_cmd;
 	int err;
 
-	err = nla_parse(tb, WL1271_TM_ATTR_MAX, data, len, wl1271_tm_policy);
+	err = nla_parse(tb, WL1271_TM_ATTR_MAX, data, len, wl1271_tm_policy,
+			NULL);
 	if (err)
 		return err;
 
diff --git a/drivers/net/wireless/ti/wlcore/vendor_cmd.c b/drivers/net/wireless/ti/wlcore/vendor_cmd.c
index fd4e9ba176c9..5c0bcb1fe1a1 100644
--- a/drivers/net/wireless/ti/wlcore/vendor_cmd.c
+++ b/drivers/net/wireless/ti/wlcore/vendor_cmd.c
@@ -41,7 +41,7 @@ wlcore_vendor_cmd_smart_config_start(struct wiphy *wiphy,
 		return -EINVAL;
 
 	ret = nla_parse(tb, MAX_WLCORE_VENDOR_ATTR, data, data_len,
-			wlcore_vendor_attr_policy);
+			wlcore_vendor_attr_policy, NULL);
 	if (ret)
 		return ret;
 
@@ -116,7 +116,7 @@ wlcore_vendor_cmd_smart_config_set_group_key(struct wiphy *wiphy,
 		return -EINVAL;
 
 	ret = nla_parse(tb, MAX_WLCORE_VENDOR_ATTR, data, data_len,
-			wlcore_vendor_attr_policy);
+			wlcore_vendor_attr_policy, NULL);
 	if (ret)
 		return ret;
 
diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index b81a4979e1db..3eeb5fd29883 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -182,14 +182,16 @@ genlmsg_nlhdr(void *user_hdr, const struct genl_family *family)
  * @tb: destination array with maxtype+1 elements
  * @maxtype: maximum attribute type to be expected
  * @policy: validation policy
- * */
+ * @extack: extended ACK report struct
+ */
 static inline int genlmsg_parse(const struct nlmsghdr *nlh,
 				const struct genl_family *family,
 				struct nlattr *tb[], int maxtype,
-				const struct nla_policy *policy)
+				const struct nla_policy *policy,
+				struct netlink_ext_ack *extack)
 {
 	return nlmsg_parse(nlh, family->hdrsize + GENL_HDRLEN, tb, maxtype,
-			   policy);
+			   policy, extack);
 }
 
 /**
diff --git a/include/net/netlink.h b/include/net/netlink.h
index a064ec3e2ee1..01709172b3d3 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -239,9 +239,11 @@ int nlmsg_notify(struct sock *sk, struct sk_buff *skb, u32 portid,
 		 unsigned int group, int report, gfp_t flags);
 
 int nla_validate(const struct nlattr *head, int len, int maxtype,
-		 const struct nla_policy *policy);
+		 const struct nla_policy *policy,
+		 struct netlink_ext_ack *extack);
 int nla_parse(struct nlattr **tb, int maxtype, const struct nlattr *head,
-	      int len, const struct nla_policy *policy);
+	      int len, const struct nla_policy *policy,
+	      struct netlink_ext_ack *extack);
 int nla_policy_len(const struct nla_policy *, int);
 struct nlattr *nla_find(const struct nlattr *head, int len, int attrtype);
 size_t nla_strlcpy(char *dst, const struct nlattr *nla, size_t dstsize);
@@ -375,18 +377,20 @@ nlmsg_next(const struct nlmsghdr *nlh, int *remaining)
  * @tb: destination array with maxtype+1 elements
  * @maxtype: maximum attribute type to be expected
  * @policy: validation policy
+ * @extack: extended ACK report struct
  *
  * See nla_parse()
  */
 static inline int nlmsg_parse(const struct nlmsghdr *nlh, int hdrlen,
 			      struct nlattr *tb[], int maxtype,
-			      const struct nla_policy *policy)
+			      const struct nla_policy *policy,
+			      struct netlink_ext_ack *extack)
 {
 	if (nlh->nlmsg_len < nlmsg_msg_size(hdrlen))
 		return -EINVAL;
 
 	return nla_parse(tb, maxtype, nlmsg_attrdata(nlh, hdrlen),
-			 nlmsg_attrlen(nlh, hdrlen), policy);
+			 nlmsg_attrlen(nlh, hdrlen), policy, extack);
 }
 
 /**
@@ -410,16 +414,19 @@ static inline struct nlattr *nlmsg_find_attr(const struct nlmsghdr *nlh,
  * @hdrlen: length of familiy specific header
  * @maxtype: maximum attribute type to be expected
  * @policy: validation policy
+ * @extack: extended ACK report struct
  */
 static inline int nlmsg_validate(const struct nlmsghdr *nlh,
 				 int hdrlen, int maxtype,
-				 const struct nla_policy *policy)
+				 const struct nla_policy *policy,
+				 struct netlink_ext_ack *extack)
 {
 	if (nlh->nlmsg_len < nlmsg_msg_size(hdrlen))
 		return -EINVAL;
 
 	return nla_validate(nlmsg_attrdata(nlh, hdrlen),
-			    nlmsg_attrlen(nlh, hdrlen), maxtype, policy);
+			    nlmsg_attrlen(nlh, hdrlen), maxtype, policy,
+			    extack);
 }
 
 /**
@@ -740,14 +747,17 @@ nla_find_nested(const struct nlattr *nla, int attrtype)
  * @maxtype: maximum attribute type to be expected
  * @nla: attribute containing the nested attributes
  * @policy: validation policy
+ * @extack: extended ACK report struct
  *
  * See nla_parse()
  */
 static inline int nla_parse_nested(struct nlattr *tb[], int maxtype,
 				   const struct nlattr *nla,
-				   const struct nla_policy *policy)
+				   const struct nla_policy *policy,
+				   struct netlink_ext_ack *extack)
 {
-	return nla_parse(tb, maxtype, nla_data(nla), nla_len(nla), policy);
+	return nla_parse(tb, maxtype, nla_data(nla), nla_len(nla), policy,
+			 extack);
 }
 
 /**
@@ -1253,6 +1263,7 @@ static inline void nla_nest_cancel(struct sk_buff *skb, struct nlattr *start)
  * @start: container attribute
  * @maxtype: maximum attribute type to be expected
  * @policy: validation policy
+ * @extack: extended ACK report struct
  *
  * Validates all attributes in the nested attribute stream against the
  * specified policy. Attributes with a type exceeding maxtype will be
@@ -1261,9 +1272,11 @@ static inline void nla_nest_cancel(struct sk_buff *skb, struct nlattr *start)
  * Returns 0 on success or a negative error code.
  */
 static inline int nla_validate_nested(const struct nlattr *start, int maxtype,
-				      const struct nla_policy *policy)
+				      const struct nla_policy *policy,
+				      struct netlink_ext_ack *extack)
 {
-	return nla_validate(nla_data(start), nla_len(start), maxtype, policy);
+	return nla_validate(nla_data(start), nla_len(start), maxtype, policy,
+			    extack);
 }
 
 /**
diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 106de5f7bf06..c07b941fce89 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -158,7 +158,8 @@ struct net_device *rtnl_create_link(struct net *net, const char *ifname,
 int rtnl_delete_link(struct net_device *dev);
 int rtnl_configure_link(struct net_device *dev, const struct ifinfomsg *ifm);
 
-int rtnl_nla_parse_ifla(struct nlattr **tb, const struct nlattr *head, int len);
+int rtnl_nla_parse_ifla(struct nlattr **tb, const struct nlattr *head, int len,
+			struct netlink_ext_ack *exterr);
 
 #define MODULE_ALIAS_RTNL_LINK(kind) MODULE_ALIAS("rtnl-link-" kind)
 
diff --git a/lib/nlattr.c b/lib/nlattr.c
index b42b8577fc23..a7e0b16078df 100644
--- a/lib/nlattr.c
+++ b/lib/nlattr.c
@@ -112,6 +112,7 @@ static int validate_nla(const struct nlattr *nla, int maxtype,
  * @len: length of attribute stream
  * @maxtype: maximum attribute type to be expected
  * @policy: validation policy
+ * @extack: extended ACK report struct
  *
  * Validates all attributes in the specified attribute stream against the
  * specified policy. Attributes with a type exceeding maxtype will be
@@ -120,20 +121,23 @@ static int validate_nla(const struct nlattr *nla, int maxtype,
  * Returns 0 on success or a negative error code.
  */
 int nla_validate(const struct nlattr *head, int len, int maxtype,
-		 const struct nla_policy *policy)
+		 const struct nla_policy *policy,
+		 struct netlink_ext_ack *extack)
 {
 	const struct nlattr *nla;
-	int rem, err;
+	int rem;
 
 	nla_for_each_attr(nla, head, len, rem) {
-		err = validate_nla(nla, maxtype, policy);
-		if (err < 0)
-			goto errout;
+		int err = validate_nla(nla, maxtype, policy);
+
+		if (err < 0) {
+			if (extack)
+				extack->bad_attr = nla;
+			return err;
+		}
 	}
 
-	err = 0;
-errout:
-	return err;
+	return 0;
 }
 EXPORT_SYMBOL(nla_validate);
 
@@ -180,7 +184,8 @@ EXPORT_SYMBOL(nla_policy_len);
  * Returns 0 on success or a negative error code.
  */
 int nla_parse(struct nlattr **tb, int maxtype, const struct nlattr *head,
-	      int len, const struct nla_policy *policy)
+	      int len, const struct nla_policy *policy,
+	      struct netlink_ext_ack *extack)
 {
 	const struct nlattr *nla;
 	int rem, err;
@@ -193,8 +198,11 @@ int nla_parse(struct nlattr **tb, int maxtype, const struct nlattr *head,
 		if (type > 0 && type <= maxtype) {
 			if (policy) {
 				err = validate_nla(nla, maxtype, policy);
-				if (err < 0)
+				if (err < 0) {
+					if (extack)
+						extack->bad_attr = nla;
 					goto errout;
+				}
 			}
 
 			tb[type] = (struct nlattr *)nla;
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index 1270207f3d7c..9c94aad153b3 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -35,7 +35,8 @@ static inline int vlan_validate_qos_map(struct nlattr *attr)
 {
 	if (!attr)
 		return 0;
-	return nla_validate_nested(attr, IFLA_VLAN_QOS_MAX, vlan_map_policy);
+	return nla_validate_nested(attr, IFLA_VLAN_QOS_MAX, vlan_map_policy,
+				   NULL);
 }
 
 static int vlan_validate(struct nlattr *tb[], struct nlattr *data[])
diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index 056e6ac49d8f..993626a7fc3b 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -464,7 +464,8 @@ static int br_mdb_parse(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct net_device *dev;
 	int err;
 
-	err = nlmsg_parse(nlh, sizeof(*bpm), tb, MDBA_SET_ENTRY_MAX, NULL);
+	err = nlmsg_parse(nlh, sizeof(*bpm), tb, MDBA_SET_ENTRY_MAX, NULL,
+			  NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index a8f6acd23e30..e6dea5cd6bd6 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -748,8 +748,8 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 
 	if (p && protinfo) {
 		if (protinfo->nla_type & NLA_F_NESTED) {
-			err = nla_parse_nested(tb, IFLA_BRPORT_MAX,
-					       protinfo, br_port_policy);
+			err = nla_parse_nested(tb, IFLA_BRPORT_MAX, protinfo,
+					       br_port_policy, NULL);
 			if (err)
 				return err;
 
diff --git a/net/bridge/br_netlink_tunnel.c b/net/bridge/br_netlink_tunnel.c
index c913491495ab..3712c7f0e00c 100644
--- a/net/bridge/br_netlink_tunnel.c
+++ b/net/bridge/br_netlink_tunnel.c
@@ -227,8 +227,8 @@ int br_parse_vlan_tunnel_info(struct nlattr *attr,
 
 	memset(tinfo, 0, sizeof(*tinfo));
 
-	err = nla_parse_nested(tb, IFLA_BRIDGE_VLAN_TUNNEL_MAX,
-			       attr, vlan_tunnel_policy);
+	err = nla_parse_nested(tb, IFLA_BRIDGE_VLAN_TUNNEL_MAX, attr,
+			       vlan_tunnel_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/can/gw.c b/net/can/gw.c
index 3c117a33e15f..3b84fb7d98aa 100644
--- a/net/can/gw.c
+++ b/net/can/gw.c
@@ -641,7 +641,7 @@ static int cgw_parse_attr(struct nlmsghdr *nlh, struct cf_mod *mod,
 	memset(mod, 0, sizeof(*mod));
 
 	err = nlmsg_parse(nlh, sizeof(struct rtcanmsg), tb, CGW_MAX,
-			  cgw_policy);
+			  cgw_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 816e3ccb0ec9..df03110ca3c8 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -386,7 +386,7 @@ int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr *nlh)
 		goto errout;
 	}
 
-	err = nlmsg_parse(nlh, sizeof(*frh), tb, FRA_MAX, ops->policy);
+	err = nlmsg_parse(nlh, sizeof(*frh), tb, FRA_MAX, ops->policy, NULL);
 	if (err < 0)
 		goto errout;
 
@@ -580,7 +580,7 @@ int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr *nlh)
 		goto errout;
 	}
 
-	err = nlmsg_parse(nlh, sizeof(*frh), tb, FRA_MAX, ops->policy);
+	err = nlmsg_parse(nlh, sizeof(*frh), tb, FRA_MAX, ops->policy, NULL);
 	if (err < 0)
 		goto errout;
 
diff --git a/net/core/lwt_bpf.c b/net/core/lwt_bpf.c
index 0cfe7b0216c3..b3bc0a31af9f 100644
--- a/net/core/lwt_bpf.c
+++ b/net/core/lwt_bpf.c
@@ -209,7 +209,8 @@ static int bpf_parse_prog(struct nlattr *attr, struct bpf_lwt_prog *prog,
 	int ret;
 	u32 fd;
 
-	ret = nla_parse_nested(tb, LWT_BPF_PROG_MAX, attr, bpf_prog_policy);
+	ret = nla_parse_nested(tb, LWT_BPF_PROG_MAX, attr, bpf_prog_policy,
+			       NULL);
 	if (ret < 0)
 		return ret;
 
@@ -249,7 +250,7 @@ static int bpf_build_state(struct nlattr *nla,
 	if (family != AF_INET && family != AF_INET6)
 		return -EAFNOSUPPORT;
 
-	ret = nla_parse_nested(tb, LWT_BPF_MAX, nla, bpf_nl_policy);
+	ret = nla_parse_nested(tb, LWT_BPF_MAX, nla, bpf_nl_policy, NULL);
 	if (ret < 0)
 		return ret;
 
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 8ae87c591c8e..31f37b264710 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1661,7 +1661,7 @@ static int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 	int err;
 
 	ASSERT_RTNL();
-	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL);
+	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL, NULL);
 	if (err < 0)
 		goto out;
 
@@ -1946,7 +1946,7 @@ static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh)
 	int err, tidx;
 
 	err = nlmsg_parse(nlh, sizeof(*ndtmsg), tb, NDTA_MAX,
-			  nl_neightbl_policy);
+			  nl_neightbl_policy, NULL);
 	if (err < 0)
 		goto errout;
 
@@ -1984,7 +1984,7 @@ static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh)
 		int i, ifindex = 0;
 
 		err = nla_parse_nested(tbp, NDTPA_MAX, tb[NDTA_PARMS],
-				       nl_ntbl_parm_policy);
+				       nl_ntbl_parm_policy, NULL);
 		if (err < 0)
 			goto errout_tbl_lock;
 
@@ -2275,7 +2275,7 @@ static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 	unsigned int flags = NLM_F_MULTI;
 	int err;
 
-	err = nlmsg_parse(nlh, sizeof(struct ndmsg), tb, NDA_MAX, NULL);
+	err = nlmsg_parse(nlh, sizeof(struct ndmsg), tb, NDA_MAX, NULL, NULL);
 	if (!err) {
 		if (tb[NDA_IFINDEX])
 			filter_idx = nla_get_u32(tb[NDA_IFINDEX]);
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 652468ff65b7..ec18cbc756d2 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -579,7 +579,7 @@ static int rtnl_net_newid(struct sk_buff *skb, struct nlmsghdr *nlh)
 	int nsid, err;
 
 	err = nlmsg_parse(nlh, sizeof(struct rtgenmsg), tb, NETNSA_MAX,
-			  rtnl_net_policy);
+			  rtnl_net_policy, NULL);
 	if (err < 0)
 		return err;
 	if (!tb[NETNSA_NSID])
@@ -653,7 +653,7 @@ static int rtnl_net_getid(struct sk_buff *skb, struct nlmsghdr *nlh)
 	int err, id;
 
 	err = nlmsg_parse(nlh, sizeof(struct rtgenmsg), tb, NETNSA_MAX,
-			  rtnl_net_policy);
+			  rtnl_net_policy, NULL);
 	if (err < 0)
 		return err;
 	if (tb[NETNSA_PID])
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 9788147241f4..14bb3c9ef6b7 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1581,7 +1581,8 @@ static const struct rtnl_link_ops *linkinfo_to_kind_ops(const struct nlattr *nla
 	const struct rtnl_link_ops *ops = NULL;
 	struct nlattr *linfo[IFLA_INFO_MAX + 1];
 
-	if (nla_parse_nested(linfo, IFLA_INFO_MAX, nla, ifla_info_policy) < 0)
+	if (nla_parse_nested(linfo, IFLA_INFO_MAX, nla,
+			     ifla_info_policy, NULL) < 0)
 		return NULL;
 
 	if (linfo[IFLA_INFO_KIND]) {
@@ -1658,8 +1659,8 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 	hdrlen = nlmsg_len(cb->nlh) < sizeof(struct ifinfomsg) ?
 		 sizeof(struct rtgenmsg) : sizeof(struct ifinfomsg);
 
-	if (nlmsg_parse(cb->nlh, hdrlen, tb, IFLA_MAX, ifla_policy) >= 0) {
-
+	if (nlmsg_parse(cb->nlh, hdrlen, tb, IFLA_MAX,
+			ifla_policy, NULL) >= 0) {
 		if (tb[IFLA_EXT_MASK])
 			ext_filter_mask = nla_get_u32(tb[IFLA_EXT_MASK]);
 
@@ -1706,9 +1707,10 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 	return skb->len;
 }
 
-int rtnl_nla_parse_ifla(struct nlattr **tb, const struct nlattr *head, int len)
+int rtnl_nla_parse_ifla(struct nlattr **tb, const struct nlattr *head, int len,
+			struct netlink_ext_ack *exterr)
 {
-	return nla_parse(tb, IFLA_MAX, head, len, ifla_policy);
+	return nla_parse(tb, IFLA_MAX, head, len, ifla_policy, exterr);
 }
 EXPORT_SYMBOL(rtnl_nla_parse_ifla);
 
@@ -2144,7 +2146,7 @@ static int do_setlink(const struct sk_buff *skb,
 				goto errout;
 			}
 			err = nla_parse_nested(vfinfo, IFLA_VF_MAX, attr,
-					       ifla_vf_policy);
+					       ifla_vf_policy, NULL);
 			if (err < 0)
 				goto errout;
 			err = do_setvfinfo(dev, vfinfo);
@@ -2172,7 +2174,7 @@ static int do_setlink(const struct sk_buff *skb,
 				goto errout;
 			}
 			err = nla_parse_nested(port, IFLA_PORT_MAX, attr,
-					       ifla_port_policy);
+					       ifla_port_policy, NULL);
 			if (err < 0)
 				goto errout;
 			if (!port[IFLA_PORT_VF]) {
@@ -2192,7 +2194,8 @@ static int do_setlink(const struct sk_buff *skb,
 		struct nlattr *port[IFLA_PORT_MAX+1];
 
 		err = nla_parse_nested(port, IFLA_PORT_MAX,
-			tb[IFLA_PORT_SELF], ifla_port_policy);
+				       tb[IFLA_PORT_SELF], ifla_port_policy,
+				       NULL);
 		if (err < 0)
 			goto errout;
 
@@ -2236,7 +2239,7 @@ static int do_setlink(const struct sk_buff *skb,
 		u32 xdp_flags = 0;
 
 		err = nla_parse_nested(xdp, IFLA_XDP_MAX, tb[IFLA_XDP],
-				       ifla_xdp_policy);
+				       ifla_xdp_policy, NULL);
 		if (err < 0)
 			goto errout;
 
@@ -2285,7 +2288,7 @@ static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct nlattr *tb[IFLA_MAX+1];
 	char ifname[IFNAMSIZ];
 
-	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy, NULL);
 	if (err < 0)
 		goto errout;
 
@@ -2378,7 +2381,7 @@ static int rtnl_dellink(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct nlattr *tb[IFLA_MAX+1];
 	int err;
 
-	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy, NULL);
 	if (err < 0)
 		return err;
 
@@ -2507,7 +2510,7 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh)
 #ifdef CONFIG_MODULES
 replay:
 #endif
-	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy, NULL);
 	if (err < 0)
 		return err;
 
@@ -2538,7 +2541,8 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	if (tb[IFLA_LINKINFO]) {
 		err = nla_parse_nested(linkinfo, IFLA_INFO_MAX,
-				       tb[IFLA_LINKINFO], ifla_info_policy);
+				       tb[IFLA_LINKINFO], ifla_info_policy,
+				       NULL);
 		if (err < 0)
 			return err;
 	} else
@@ -2563,7 +2567,7 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh)
 			if (ops->maxtype && linkinfo[IFLA_INFO_DATA]) {
 				err = nla_parse_nested(attr, ops->maxtype,
 						       linkinfo[IFLA_INFO_DATA],
-						       ops->policy);
+						       ops->policy, NULL);
 				if (err < 0)
 					return err;
 				data = attr;
@@ -2581,7 +2585,8 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh)
 				err = nla_parse_nested(slave_attr,
 						       m_ops->slave_maxtype,
 						       linkinfo[IFLA_INFO_SLAVE_DATA],
-						       m_ops->slave_policy);
+						       m_ops->slave_policy,
+						       NULL);
 				if (err < 0)
 					return err;
 				slave_data = slave_attr;
@@ -2750,7 +2755,7 @@ static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh)
 	int err;
 	u32 ext_filter_mask = 0;
 
-	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy, NULL);
 	if (err < 0)
 		return err;
 
@@ -2800,7 +2805,7 @@ static u16 rtnl_calcit(struct sk_buff *skb, struct nlmsghdr *nlh)
 	hdrlen = nlmsg_len(nlh) < sizeof(struct ifinfomsg) ?
 		 sizeof(struct rtgenmsg) : sizeof(struct ifinfomsg);
 
-	if (nlmsg_parse(nlh, hdrlen, tb, IFLA_MAX, ifla_policy) >= 0) {
+	if (nlmsg_parse(nlh, hdrlen, tb, IFLA_MAX, ifla_policy, NULL) >= 0) {
 		if (tb[IFLA_EXT_MASK])
 			ext_filter_mask = nla_get_u32(tb[IFLA_EXT_MASK]);
 	}
@@ -3039,7 +3044,7 @@ static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 	u16 vid;
 	int err;
 
-	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL);
+	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL, NULL);
 	if (err < 0)
 		return err;
 
@@ -3142,7 +3147,7 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (!netlink_capable(skb, CAP_NET_ADMIN))
 		return -EPERM;
 
-	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL);
+	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL, NULL);
 	if (err < 0)
 		return err;
 
@@ -3277,8 +3282,8 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	int err = 0;
 	int fidx = 0;
 
-	if (nlmsg_parse(cb->nlh, sizeof(struct ifinfomsg), tb, IFLA_MAX,
-			ifla_policy) == 0) {
+	if (nlmsg_parse(cb->nlh, sizeof(struct ifinfomsg), tb,
+			IFLA_MAX, ifla_policy, NULL) == 0) {
 		if (tb[IFLA_MASTER])
 			br_idx = nla_get_u32(tb[IFLA_MASTER]);
 	}
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 3202d75329b5..3f5a5f710576 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -245,8 +245,7 @@ static int dcbnl_getpfccfg(struct net_device *netdev, struct nlmsghdr *nlh,
 		return -EOPNOTSUPP;
 
 	ret = nla_parse_nested(data, DCB_PFC_UP_ATTR_MAX,
-	                       tb[DCB_ATTR_PFC_CFG],
-	                       dcbnl_pfc_up_nest);
+			       tb[DCB_ATTR_PFC_CFG], dcbnl_pfc_up_nest, NULL);
 	if (ret)
 		return ret;
 
@@ -304,7 +303,7 @@ static int dcbnl_getcap(struct net_device *netdev, struct nlmsghdr *nlh,
 		return -EOPNOTSUPP;
 
 	ret = nla_parse_nested(data, DCB_CAP_ATTR_MAX, tb[DCB_ATTR_CAP],
-	                       dcbnl_cap_nest);
+			       dcbnl_cap_nest, NULL);
 	if (ret)
 		return ret;
 
@@ -348,7 +347,7 @@ static int dcbnl_getnumtcs(struct net_device *netdev, struct nlmsghdr *nlh,
 		return -EOPNOTSUPP;
 
 	ret = nla_parse_nested(data, DCB_NUMTCS_ATTR_MAX, tb[DCB_ATTR_NUMTCS],
-	                       dcbnl_numtcs_nest);
+			       dcbnl_numtcs_nest, NULL);
 	if (ret)
 		return ret;
 
@@ -393,7 +392,7 @@ static int dcbnl_setnumtcs(struct net_device *netdev, struct nlmsghdr *nlh,
 		return -EOPNOTSUPP;
 
 	ret = nla_parse_nested(data, DCB_NUMTCS_ATTR_MAX, tb[DCB_ATTR_NUMTCS],
-	                       dcbnl_numtcs_nest);
+			       dcbnl_numtcs_nest, NULL);
 	if (ret)
 		return ret;
 
@@ -452,7 +451,7 @@ static int dcbnl_getapp(struct net_device *netdev, struct nlmsghdr *nlh,
 		return -EINVAL;
 
 	ret = nla_parse_nested(app_tb, DCB_APP_ATTR_MAX, tb[DCB_ATTR_APP],
-	                       dcbnl_app_nest);
+			       dcbnl_app_nest, NULL);
 	if (ret)
 		return ret;
 
@@ -520,7 +519,7 @@ static int dcbnl_setapp(struct net_device *netdev, struct nlmsghdr *nlh,
 		return -EINVAL;
 
 	ret = nla_parse_nested(app_tb, DCB_APP_ATTR_MAX, tb[DCB_ATTR_APP],
-	                       dcbnl_app_nest);
+			       dcbnl_app_nest, NULL);
 	if (ret)
 		return ret;
 
@@ -577,8 +576,8 @@ static int __dcbnl_pg_getcfg(struct net_device *netdev, struct nlmsghdr *nlh,
 	    !netdev->dcbnl_ops->getpgbwgcfgrx)
 		return -EOPNOTSUPP;
 
-	ret = nla_parse_nested(pg_tb, DCB_PG_ATTR_MAX,
-	                       tb[DCB_ATTR_PG_CFG], dcbnl_pg_nest);
+	ret = nla_parse_nested(pg_tb, DCB_PG_ATTR_MAX, tb[DCB_ATTR_PG_CFG],
+			       dcbnl_pg_nest, NULL);
 	if (ret)
 		return ret;
 
@@ -597,8 +596,8 @@ static int __dcbnl_pg_getcfg(struct net_device *netdev, struct nlmsghdr *nlh,
 			data = pg_tb[DCB_PG_ATTR_TC_ALL];
 		else
 			data = pg_tb[i];
-		ret = nla_parse_nested(param_tb, DCB_TC_ATTR_PARAM_MAX,
-				       data, dcbnl_tc_param_nest);
+		ret = nla_parse_nested(param_tb, DCB_TC_ATTR_PARAM_MAX, data,
+				       dcbnl_tc_param_nest, NULL);
 		if (ret)
 			goto err_pg;
 
@@ -735,8 +734,7 @@ static int dcbnl_setpfccfg(struct net_device *netdev, struct nlmsghdr *nlh,
 		return -EOPNOTSUPP;
 
 	ret = nla_parse_nested(data, DCB_PFC_UP_ATTR_MAX,
-	                       tb[DCB_ATTR_PFC_CFG],
-	                       dcbnl_pfc_up_nest);
+			       tb[DCB_ATTR_PFC_CFG], dcbnl_pfc_up_nest, NULL);
 	if (ret)
 		return ret;
 
@@ -791,8 +789,8 @@ static int __dcbnl_pg_setcfg(struct net_device *netdev, struct nlmsghdr *nlh,
 	    !netdev->dcbnl_ops->setpgbwgcfgrx)
 		return -EOPNOTSUPP;
 
-	ret = nla_parse_nested(pg_tb, DCB_PG_ATTR_MAX,
-	                       tb[DCB_ATTR_PG_CFG], dcbnl_pg_nest);
+	ret = nla_parse_nested(pg_tb, DCB_PG_ATTR_MAX, tb[DCB_ATTR_PG_CFG],
+			       dcbnl_pg_nest, NULL);
 	if (ret)
 		return ret;
 
@@ -801,7 +799,7 @@ static int __dcbnl_pg_setcfg(struct net_device *netdev, struct nlmsghdr *nlh,
 			continue;
 
 		ret = nla_parse_nested(param_tb, DCB_TC_ATTR_PARAM_MAX,
-		                       pg_tb[i], dcbnl_tc_param_nest);
+				       pg_tb[i], dcbnl_tc_param_nest, NULL);
 		if (ret)
 			return ret;
 
@@ -889,8 +887,8 @@ static int dcbnl_bcn_getcfg(struct net_device *netdev, struct nlmsghdr *nlh,
 	    !netdev->dcbnl_ops->getbcncfg)
 		return -EOPNOTSUPP;
 
-	ret = nla_parse_nested(bcn_tb, DCB_BCN_ATTR_MAX,
-	                       tb[DCB_ATTR_BCN], dcbnl_bcn_nest);
+	ret = nla_parse_nested(bcn_tb, DCB_BCN_ATTR_MAX, tb[DCB_ATTR_BCN],
+			       dcbnl_bcn_nest, NULL);
 	if (ret)
 		return ret;
 
@@ -948,9 +946,8 @@ static int dcbnl_bcn_setcfg(struct net_device *netdev, struct nlmsghdr *nlh,
 	    !netdev->dcbnl_ops->setbcnrp)
 		return -EOPNOTSUPP;
 
-	ret = nla_parse_nested(data, DCB_BCN_ATTR_MAX,
-	                       tb[DCB_ATTR_BCN],
-	                       dcbnl_pfc_up_nest);
+	ret = nla_parse_nested(data, DCB_BCN_ATTR_MAX, tb[DCB_ATTR_BCN],
+			       dcbnl_pfc_up_nest, NULL);
 	if (ret)
 		return ret;
 
@@ -1424,8 +1421,8 @@ static int dcbnl_ieee_set(struct net_device *netdev, struct nlmsghdr *nlh,
 	if (!tb[DCB_ATTR_IEEE])
 		return -EINVAL;
 
-	err = nla_parse_nested(ieee, DCB_ATTR_IEEE_MAX,
-			       tb[DCB_ATTR_IEEE], dcbnl_ieee_policy);
+	err = nla_parse_nested(ieee, DCB_ATTR_IEEE_MAX, tb[DCB_ATTR_IEEE],
+			       dcbnl_ieee_policy, NULL);
 	if (err)
 		return err;
 
@@ -1508,8 +1505,8 @@ static int dcbnl_ieee_del(struct net_device *netdev, struct nlmsghdr *nlh,
 	if (!tb[DCB_ATTR_IEEE])
 		return -EINVAL;
 
-	err = nla_parse_nested(ieee, DCB_ATTR_IEEE_MAX,
-			       tb[DCB_ATTR_IEEE], dcbnl_ieee_policy);
+	err = nla_parse_nested(ieee, DCB_ATTR_IEEE_MAX, tb[DCB_ATTR_IEEE],
+			       dcbnl_ieee_policy, NULL);
 	if (err)
 		return err;
 
@@ -1581,8 +1578,8 @@ static int dcbnl_getfeatcfg(struct net_device *netdev, struct nlmsghdr *nlh,
 	if (!tb[DCB_ATTR_FEATCFG])
 		return -EINVAL;
 
-	ret = nla_parse_nested(data, DCB_FEATCFG_ATTR_MAX, tb[DCB_ATTR_FEATCFG],
-			       dcbnl_featcfg_nest);
+	ret = nla_parse_nested(data, DCB_FEATCFG_ATTR_MAX,
+			       tb[DCB_ATTR_FEATCFG], dcbnl_featcfg_nest, NULL);
 	if (ret)
 		return ret;
 
@@ -1625,8 +1622,8 @@ static int dcbnl_setfeatcfg(struct net_device *netdev, struct nlmsghdr *nlh,
 	if (!tb[DCB_ATTR_FEATCFG])
 		return -EINVAL;
 
-	ret = nla_parse_nested(data, DCB_FEATCFG_ATTR_MAX, tb[DCB_ATTR_FEATCFG],
-			       dcbnl_featcfg_nest);
+	ret = nla_parse_nested(data, DCB_FEATCFG_ATTR_MAX,
+			       tb[DCB_ATTR_FEATCFG], dcbnl_featcfg_nest, NULL);
 
 	if (ret)
 		goto err;
@@ -1715,7 +1712,7 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return -EPERM;
 
 	ret = nlmsg_parse(nlh, sizeof(*dcb), tb, DCB_ATTR_MAX,
-			  dcbnl_rtnl_policy);
+			  dcbnl_rtnl_policy, NULL);
 	if (ret < 0)
 		return ret;
 
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 8fdd9f492b0e..e65f1be44e8e 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -581,7 +581,7 @@ static int dn_nl_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (!net_eq(net, &init_net))
 		goto errout;
 
-	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, dn_ifa_policy);
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, dn_ifa_policy, NULL);
 	if (err < 0)
 		goto errout;
 
@@ -625,7 +625,7 @@ static int dn_nl_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (!net_eq(net, &init_net))
 		return -EINVAL;
 
-	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, dn_ifa_policy);
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, dn_ifa_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
index 7af0ba6157a1..34663bf8aa6d 100644
--- a/net/decnet/dn_fib.c
+++ b/net/decnet/dn_fib.c
@@ -515,7 +515,8 @@ static int dn_fib_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (!net_eq(net, &init_net))
 		return -EINVAL;
 
-	err = nlmsg_parse(nlh, sizeof(*r), attrs, RTA_MAX, rtm_dn_policy);
+	err = nlmsg_parse(nlh, sizeof(*r), attrs, RTA_MAX, rtm_dn_policy,
+			  NULL);
 	if (err < 0)
 		return err;
 
@@ -540,7 +541,8 @@ static int dn_fib_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (!net_eq(net, &init_net))
 		return -EINVAL;
 
-	err = nlmsg_parse(nlh, sizeof(*r), attrs, RTA_MAX, rtm_dn_policy);
+	err = nlmsg_parse(nlh, sizeof(*r), attrs, RTA_MAX, rtm_dn_policy,
+			  NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index b1dc096d22f8..2d7097bbc666 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1654,7 +1654,7 @@ static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	if (!net_eq(net, &init_net))
 		return -EINVAL;
 
-	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_dn_policy);
+	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_dn_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/ieee802154/nl802154.c b/net/ieee802154/nl802154.c
index fc60cd061f39..d6b1a1b21909 100644
--- a/net/ieee802154/nl802154.c
+++ b/net/ieee802154/nl802154.c
@@ -249,8 +249,7 @@ nl802154_prepare_wpan_dev_dump(struct sk_buff *skb,
 	if (!cb->args[0]) {
 		err = nlmsg_parse(cb->nlh, GENL_HDRLEN + nl802154_fam.hdrsize,
 				  genl_family_attrbuf(&nl802154_fam),
-				  nl802154_fam.maxattr,
-				  nl802154_policy);
+				  nl802154_fam.maxattr, nl802154_policy, NULL);
 		if (err)
 			goto out_unlock;
 
@@ -562,8 +561,8 @@ static int nl802154_dump_wpan_phy_parse(struct sk_buff *skb,
 					struct nl802154_dump_wpan_phy_state *state)
 {
 	struct nlattr **tb = genl_family_attrbuf(&nl802154_fam);
-	int ret = nlmsg_parse(cb->nlh, GENL_HDRLEN + nl802154_fam.hdrsize,
-			      tb, nl802154_fam.maxattr, nl802154_policy);
+	int ret = nlmsg_parse(cb->nlh, GENL_HDRLEN + nl802154_fam.hdrsize, tb,
+			      nl802154_fam.maxattr, nl802154_policy, NULL);
 
 	/* TODO check if we can handle error here,
 	 * we have no backward compatibility
@@ -1308,7 +1307,7 @@ ieee802154_llsec_parse_dev_addr(struct nlattr *nla,
 	struct nlattr *attrs[NL802154_DEV_ADDR_ATTR_MAX + 1];
 
 	if (!nla || nla_parse_nested(attrs, NL802154_DEV_ADDR_ATTR_MAX, nla,
-				     nl802154_dev_addr_policy))
+				     nl802154_dev_addr_policy, NULL))
 		return -EINVAL;
 
 	if (!attrs[NL802154_DEV_ADDR_ATTR_PAN_ID] ||
@@ -1348,7 +1347,7 @@ ieee802154_llsec_parse_key_id(struct nlattr *nla,
 	struct nlattr *attrs[NL802154_KEY_ID_ATTR_MAX + 1];
 
 	if (!nla || nla_parse_nested(attrs, NL802154_KEY_ID_ATTR_MAX, nla,
-				     nl802154_key_id_policy))
+				     nl802154_key_id_policy, NULL))
 		return -EINVAL;
 
 	if (!attrs[NL802154_KEY_ID_ATTR_MODE])
@@ -1565,7 +1564,7 @@ static int nl802154_add_llsec_key(struct sk_buff *skb, struct genl_info *info)
 
 	if (nla_parse_nested(attrs, NL802154_KEY_ATTR_MAX,
 			     info->attrs[NL802154_ATTR_SEC_KEY],
-			     nl802154_key_policy))
+			     nl802154_key_policy, NULL))
 		return -EINVAL;
 
 	if (!attrs[NL802154_KEY_ATTR_USAGE_FRAMES] ||
@@ -1615,7 +1614,7 @@ static int nl802154_del_llsec_key(struct sk_buff *skb, struct genl_info *info)
 
 	if (nla_parse_nested(attrs, NL802154_KEY_ATTR_MAX,
 			     info->attrs[NL802154_ATTR_SEC_KEY],
-			     nl802154_key_policy))
+			     nl802154_key_policy, NULL))
 		return -EINVAL;
 
 	if (ieee802154_llsec_parse_key_id(attrs[NL802154_KEY_ATTR_ID], &id) < 0)
@@ -1729,8 +1728,8 @@ ieee802154_llsec_parse_device(struct nlattr *nla,
 {
 	struct nlattr *attrs[NL802154_DEV_ATTR_MAX + 1];
 
-	if (!nla || nla_parse_nested(attrs, NL802154_DEV_ATTR_MAX, nla,
-				     nl802154_dev_policy))
+	if (!nla || nla_parse_nested(attrs, NL802154_DEV_ATTR_MAX,
+				     nla, nl802154_dev_policy, NULL))
 		return -EINVAL;
 
 	memset(dev, 0, sizeof(*dev));
@@ -1783,7 +1782,7 @@ static int nl802154_del_llsec_dev(struct sk_buff *skb, struct genl_info *info)
 
 	if (nla_parse_nested(attrs, NL802154_DEV_ATTR_MAX,
 			     info->attrs[NL802154_ATTR_SEC_DEVICE],
-			     nl802154_dev_policy))
+			     nl802154_dev_policy, NULL))
 		return -EINVAL;
 
 	if (!attrs[NL802154_DEV_ATTR_EXTENDED_ADDR])
@@ -1911,7 +1910,7 @@ static int nl802154_add_llsec_devkey(struct sk_buff *skb, struct genl_info *info
 	if (!info->attrs[NL802154_ATTR_SEC_DEVKEY] ||
 	    nla_parse_nested(attrs, NL802154_DEVKEY_ATTR_MAX,
 			     info->attrs[NL802154_ATTR_SEC_DEVKEY],
-			     nl802154_devkey_policy) < 0)
+			     nl802154_devkey_policy, NULL) < 0)
 		return -EINVAL;
 
 	if (!attrs[NL802154_DEVKEY_ATTR_FRAME_COUNTER] ||
@@ -1943,7 +1942,7 @@ static int nl802154_del_llsec_devkey(struct sk_buff *skb, struct genl_info *info
 
 	if (nla_parse_nested(attrs, NL802154_DEVKEY_ATTR_MAX,
 			     info->attrs[NL802154_ATTR_SEC_DEVKEY],
-			     nl802154_devkey_policy))
+			     nl802154_devkey_policy, NULL))
 		return -EINVAL;
 
 	if (!attrs[NL802154_DEVKEY_ATTR_EXTENDED_ADDR])
@@ -2063,8 +2062,8 @@ llsec_parse_seclevel(struct nlattr *nla, struct ieee802154_llsec_seclevel *sl)
 {
 	struct nlattr *attrs[NL802154_SECLEVEL_ATTR_MAX + 1];
 
-	if (!nla || nla_parse_nested(attrs, NL802154_SECLEVEL_ATTR_MAX, nla,
-				     nl802154_seclevel_policy))
+	if (!nla || nla_parse_nested(attrs, NL802154_SECLEVEL_ATTR_MAX,
+				     nla, nl802154_seclevel_policy, NULL))
 		return -EINVAL;
 
 	memset(sl, 0, sizeof(*sl));
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 6d3602ec640c..f33f53791f50 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -582,7 +582,8 @@ static int inet_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	ASSERT_RTNL();
 
-	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv4_policy);
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv4_policy,
+			  NULL);
 	if (err < 0)
 		goto errout;
 
@@ -752,7 +753,8 @@ static struct in_ifaddr *rtm_to_ifaddr(struct net *net, struct nlmsghdr *nlh,
 	struct in_device *in_dev;
 	int err;
 
-	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv4_policy);
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv4_policy,
+			  NULL);
 	if (err < 0)
 		goto errout;
 
@@ -1717,7 +1719,7 @@ static int inet_validate_link_af(const struct net_device *dev,
 	if (dev && !__in_dev_get_rtnl(dev))
 		return -EAFNOSUPPORT;
 
-	err = nla_parse_nested(tb, IFLA_INET_MAX, nla, inet_af_policy);
+	err = nla_parse_nested(tb, IFLA_INET_MAX, nla, inet_af_policy, NULL);
 	if (err < 0)
 		return err;
 
@@ -1745,7 +1747,7 @@ static int inet_set_link_af(struct net_device *dev, const struct nlattr *nla)
 	if (!in_dev)
 		return -EAFNOSUPPORT;
 
-	if (nla_parse_nested(tb, IFLA_INET_MAX, nla, NULL) < 0)
+	if (nla_parse_nested(tb, IFLA_INET_MAX, nla, NULL, NULL) < 0)
 		BUG();
 
 	if (tb[IFLA_INET_CONF]) {
@@ -1882,7 +1884,7 @@ static int inet_netconf_get_devconf(struct sk_buff *in_skb,
 	int err;
 
 	err = nlmsg_parse(nlh, sizeof(*ncm), tb, NETCONFA_MAX,
-			  devconf_ipv4_policy);
+			  devconf_ipv4_policy, NULL);
 	if (err < 0)
 		goto errout;
 
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 8f2133ffc2ff..434dd2538716 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -632,7 +632,8 @@ static int rtm_to_fib_config(struct net *net, struct sk_buff *skb,
 	int err, remaining;
 	struct rtmsg *rtm;
 
-	err = nlmsg_validate(nlh, sizeof(*rtm), RTA_MAX, rtm_ipv4_policy);
+	err = nlmsg_validate(nlh, sizeof(*rtm), RTA_MAX, rtm_ipv4_policy,
+			     NULL);
 	if (err < 0)
 		goto errout;
 
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index a31f47ccaad9..baf196eaf1d8 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -235,7 +235,7 @@ static int ip_tun_build_state(struct nlattr *attr,
 	struct nlattr *tb[LWTUNNEL_IP_MAX + 1];
 	int err;
 
-	err = nla_parse_nested(tb, LWTUNNEL_IP_MAX, attr, ip_tun_policy);
+	err = nla_parse_nested(tb, LWTUNNEL_IP_MAX, attr, ip_tun_policy, NULL);
 	if (err < 0)
 		return err;
 
@@ -332,7 +332,8 @@ static int ip6_tun_build_state(struct nlattr *attr,
 	struct nlattr *tb[LWTUNNEL_IP6_MAX + 1];
 	int err;
 
-	err = nla_parse_nested(tb, LWTUNNEL_IP6_MAX, attr, ip6_tun_policy);
+	err = nla_parse_nested(tb, LWTUNNEL_IP6_MAX, attr, ip6_tun_policy,
+			       NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 5bca64fc71b7..d7be21f2174a 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2439,7 +2439,8 @@ static int rtm_to_ipmr_mfcc(struct net *net, struct nlmsghdr *nlh,
 	struct rtmsg *rtm;
 	int ret, rem;
 
-	ret = nlmsg_validate(nlh, sizeof(*rtm), RTA_MAX, rtm_ipmr_policy);
+	ret = nlmsg_validate(nlh, sizeof(*rtm), RTA_MAX, rtm_ipmr_policy,
+			     NULL);
 	if (ret < 0)
 		goto out;
 	rtm = nlmsg_data(nlh);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 5e1e60546fce..a8351ea18db3 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2649,7 +2649,8 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	u32 table_id = RT_TABLE_MAIN;
 	kuid_t uid;
 
-	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_ipv4_policy);
+	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_ipv4_policy,
+			  NULL);
 	if (err < 0)
 		goto errout;
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 67ec87ea5fb6..b330c2abcb24 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -624,7 +624,7 @@ static int inet6_netconf_get_devconf(struct sk_buff *in_skb,
 	int err;
 
 	err = nlmsg_parse(nlh, sizeof(*ncm), tb, NETCONFA_MAX,
-			  devconf_ipv6_policy);
+			  devconf_ipv6_policy, NULL);
 	if (err < 0)
 		goto errout;
 
@@ -4408,7 +4408,8 @@ inet6_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
 	u32 ifa_flags;
 	int err;
 
-	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv6_policy);
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv6_policy,
+			  NULL);
 	if (err < 0)
 		return err;
 
@@ -4520,7 +4521,8 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 	u32 ifa_flags;
 	int err;
 
-	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv6_policy);
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv6_policy,
+			  NULL);
 	if (err < 0)
 		return err;
 
@@ -4881,7 +4883,8 @@ static int inet6_rtm_getaddr(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	struct sk_buff *skb;
 	int err;
 
-	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv6_policy);
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv6_policy,
+			  NULL);
 	if (err < 0)
 		goto errout;
 
@@ -5251,7 +5254,8 @@ static int inet6_validate_link_af(const struct net_device *dev,
 	if (dev && !__in6_dev_get(dev))
 		return -EAFNOSUPPORT;
 
-	return nla_parse_nested(tb, IFLA_INET6_MAX, nla, inet6_af_policy);
+	return nla_parse_nested(tb, IFLA_INET6_MAX, nla, inet6_af_policy,
+				NULL);
 }
 
 static int check_addr_gen_mode(int mode)
@@ -5283,7 +5287,7 @@ static int inet6_set_link_af(struct net_device *dev, const struct nlattr *nla)
 	if (!idev)
 		return -EAFNOSUPPORT;
 
-	if (nla_parse_nested(tb, IFLA_INET6_MAX, nla, NULL) < 0)
+	if (nla_parse_nested(tb, IFLA_INET6_MAX, nla, NULL, NULL) < 0)
 		BUG();
 
 	if (tb[IFLA_INET6_TOKEN]) {
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index a8f6986dcbe5..6cb4ed91722a 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -413,7 +413,7 @@ static int ip6addrlbl_newdel(struct sk_buff *skb, struct nlmsghdr *nlh)
 	u32 label;
 	int err = 0;
 
-	err = nlmsg_parse(nlh, sizeof(*ifal), tb, IFAL_MAX, ifal_policy);
+	err = nlmsg_parse(nlh, sizeof(*ifal), tb, IFAL_MAX, ifal_policy, NULL);
 	if (err < 0)
 		return err;
 
@@ -532,7 +532,7 @@ static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	struct ip6addrlbl_entry *p;
 	struct sk_buff *skb;
 
-	err = nlmsg_parse(nlh, sizeof(*ifal), tb, IFAL_MAX, ifal_policy);
+	err = nlmsg_parse(nlh, sizeof(*ifal), tb, IFAL_MAX, ifal_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/ipv6/ila/ila_lwt.c b/net/ipv6/ila/ila_lwt.c
index ce1aae4a7fc8..b3df03e3faa0 100644
--- a/net/ipv6/ila/ila_lwt.c
+++ b/net/ipv6/ila/ila_lwt.c
@@ -146,8 +146,7 @@ static int ila_build_state(struct nlattr *nla,
 		return -EINVAL;
 	}
 
-	ret = nla_parse_nested(tb, ILA_ATTR_MAX, nla,
-			       ila_nl_policy);
+	ret = nla_parse_nested(tb, ILA_ATTR_MAX, nla, ila_nl_policy, NULL);
 	if (ret < 0)
 		return ret;
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 9db1418993f2..ccde23eba702 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2906,7 +2906,8 @@ static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
 	unsigned int pref;
 	int err;
 
-	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_ipv6_policy);
+	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_ipv6_policy,
+			  NULL);
 	if (err < 0)
 		goto errout;
 
@@ -3574,7 +3575,8 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	struct flowi6 fl6;
 	int err, iif = 0, oif = 0;
 
-	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_ipv6_policy);
+	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_ipv6_policy,
+			  NULL);
 	if (err < 0)
 		goto errout;
 
diff --git a/net/ipv6/seg6_iptunnel.c b/net/ipv6/seg6_iptunnel.c
index a644aaecdfd3..7436a4a62f3e 100644
--- a/net/ipv6/seg6_iptunnel.c
+++ b/net/ipv6/seg6_iptunnel.c
@@ -328,7 +328,7 @@ static int seg6_build_state(struct nlattr *nla,
 	int err;
 
 	err = nla_parse_nested(tb, SEG6_IPTUNNEL_MAX, nla,
-			       seg6_iptunnel_policy);
+			       seg6_iptunnel_policy, NULL);
 
 	if (err < 0)
 		return err;
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 5928d22ba9c8..07181d2273e1 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -1122,7 +1122,7 @@ static int mpls_netconf_get_devconf(struct sk_buff *in_skb,
 	int err;
 
 	err = nlmsg_parse(nlh, sizeof(*ncm), tb, NETCONFA_MAX,
-			  devconf_mpls_policy);
+			  devconf_mpls_policy, NULL);
 	if (err < 0)
 		goto errout;
 
@@ -1643,7 +1643,8 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
 	int index;
 	int err;
 
-	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_mpls_policy);
+	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_mpls_policy,
+			  NULL);
 	if (err < 0)
 		goto errout;
 
diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
index fe00e98667cf..369c7a23c86c 100644
--- a/net/mpls/mpls_iptunnel.c
+++ b/net/mpls/mpls_iptunnel.c
@@ -168,7 +168,7 @@ static int mpls_build_state(struct nlattr *nla,
 	int ret;
 
 	ret = nla_parse_nested(tb, MPLS_IPTUNNEL_MAX, nla,
-			       mpls_iptunnel_policy);
+			       mpls_iptunnel_policy, NULL);
 	if (ret < 0)
 		return ret;
 
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 26356bf8cebf..9bd5b6636181 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -295,7 +295,8 @@ ip_set_get_ipaddr4(struct nlattr *nla,  __be32 *ipaddr)
 
 	if (unlikely(!flag_nested(nla)))
 		return -IPSET_ERR_PROTOCOL;
-	if (nla_parse_nested(tb, IPSET_ATTR_IPADDR_MAX, nla, ipaddr_policy))
+	if (nla_parse_nested(tb, IPSET_ATTR_IPADDR_MAX, nla,
+			     ipaddr_policy, NULL))
 		return -IPSET_ERR_PROTOCOL;
 	if (unlikely(!ip_set_attr_netorder(tb, IPSET_ATTR_IPADDR_IPV4)))
 		return -IPSET_ERR_PROTOCOL;
@@ -313,7 +314,8 @@ ip_set_get_ipaddr6(struct nlattr *nla, union nf_inet_addr *ipaddr)
 	if (unlikely(!flag_nested(nla)))
 		return -IPSET_ERR_PROTOCOL;
 
-	if (nla_parse_nested(tb, IPSET_ATTR_IPADDR_MAX, nla, ipaddr_policy))
+	if (nla_parse_nested(tb, IPSET_ATTR_IPADDR_MAX, nla,
+			     ipaddr_policy, NULL))
 		return -IPSET_ERR_PROTOCOL;
 	if (unlikely(!ip_set_attr_netorder(tb, IPSET_ATTR_IPADDR_IPV6)))
 		return -IPSET_ERR_PROTOCOL;
@@ -906,7 +908,7 @@ static int ip_set_create(struct net *net, struct sock *ctnl,
 	/* Without holding any locks, create private part. */
 	if (attr[IPSET_ATTR_DATA] &&
 	    nla_parse_nested(tb, IPSET_ATTR_CREATE_MAX, attr[IPSET_ATTR_DATA],
-			     set->type->create_policy)) {
+			     set->type->create_policy, NULL)) {
 		ret = -IPSET_ERR_PROTOCOL;
 		goto put_out;
 	}
@@ -1257,8 +1259,8 @@ dump_init(struct netlink_callback *cb, struct ip_set_net *inst)
 	ip_set_id_t index;
 
 	/* Second pass, so parser can't fail */
-	nla_parse(cda, IPSET_ATTR_CMD_MAX,
-		  attr, nlh->nlmsg_len - min_len, ip_set_setname_policy);
+	nla_parse(cda, IPSET_ATTR_CMD_MAX, attr, nlh->nlmsg_len - min_len,
+		  ip_set_setname_policy, NULL);
 
 	if (cda[IPSET_ATTR_SETNAME]) {
 		struct ip_set *set;
@@ -1501,9 +1503,8 @@ call_ad(struct sock *ctnl, struct sk_buff *skb, struct ip_set *set,
 		memcpy(&errmsg->msg, nlh, nlh->nlmsg_len);
 		cmdattr = (void *)&errmsg->msg + min_len;
 
-		nla_parse(cda, IPSET_ATTR_CMD_MAX,
-			  cmdattr, nlh->nlmsg_len - min_len,
-			  ip_set_adt_policy);
+		nla_parse(cda, IPSET_ATTR_CMD_MAX, cmdattr,
+			  nlh->nlmsg_len - min_len, ip_set_adt_policy, NULL);
 
 		errline = nla_data(cda[IPSET_ATTR_LINENO]);
 
@@ -1549,7 +1550,7 @@ static int ip_set_uadd(struct net *net, struct sock *ctnl, struct sk_buff *skb,
 	if (attr[IPSET_ATTR_DATA]) {
 		if (nla_parse_nested(tb, IPSET_ATTR_ADT_MAX,
 				     attr[IPSET_ATTR_DATA],
-				     set->type->adt_policy))
+				     set->type->adt_policy, NULL))
 			return -IPSET_ERR_PROTOCOL;
 		ret = call_ad(ctnl, skb, set, tb, IPSET_ADD, flags,
 			      use_lineno);
@@ -1561,7 +1562,7 @@ static int ip_set_uadd(struct net *net, struct sock *ctnl, struct sk_buff *skb,
 			if (nla_type(nla) != IPSET_ATTR_DATA ||
 			    !flag_nested(nla) ||
 			    nla_parse_nested(tb, IPSET_ATTR_ADT_MAX, nla,
-					     set->type->adt_policy))
+					     set->type->adt_policy, NULL))
 				return -IPSET_ERR_PROTOCOL;
 			ret = call_ad(ctnl, skb, set, tb, IPSET_ADD,
 				      flags, use_lineno);
@@ -1603,7 +1604,7 @@ static int ip_set_udel(struct net *net, struct sock *ctnl, struct sk_buff *skb,
 	if (attr[IPSET_ATTR_DATA]) {
 		if (nla_parse_nested(tb, IPSET_ATTR_ADT_MAX,
 				     attr[IPSET_ATTR_DATA],
-				     set->type->adt_policy))
+				     set->type->adt_policy, NULL))
 			return -IPSET_ERR_PROTOCOL;
 		ret = call_ad(ctnl, skb, set, tb, IPSET_DEL, flags,
 			      use_lineno);
@@ -1615,7 +1616,7 @@ static int ip_set_udel(struct net *net, struct sock *ctnl, struct sk_buff *skb,
 			if (nla_type(nla) != IPSET_ATTR_DATA ||
 			    !flag_nested(nla) ||
 			    nla_parse_nested(tb, IPSET_ATTR_ADT_MAX, nla,
-					     set->type->adt_policy))
+					     set->type->adt_policy, NULL))
 				return -IPSET_ERR_PROTOCOL;
 			ret = call_ad(ctnl, skb, set, tb, IPSET_DEL,
 				      flags, use_lineno);
@@ -1646,7 +1647,7 @@ static int ip_set_utest(struct net *net, struct sock *ctnl, struct sk_buff *skb,
 		return -ENOENT;
 
 	if (nla_parse_nested(tb, IPSET_ATTR_ADT_MAX, attr[IPSET_ATTR_DATA],
-			     set->type->adt_policy))
+			     set->type->adt_policy, NULL))
 		return -IPSET_ERR_PROTOCOL;
 
 	rcu_read_lock_bh();
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 541aa7694775..adb7ee142c5f 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3089,7 +3089,8 @@ static int ip_vs_genl_parse_service(struct netns_ipvs *ipvs,
 
 	/* Parse mandatory identifying service fields first */
 	if (nla == NULL ||
-	    nla_parse_nested(attrs, IPVS_SVC_ATTR_MAX, nla, ip_vs_svc_policy))
+	    nla_parse_nested(attrs, IPVS_SVC_ATTR_MAX, nla,
+			     ip_vs_svc_policy, NULL))
 		return -EINVAL;
 
 	nla_af		= attrs[IPVS_SVC_ATTR_AF];
@@ -3251,8 +3252,8 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
 	mutex_lock(&__ip_vs_mutex);
 
 	/* Try to find the service for which to dump destinations */
-	if (nlmsg_parse(cb->nlh, GENL_HDRLEN, attrs,
-			IPVS_CMD_ATTR_MAX, ip_vs_cmd_policy))
+	if (nlmsg_parse(cb->nlh, GENL_HDRLEN, attrs, IPVS_CMD_ATTR_MAX,
+			ip_vs_cmd_policy, NULL))
 		goto out_err;
 
 
@@ -3288,7 +3289,8 @@ static int ip_vs_genl_parse_dest(struct ip_vs_dest_user_kern *udest,
 
 	/* Parse mandatory identifying destination fields first */
 	if (nla == NULL ||
-	    nla_parse_nested(attrs, IPVS_DEST_ATTR_MAX, nla, ip_vs_dest_policy))
+	    nla_parse_nested(attrs, IPVS_DEST_ATTR_MAX, nla,
+			     ip_vs_dest_policy, NULL))
 		return -EINVAL;
 
 	nla_addr	= attrs[IPVS_DEST_ATTR_ADDR];
@@ -3530,7 +3532,7 @@ static int ip_vs_genl_set_daemon(struct sk_buff *skb, struct genl_info *info)
 		if (!info->attrs[IPVS_CMD_ATTR_DAEMON] ||
 		    nla_parse_nested(daemon_attrs, IPVS_DAEMON_ATTR_MAX,
 				     info->attrs[IPVS_CMD_ATTR_DAEMON],
-				     ip_vs_daemon_policy))
+				     ip_vs_daemon_policy, NULL))
 			goto out;
 
 		if (cmd == IPVS_CMD_NEW_DAEMON)
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index ecdc324c7785..ace824ab2e03 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -908,7 +908,7 @@ static int ctnetlink_parse_tuple_ip(struct nlattr *attr,
 	struct nf_conntrack_l3proto *l3proto;
 	int ret = 0;
 
-	ret = nla_parse_nested(tb, CTA_IP_MAX, attr, NULL);
+	ret = nla_parse_nested(tb, CTA_IP_MAX, attr, NULL, NULL);
 	if (ret < 0)
 		return ret;
 
@@ -917,7 +917,7 @@ static int ctnetlink_parse_tuple_ip(struct nlattr *attr,
 
 	if (likely(l3proto->nlattr_to_tuple)) {
 		ret = nla_validate_nested(attr, CTA_IP_MAX,
-					  l3proto->nla_policy);
+					  l3proto->nla_policy, NULL);
 		if (ret == 0)
 			ret = l3proto->nlattr_to_tuple(tb, tuple);
 	}
@@ -938,7 +938,8 @@ static int ctnetlink_parse_tuple_proto(struct nlattr *attr,
 	struct nf_conntrack_l4proto *l4proto;
 	int ret = 0;
 
-	ret = nla_parse_nested(tb, CTA_PROTO_MAX, attr, proto_nla_policy);
+	ret = nla_parse_nested(tb, CTA_PROTO_MAX, attr, proto_nla_policy,
+			       NULL);
 	if (ret < 0)
 		return ret;
 
@@ -951,7 +952,7 @@ static int ctnetlink_parse_tuple_proto(struct nlattr *attr,
 
 	if (likely(l4proto->nlattr_to_tuple)) {
 		ret = nla_validate_nested(attr, CTA_PROTO_MAX,
-					  l4proto->nla_policy);
+					  l4proto->nla_policy, NULL);
 		if (ret == 0)
 			ret = l4proto->nlattr_to_tuple(tb, tuple);
 	}
@@ -1015,7 +1016,8 @@ ctnetlink_parse_tuple(const struct nlattr * const cda[],
 
 	memset(tuple, 0, sizeof(*tuple));
 
-	err = nla_parse_nested(tb, CTA_TUPLE_MAX, cda[type], tuple_nla_policy);
+	err = nla_parse_nested(tb, CTA_TUPLE_MAX, cda[type], tuple_nla_policy,
+			       NULL);
 	if (err < 0)
 		return err;
 
@@ -1065,7 +1067,7 @@ static int ctnetlink_parse_help(const struct nlattr *attr, char **helper_name,
 	int err;
 	struct nlattr *tb[CTA_HELP_MAX+1];
 
-	err = nla_parse_nested(tb, CTA_HELP_MAX, attr, help_nla_policy);
+	err = nla_parse_nested(tb, CTA_HELP_MAX, attr, help_nla_policy, NULL);
 	if (err < 0)
 		return err;
 
@@ -1566,7 +1568,8 @@ static int ctnetlink_change_protoinfo(struct nf_conn *ct,
 	struct nf_conntrack_l4proto *l4proto;
 	int err = 0;
 
-	err = nla_parse_nested(tb, CTA_PROTOINFO_MAX, attr, protoinfo_policy);
+	err = nla_parse_nested(tb, CTA_PROTOINFO_MAX, attr, protoinfo_policy,
+			       NULL);
 	if (err < 0)
 		return err;
 
@@ -1591,7 +1594,7 @@ static int change_seq_adj(struct nf_ct_seqadj *seq,
 	int err;
 	struct nlattr *cda[CTA_SEQADJ_MAX+1];
 
-	err = nla_parse_nested(cda, CTA_SEQADJ_MAX, attr, seqadj_policy);
+	err = nla_parse_nested(cda, CTA_SEQADJ_MAX, attr, seqadj_policy, NULL);
 	if (err < 0)
 		return err;
 
@@ -2348,7 +2351,7 @@ ctnetlink_glue_parse(const struct nlattr *attr, struct nf_conn *ct)
 	struct nlattr *cda[CTA_MAX+1];
 	int ret;
 
-	ret = nla_parse_nested(cda, CTA_MAX, attr, ct_nla_policy);
+	ret = nla_parse_nested(cda, CTA_MAX, attr, ct_nla_policy, NULL);
 	if (ret < 0)
 		return ret;
 
@@ -2385,7 +2388,8 @@ ctnetlink_glue_attach_expect(const struct nlattr *attr, struct nf_conn *ct,
 	struct nf_conntrack_expect *exp;
 	int err;
 
-	err = nla_parse_nested(cda, CTA_EXPECT_MAX, attr, exp_nla_policy);
+	err = nla_parse_nested(cda, CTA_EXPECT_MAX, attr, exp_nla_policy,
+			       NULL);
 	if (err < 0)
 		return err;
 
@@ -3004,7 +3008,8 @@ ctnetlink_parse_expect_nat(const struct nlattr *attr,
 	struct nf_conntrack_tuple nat_tuple = {};
 	int err;
 
-	err = nla_parse_nested(tb, CTA_EXPECT_NAT_MAX, attr, exp_nat_nla_policy);
+	err = nla_parse_nested(tb, CTA_EXPECT_NAT_MAX, attr,
+			       exp_nat_nla_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index 93dd1c5b7bff..b2e02dfe7fa8 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -665,7 +665,7 @@ static int nlattr_to_dccp(struct nlattr *cda[], struct nf_conn *ct)
 		return 0;
 
 	err = nla_parse_nested(tb, CTA_PROTOINFO_DCCP_MAX, attr,
-			       dccp_nla_policy);
+			       dccp_nla_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 33279aab583d..2a7300587c87 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -584,10 +584,8 @@ static int nlattr_to_sctp(struct nlattr *cda[], struct nf_conn *ct)
 	if (!attr)
 		return 0;
 
-	err = nla_parse_nested(tb,
-			       CTA_PROTOINFO_SCTP_MAX,
-			       attr,
-			       sctp_nla_policy);
+	err = nla_parse_nested(tb, CTA_PROTOINFO_SCTP_MAX, attr,
+			       sctp_nla_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index b122e9dacfed..85bde77ad967 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -1234,7 +1234,8 @@ static int nlattr_to_tcp(struct nlattr *cda[], struct nf_conn *ct)
 	if (!pattr)
 		return 0;
 
-	err = nla_parse_nested(tb, CTA_PROTOINFO_TCP_MAX, pattr, tcp_nla_policy);
+	err = nla_parse_nested(tb, CTA_PROTOINFO_TCP_MAX, pattr,
+			       tcp_nla_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 82802e4a6640..908ba5abbc0b 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -751,7 +751,8 @@ static int nfnetlink_parse_nat_proto(struct nlattr *attr,
 	const struct nf_nat_l4proto *l4proto;
 	int err;
 
-	err = nla_parse_nested(tb, CTA_PROTONAT_MAX, attr, protonat_nla_policy);
+	err = nla_parse_nested(tb, CTA_PROTONAT_MAX, attr,
+			       protonat_nla_policy, NULL);
 	if (err < 0)
 		return err;
 
@@ -780,7 +781,7 @@ nfnetlink_parse_nat(const struct nlattr *nat,
 
 	memset(range, 0, sizeof(*range));
 
-	err = nla_parse_nested(tb, CTA_NAT_MAX, nat, nat_nla_policy);
+	err = nla_parse_nested(tb, CTA_NAT_MAX, nat, nat_nla_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 2d822d2fd830..907431318637 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -1182,7 +1182,8 @@ static struct nft_stats __percpu *nft_stats_alloc(const struct nlattr *attr)
 	struct nft_stats *stats;
 	int err;
 
-	err = nla_parse_nested(tb, NFTA_COUNTER_MAX, attr, nft_counter_policy);
+	err = nla_parse_nested(tb, NFTA_COUNTER_MAX, attr, nft_counter_policy,
+			       NULL);
 	if (err < 0)
 		return ERR_PTR(err);
 
@@ -1257,7 +1258,7 @@ static int nft_chain_parse_hook(struct net *net,
 	int err;
 
 	err = nla_parse_nested(ha, NFTA_HOOK_MAX, nla[NFTA_CHAIN_HOOK],
-			       nft_hook_policy);
+			       nft_hook_policy, NULL);
 	if (err < 0)
 		return err;
 
@@ -1724,7 +1725,7 @@ static int nf_tables_expr_parse(const struct nft_ctx *ctx,
 	struct nlattr *tb[NFTA_EXPR_MAX + 1];
 	int err;
 
-	err = nla_parse_nested(tb, NFTA_EXPR_MAX, nla, nft_expr_policy);
+	err = nla_parse_nested(tb, NFTA_EXPR_MAX, nla, nft_expr_policy, NULL);
 	if (err < 0)
 		return err;
 
@@ -1734,7 +1735,7 @@ static int nf_tables_expr_parse(const struct nft_ctx *ctx,
 
 	if (tb[NFTA_EXPR_DATA]) {
 		err = nla_parse_nested(info->tb, type->maxattr,
-				       tb[NFTA_EXPR_DATA], type->policy);
+				       tb[NFTA_EXPR_DATA], type->policy, NULL);
 		if (err < 0)
 			goto err1;
 	} else
@@ -2879,7 +2880,8 @@ static int nf_tables_set_desc_parse(const struct nft_ctx *ctx,
 	struct nlattr *da[NFTA_SET_DESC_MAX + 1];
 	int err;
 
-	err = nla_parse_nested(da, NFTA_SET_DESC_MAX, nla, nft_set_desc_policy);
+	err = nla_parse_nested(da, NFTA_SET_DESC_MAX, nla,
+			       nft_set_desc_policy, NULL);
 	if (err < 0)
 		return err;
 
@@ -3381,7 +3383,8 @@ static int nf_tables_dump_set(struct sk_buff *skb, struct netlink_callback *cb)
 	int event, err;
 
 	err = nlmsg_parse(cb->nlh, sizeof(struct nfgenmsg), nla,
-			  NFTA_SET_ELEM_LIST_MAX, nft_set_elem_list_policy);
+			  NFTA_SET_ELEM_LIST_MAX, nft_set_elem_list_policy,
+			  NULL);
 	if (err < 0)
 		return err;
 
@@ -3640,7 +3643,7 @@ static int nft_add_set_elem(struct nft_ctx *ctx, struct nft_set *set,
 	int err;
 
 	err = nla_parse_nested(nla, NFTA_SET_ELEM_MAX, attr,
-			       nft_set_elem_policy);
+			       nft_set_elem_policy, NULL);
 	if (err < 0)
 		return err;
 
@@ -3870,7 +3873,7 @@ static int nft_del_setelem(struct nft_ctx *ctx, struct nft_set *set,
 	int err;
 
 	err = nla_parse_nested(nla, NFTA_SET_ELEM_MAX, attr,
-			       nft_set_elem_policy);
+			       nft_set_elem_policy, NULL);
 	if (err < 0)
 		goto err1;
 
@@ -4101,7 +4104,8 @@ static struct nft_object *nft_obj_init(const struct nft_ctx *ctx,
 	int err;
 
 	if (attr) {
-		err = nla_parse_nested(tb, type->maxattr, attr, type->policy);
+		err = nla_parse_nested(tb, type->maxattr, attr, type->policy,
+				       NULL);
 		if (err < 0)
 			goto err1;
 	} else {
@@ -5314,7 +5318,8 @@ static int nft_verdict_init(const struct nft_ctx *ctx, struct nft_data *data,
 	struct nft_chain *chain;
 	int err;
 
-	err = nla_parse_nested(tb, NFTA_VERDICT_MAX, nla, nft_verdict_policy);
+	err = nla_parse_nested(tb, NFTA_VERDICT_MAX, nla, nft_verdict_policy,
+			       NULL);
 	if (err < 0)
 		return err;
 
@@ -5444,7 +5449,7 @@ int nft_data_init(const struct nft_ctx *ctx,
 	struct nlattr *tb[NFTA_DATA_MAX + 1];
 	int err;
 
-	err = nla_parse_nested(tb, NFTA_DATA_MAX, nla, nft_data_policy);
+	err = nla_parse_nested(tb, NFTA_DATA_MAX, nla, nft_data_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 181d3bb800e6..792def00a07d 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -192,8 +192,8 @@ static int nfnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 		int attrlen = nlh->nlmsg_len - min_len;
 		__u8 subsys_id = NFNL_SUBSYS_ID(type);
 
-		err = nla_parse(cda, ss->cb[cb_id].attr_count,
-				attr, attrlen, ss->cb[cb_id].policy);
+		err = nla_parse(cda, ss->cb[cb_id].attr_count, attr, attrlen,
+				ss->cb[cb_id].policy, NULL);
 		if (err < 0) {
 			rcu_read_unlock();
 			return err;
@@ -377,8 +377,8 @@ static void nfnetlink_rcv_batch(struct sk_buff *skb, struct nlmsghdr *nlh,
 			struct nlattr *attr = (void *)nlh + min_len;
 			int attrlen = nlh->nlmsg_len - min_len;
 
-			err = nla_parse(cda, ss->cb[cb_id].attr_count,
-					attr, attrlen, ss->cb[cb_id].policy);
+			err = nla_parse(cda, ss->cb[cb_id].attr_count, attr,
+					attrlen, ss->cb[cb_id].policy, NULL);
 			if (err < 0)
 				goto ack;
 
@@ -467,7 +467,8 @@ static void nfnetlink_rcv_skb_batch(struct sk_buff *skb, struct nlmsghdr *nlh)
 	    skb->len < NLMSG_HDRLEN + sizeof(struct nfgenmsg))
 		return;
 
-	err = nla_parse(cda, NFNL_BATCH_MAX, attr, attrlen, nfnl_batch_policy);
+	err = nla_parse(cda, NFNL_BATCH_MAX, attr, attrlen, nfnl_batch_policy,
+			NULL);
 	if (err < 0) {
 		netlink_ack(skb, nlh, err, NULL);
 		return;
diff --git a/net/netfilter/nfnetlink_acct.c b/net/netfilter/nfnetlink_acct.c
index c86da174a5fc..2837d5fb98bd 100644
--- a/net/netfilter/nfnetlink_acct.c
+++ b/net/netfilter/nfnetlink_acct.c
@@ -244,7 +244,8 @@ nfacct_filter_alloc(const struct nlattr * const attr)
 	struct nlattr *tb[NFACCT_FILTER_MAX + 1];
 	int err;
 
-	err = nla_parse_nested(tb, NFACCT_FILTER_MAX, attr, filter_policy);
+	err = nla_parse_nested(tb, NFACCT_FILTER_MAX, attr, filter_policy,
+			       NULL);
 	if (err < 0)
 		return ERR_PTR(err);
 
diff --git a/net/netfilter/nfnetlink_cthelper.c b/net/netfilter/nfnetlink_cthelper.c
index d45558178da5..5b6c68311566 100644
--- a/net/netfilter/nfnetlink_cthelper.c
+++ b/net/netfilter/nfnetlink_cthelper.c
@@ -77,7 +77,8 @@ nfnl_cthelper_parse_tuple(struct nf_conntrack_tuple *tuple,
 	int err;
 	struct nlattr *tb[NFCTH_TUPLE_MAX+1];
 
-	err = nla_parse_nested(tb, NFCTH_TUPLE_MAX, attr, nfnl_cthelper_tuple_pol);
+	err = nla_parse_nested(tb, NFCTH_TUPLE_MAX, attr,
+			       nfnl_cthelper_tuple_pol, NULL);
 	if (err < 0)
 		return err;
 
@@ -137,7 +138,8 @@ nfnl_cthelper_expect_policy(struct nf_conntrack_expect_policy *expect_policy,
 	int err;
 	struct nlattr *tb[NFCTH_POLICY_MAX+1];
 
-	err = nla_parse_nested(tb, NFCTH_POLICY_MAX, attr, nfnl_cthelper_expect_pol);
+	err = nla_parse_nested(tb, NFCTH_POLICY_MAX, attr,
+			       nfnl_cthelper_expect_pol, NULL);
 	if (err < 0)
 		return err;
 
@@ -171,7 +173,7 @@ nfnl_cthelper_parse_expect_policy(struct nf_conntrack_helper *helper,
 	unsigned int class_max;
 
 	ret = nla_parse_nested(tb, NFCTH_POLICY_SET_MAX, attr,
-			       nfnl_cthelper_expect_policy_set);
+			       nfnl_cthelper_expect_policy_set, NULL);
 	if (ret < 0)
 		return ret;
 
@@ -276,7 +278,7 @@ nfnl_cthelper_update_policy_one(const struct nf_conntrack_expect_policy *policy,
 	int err;
 
 	err = nla_parse_nested(tb, NFCTH_POLICY_MAX, attr,
-			       nfnl_cthelper_expect_pol);
+			       nfnl_cthelper_expect_pol, NULL);
 	if (err < 0)
 		return err;
 
@@ -336,7 +338,7 @@ static int nfnl_cthelper_update_policy(struct nf_conntrack_helper *helper,
 	int err;
 
 	err = nla_parse_nested(tb, NFCTH_POLICY_SET_MAX, attr,
-			       nfnl_cthelper_expect_policy_set);
+			       nfnl_cthelper_expect_policy_set, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index 57c2cdf7b691..0a3510e7e396 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -56,7 +56,8 @@ ctnl_timeout_parse_policy(void *timeouts, struct nf_conntrack_l4proto *l4proto,
 		struct nlattr *tb[l4proto->ctnl_timeout.nlattr_max+1];
 
 		ret = nla_parse_nested(tb, l4proto->ctnl_timeout.nlattr_max,
-				       attr, l4proto->ctnl_timeout.nla_policy);
+				       attr, l4proto->ctnl_timeout.nla_policy,
+				       NULL);
 		if (ret < 0)
 			return ret;
 
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 933509ebf3d3..3be6fef30581 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -1109,7 +1109,7 @@ static int nfqa_parse_bridge(struct nf_queue_entry *entry,
 		int err;
 
 		err = nla_parse_nested(tb, NFQA_VLAN_MAX, nfqa[NFQA_VLAN],
-				       nfqa_vlan_policy);
+				       nfqa_vlan_policy, NULL);
 		if (err < 0)
 			return err;
 
diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index fab6bf3f955e..d76d0f36799f 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -200,7 +200,7 @@ static int nft_parse_compat(const struct nlattr *attr, u16 *proto, bool *inv)
 	int err;
 
 	err = nla_parse_nested(tb, NFTA_RULE_COMPAT_MAX, attr,
-			       nft_rule_compat_policy);
+			       nft_rule_compat_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/netlabel/netlabel_cipso_v4.c b/net/netlabel/netlabel_cipso_v4.c
index 4149d3e63589..9aacf2da3d98 100644
--- a/net/netlabel/netlabel_cipso_v4.c
+++ b/net/netlabel/netlabel_cipso_v4.c
@@ -101,7 +101,7 @@ static int netlbl_cipsov4_add_common(struct genl_info *info,
 
 	if (nla_validate_nested(info->attrs[NLBL_CIPSOV4_A_TAGLST],
 				NLBL_CIPSOV4_A_MAX,
-				netlbl_cipsov4_genl_policy) != 0)
+				netlbl_cipsov4_genl_policy, NULL) != 0)
 		return -EINVAL;
 
 	nla_for_each_nested(nla, info->attrs[NLBL_CIPSOV4_A_TAGLST], nla_rem)
@@ -148,7 +148,7 @@ static int netlbl_cipsov4_add_std(struct genl_info *info,
 
 	if (nla_validate_nested(info->attrs[NLBL_CIPSOV4_A_MLSLVLLST],
 				NLBL_CIPSOV4_A_MAX,
-				netlbl_cipsov4_genl_policy) != 0)
+				netlbl_cipsov4_genl_policy, NULL) != 0)
 		return -EINVAL;
 
 	doi_def = kmalloc(sizeof(*doi_def), GFP_KERNEL);
@@ -170,10 +170,10 @@ static int netlbl_cipsov4_add_std(struct genl_info *info,
 			    info->attrs[NLBL_CIPSOV4_A_MLSLVLLST],
 			    nla_a_rem)
 		if (nla_type(nla_a) == NLBL_CIPSOV4_A_MLSLVL) {
-			if (nla_validate_nested(nla_a,
-					    NLBL_CIPSOV4_A_MAX,
-					    netlbl_cipsov4_genl_policy) != 0)
-					goto add_std_failure;
+			if (nla_validate_nested(nla_a, NLBL_CIPSOV4_A_MAX,
+						netlbl_cipsov4_genl_policy,
+						NULL) != 0)
+				goto add_std_failure;
 			nla_for_each_nested(nla_b, nla_a, nla_b_rem)
 				switch (nla_type(nla_b)) {
 				case NLBL_CIPSOV4_A_MLSLVLLOC:
@@ -236,7 +236,7 @@ static int netlbl_cipsov4_add_std(struct genl_info *info,
 	if (info->attrs[NLBL_CIPSOV4_A_MLSCATLST]) {
 		if (nla_validate_nested(info->attrs[NLBL_CIPSOV4_A_MLSCATLST],
 					NLBL_CIPSOV4_A_MAX,
-					netlbl_cipsov4_genl_policy) != 0)
+					netlbl_cipsov4_genl_policy, NULL) != 0)
 			goto add_std_failure;
 
 		nla_for_each_nested(nla_a,
@@ -244,8 +244,9 @@ static int netlbl_cipsov4_add_std(struct genl_info *info,
 				    nla_a_rem)
 			if (nla_type(nla_a) == NLBL_CIPSOV4_A_MLSCAT) {
 				if (nla_validate_nested(nla_a,
-					      NLBL_CIPSOV4_A_MAX,
-					      netlbl_cipsov4_genl_policy) != 0)
+							NLBL_CIPSOV4_A_MAX,
+							netlbl_cipsov4_genl_policy,
+							NULL) != 0)
 					goto add_std_failure;
 				nla_for_each_nested(nla_b, nla_a, nla_b_rem)
 					switch (nla_type(nla_b)) {
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 4b598a5999a2..ff6db5e66eb5 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -574,7 +574,7 @@ static int genl_family_rcv_msg(const struct genl_family *family,
 
 	if (attrbuf) {
 		err = nlmsg_parse(nlh, hdrlen, attrbuf, family->maxattr,
-				  ops->policy);
+				  ops->policy, NULL);
 		if (err < 0)
 			goto out;
 	}
diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
index 03f3d5c7beb8..aca903c12671 100644
--- a/net/nfc/netlink.c
+++ b/net/nfc/netlink.c
@@ -119,7 +119,8 @@ static struct nfc_dev *__get_device_from_cb(struct netlink_callback *cb)
 	u32 idx;
 
 	rc = nlmsg_parse(cb->nlh, GENL_HDRLEN + nfc_genl_family.hdrsize,
-			 attrbuf, nfc_genl_family.maxattr, nfc_genl_policy);
+			 attrbuf, nfc_genl_family.maxattr, nfc_genl_policy,
+			 NULL);
 	if (rc < 0)
 		return ERR_PTR(rc);
 
@@ -1161,7 +1162,7 @@ static int nfc_genl_llc_sdreq(struct sk_buff *skb, struct genl_info *info)
 
 	nla_for_each_nested(attr, info->attrs[NFC_ATTR_LLC_SDP], rem) {
 		rc = nla_parse_nested(sdp_attrs, NFC_SDP_ATTR_MAX, attr,
-				      nfc_sdp_genl_policy);
+				      nfc_sdp_genl_policy, NULL);
 
 		if (rc != 0) {
 			rc = -EINVAL;
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 9c62b6325f7a..7b17da9a94a0 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1353,7 +1353,7 @@ static int ovs_flow_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	int err;
 
 	err = genlmsg_parse(cb->nlh, &dp_flow_genl_family, a,
-			    OVS_FLOW_ATTR_MAX, flow_policy);
+			    OVS_FLOW_ATTR_MAX, flow_policy, NULL);
 	if (err)
 		return err;
 	ufid_flags = ovs_nla_get_ufid_flags(a[OVS_FLOW_ATTR_UFID_FLAGS]);
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index df82b81a9b35..7e1d8a2afa63 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -2427,8 +2427,8 @@ static int validate_userspace(const struct nlattr *attr)
 	struct nlattr *a[OVS_USERSPACE_ATTR_MAX + 1];
 	int error;
 
-	error = nla_parse_nested(a, OVS_USERSPACE_ATTR_MAX,
-				 attr, userspace_policy);
+	error = nla_parse_nested(a, OVS_USERSPACE_ATTR_MAX, attr,
+				 userspace_policy, NULL);
 	if (error)
 		return error;
 
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index 7eb955e453e6..869acb3b3d3f 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -70,7 +70,8 @@ static int vxlan_configure_exts(struct vport *vport, struct nlattr *attr,
 	if (nla_len(attr) < sizeof(struct nlattr))
 		return -EINVAL;
 
-	err = nla_parse_nested(exts, OVS_VXLAN_EXT_MAX, attr, exts_policy);
+	err = nla_parse_nested(exts, OVS_VXLAN_EXT_MAX, attr, exts_policy,
+			       NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
index bc5ee5fbe6ae..363799bf97f6 100644
--- a/net/phonet/pn_netlink.c
+++ b/net/phonet/pn_netlink.c
@@ -78,7 +78,8 @@ static int addr_doit(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	ASSERT_RTNL();
 
-	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_phonet_policy);
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_phonet_policy,
+			  NULL);
 	if (err < 0)
 		return err;
 
@@ -243,7 +244,8 @@ static int route_doit(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	ASSERT_RTNL();
 
-	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_phonet_policy);
+	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_phonet_policy,
+			  NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/qrtr/qrtr.c b/net/qrtr/qrtr.c
index ae5ac175b2be..7fdbb34002f5 100644
--- a/net/qrtr/qrtr.c
+++ b/net/qrtr/qrtr.c
@@ -957,7 +957,7 @@ static int qrtr_addr_doit(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	ASSERT_RTNL();
 
-	rc = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, qrtr_policy);
+	rc = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, qrtr_policy, NULL);
 	if (rc < 0)
 		return rc;
 
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index b70aa57319ea..79d875c6e8a0 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -557,7 +557,7 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
 	int err;
 
 	if (name == NULL) {
-		err = nla_parse_nested(tb, TCA_ACT_MAX, nla, NULL);
+		err = nla_parse_nested(tb, TCA_ACT_MAX, nla, NULL, NULL);
 		if (err < 0)
 			goto err_out;
 		err = -EINVAL;
@@ -654,7 +654,7 @@ int tcf_action_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 	int err;
 	int i;
 
-	err = nla_parse_nested(tb, TCA_ACT_MAX_PRIO, nla, NULL);
+	err = nla_parse_nested(tb, TCA_ACT_MAX_PRIO, nla, NULL, NULL);
 	if (err < 0)
 		return err;
 
@@ -786,7 +786,7 @@ static struct tc_action *tcf_action_get_1(struct net *net, struct nlattr *nla,
 	int index;
 	int err;
 
-	err = nla_parse_nested(tb, TCA_ACT_MAX, nla, NULL);
+	err = nla_parse_nested(tb, TCA_ACT_MAX, nla, NULL, NULL);
 	if (err < 0)
 		goto err_out;
 
@@ -835,7 +835,7 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 
 	b = skb_tail_pointer(skb);
 
-	err = nla_parse_nested(tb, TCA_ACT_MAX, nla, NULL);
+	err = nla_parse_nested(tb, TCA_ACT_MAX, nla, NULL, NULL);
 	if (err < 0)
 		goto err_out;
 
@@ -921,7 +921,7 @@ tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
 	struct tc_action *act;
 	LIST_HEAD(actions);
 
-	ret = nla_parse_nested(tb, TCA_ACT_MAX_PRIO, nla, NULL);
+	ret = nla_parse_nested(tb, TCA_ACT_MAX_PRIO, nla, NULL, NULL);
 	if (ret < 0)
 		return ret;
 
@@ -1004,7 +1004,8 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n)
 	    !netlink_capable(skb, CAP_NET_ADMIN))
 		return -EPERM;
 
-	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCA_ACT_MAX, NULL);
+	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCA_ACT_MAX, NULL,
+			  NULL);
 	if (ret < 0)
 		return ret;
 
@@ -1051,19 +1052,20 @@ static struct nlattr *find_dump_kind(const struct nlmsghdr *n)
 	struct nlattr *nla[TCAA_MAX + 1];
 	struct nlattr *kind;
 
-	if (nlmsg_parse(n, sizeof(struct tcamsg), nla, TCAA_MAX, NULL) < 0)
+	if (nlmsg_parse(n, sizeof(struct tcamsg), nla, TCAA_MAX,
+			NULL, NULL) < 0)
 		return NULL;
 	tb1 = nla[TCA_ACT_TAB];
 	if (tb1 == NULL)
 		return NULL;
 
 	if (nla_parse(tb, TCA_ACT_MAX_PRIO, nla_data(tb1),
-		      NLMSG_ALIGN(nla_len(tb1)), NULL) < 0)
+		      NLMSG_ALIGN(nla_len(tb1)), NULL, NULL) < 0)
 		return NULL;
 
 	if (tb[1] == NULL)
 		return NULL;
-	if (nla_parse_nested(tb2, TCA_ACT_MAX, tb[1], NULL) < 0)
+	if (nla_parse_nested(tb2, TCA_ACT_MAX, tb[1], NULL, NULL) < 0)
 		return NULL;
 	kind = tb2[TCA_ACT_KIND];
 
diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index 520baa41cba3..d33947d6e9d0 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -283,7 +283,7 @@ static int tcf_bpf_init(struct net *net, struct nlattr *nla,
 	if (!nla)
 		return -EINVAL;
 
-	ret = nla_parse_nested(tb, TCA_ACT_BPF_MAX, nla, act_bpf_policy);
+	ret = nla_parse_nested(tb, TCA_ACT_BPF_MAX, nla, act_bpf_policy, NULL);
 	if (ret < 0)
 		return ret;
 
diff --git a/net/sched/act_connmark.c b/net/sched/act_connmark.c
index f9bb43c25697..2155bc6c6a1e 100644
--- a/net/sched/act_connmark.c
+++ b/net/sched/act_connmark.c
@@ -109,7 +109,8 @@ static int tcf_connmark_init(struct net *net, struct nlattr *nla,
 	if (!nla)
 		return -EINVAL;
 
-	ret = nla_parse_nested(tb, TCA_CONNMARK_MAX, nla, connmark_policy);
+	ret = nla_parse_nested(tb, TCA_CONNMARK_MAX, nla, connmark_policy,
+			       NULL);
 	if (ret < 0)
 		return ret;
 
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index 6c319a40c1cc..ab6fdbd34db7 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -59,7 +59,7 @@ static int tcf_csum_init(struct net *net, struct nlattr *nla,
 	if (nla == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_CSUM_MAX, nla, csum_policy);
+	err = nla_parse_nested(tb, TCA_CSUM_MAX, nla, csum_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index e6c874a2b283..99afe8b1f1fb 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -73,7 +73,7 @@ static int tcf_gact_init(struct net *net, struct nlattr *nla,
 	if (nla == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_GACT_MAX, nla, gact_policy);
+	err = nla_parse_nested(tb, TCA_GACT_MAX, nla, gact_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
index c75ea5c9102c..c5dec308b8b1 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -443,7 +443,7 @@ static int tcf_ife_init(struct net *net, struct nlattr *nla,
 	int ret = 0;
 	int err;
 
-	err = nla_parse_nested(tb, TCA_IFE_MAX, nla, ife_policy);
+	err = nla_parse_nested(tb, TCA_IFE_MAX, nla, ife_policy, NULL);
 	if (err < 0)
 		return err;
 
@@ -514,7 +514,7 @@ static int tcf_ife_init(struct net *net, struct nlattr *nla,
 
 	if (tb[TCA_IFE_METALST]) {
 		err = nla_parse_nested(tb2, IFE_META_MAX, tb[TCA_IFE_METALST],
-				       NULL);
+				       NULL, NULL);
 		if (err) {
 metadata_parse_err:
 			if (exists)
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 992ef8d624f1..36f0ced9e60c 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -107,7 +107,7 @@ static int __tcf_ipt_init(struct tc_action_net *tn, struct nlattr *nla,
 	if (nla == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_IPT_MAX, nla, ipt_policy);
+	err = nla_parse_nested(tb, TCA_IPT_MAX, nla, ipt_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index af49c7dca860..1b5549ababd4 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -87,7 +87,7 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 
 	if (nla == NULL)
 		return -EINVAL;
-	ret = nla_parse_nested(tb, TCA_MIRRED_MAX, nla, mirred_policy);
+	ret = nla_parse_nested(tb, TCA_MIRRED_MAX, nla, mirred_policy, NULL);
 	if (ret < 0)
 		return ret;
 	if (tb[TCA_MIRRED_PARMS] == NULL)
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index 9b6aec665495..9016ab8a0649 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -50,7 +50,7 @@ static int tcf_nat_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 	if (nla == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_NAT_MAX, nla, nat_policy);
+	err = nla_parse_nested(tb, TCA_NAT_MAX, nla, nat_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index c1310472f620..164b5ac094be 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -72,7 +72,7 @@ static struct tcf_pedit_key_ex *tcf_pedit_keys_ex_parse(struct nlattr *nla,
 		}
 
 		err = nla_parse_nested(tb, TCA_PEDIT_KEY_EX_MAX, ka,
-				       pedit_key_ex_policy);
+				       pedit_key_ex_policy, NULL);
 		if (err)
 			goto err_out;
 
@@ -147,7 +147,7 @@ static int tcf_pedit_init(struct net *net, struct nlattr *nla,
 	if (nla == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_PEDIT_MAX, nla, pedit_policy);
+	err = nla_parse_nested(tb, TCA_PEDIT_MAX, nla, pedit_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 0ba91d1ce994..f42008b29311 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -90,7 +90,7 @@ static int tcf_act_police_init(struct net *net, struct nlattr *nla,
 	if (nla == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_POLICE_MAX, nla, police_policy);
+	err = nla_parse_nested(tb, TCA_POLICE_MAX, nla, police_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/act_sample.c b/net/sched/act_sample.c
index 0b8217b4763f..59d6645a4007 100644
--- a/net/sched/act_sample.c
+++ b/net/sched/act_sample.c
@@ -50,7 +50,7 @@ static int tcf_sample_init(struct net *net, struct nlattr *nla,
 
 	if (!nla)
 		return -EINVAL;
-	ret = nla_parse_nested(tb, TCA_SAMPLE_MAX, nla, sample_policy);
+	ret = nla_parse_nested(tb, TCA_SAMPLE_MAX, nla, sample_policy, NULL);
 	if (ret < 0)
 		return ret;
 	if (!tb[TCA_SAMPLE_PARMS] || !tb[TCA_SAMPLE_RATE] ||
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index 823a73ad0c60..43605e7ce051 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -94,7 +94,7 @@ static int tcf_simp_init(struct net *net, struct nlattr *nla,
 	if (nla == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_DEF_MAX, nla, simple_policy);
+	err = nla_parse_nested(tb, TCA_DEF_MAX, nla, simple_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index 06ccae3c12ee..6b3e65d7de0c 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -82,7 +82,7 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 	if (nla == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_SKBEDIT_MAX, nla, skbedit_policy);
+	err = nla_parse_nested(tb, TCA_SKBEDIT_MAX, nla, skbedit_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/act_skbmod.c b/net/sched/act_skbmod.c
index c736627f8f4a..a73c4bbcada2 100644
--- a/net/sched/act_skbmod.c
+++ b/net/sched/act_skbmod.c
@@ -103,7 +103,7 @@ static int tcf_skbmod_init(struct net *net, struct nlattr *nla,
 	if (!nla)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_SKBMOD_MAX, nla, skbmod_policy);
+	err = nla_parse_nested(tb, TCA_SKBMOD_MAX, nla, skbmod_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/act_tunnel_key.c b/net/sched/act_tunnel_key.c
index e3a58e021198..b9a2f241a5b3 100644
--- a/net/sched/act_tunnel_key.c
+++ b/net/sched/act_tunnel_key.c
@@ -89,7 +89,8 @@ static int tunnel_key_init(struct net *net, struct nlattr *nla,
 	if (!nla)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_TUNNEL_KEY_MAX, nla, tunnel_key_policy);
+	err = nla_parse_nested(tb, TCA_TUNNEL_KEY_MAX, nla, tunnel_key_policy,
+			       NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/act_vlan.c b/net/sched/act_vlan.c
index 19e0dba305ce..13ba3a89f675 100644
--- a/net/sched/act_vlan.c
+++ b/net/sched/act_vlan.c
@@ -121,7 +121,7 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
 	if (!nla)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_VLAN_MAX, nla, vlan_policy);
+	err = nla_parse_nested(tb, TCA_VLAN_MAX, nla, vlan_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 732f7cae459d..e2c68c30f97d 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -229,7 +229,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 replay:
 	tp_created = 0;
 
-	err = nlmsg_parse(n, sizeof(*t), tca, TCA_MAX, NULL);
+	err = nlmsg_parse(n, sizeof(*t), tca, TCA_MAX, NULL, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index 5877f6061b57..422414f16b38 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -174,7 +174,7 @@ static int basic_change(struct net *net, struct sk_buff *in_skb,
 		return -EINVAL;
 
 	err = nla_parse_nested(tb, TCA_BASIC_MAX, tca[TCA_OPTIONS],
-			       basic_policy);
+			       basic_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 80f688436dd7..7ddd08efaa0f 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -478,7 +478,8 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 	if (tca[TCA_OPTIONS] == NULL)
 		return -EINVAL;
 
-	ret = nla_parse_nested(tb, TCA_BPF_MAX, tca[TCA_OPTIONS], bpf_policy);
+	ret = nla_parse_nested(tb, TCA_BPF_MAX, tca[TCA_OPTIONS], bpf_policy,
+			       NULL);
 	if (ret < 0)
 		return ret;
 
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index c1f20077837f..b5e7c1bee6c3 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -99,7 +99,7 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 	new->handle = handle;
 	new->tp = tp;
 	err = nla_parse_nested(tb, TCA_CGROUP_MAX, tca[TCA_OPTIONS],
-			       cgroup_policy);
+			       cgroup_policy, NULL);
 	if (err < 0)
 		goto errout;
 
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index ca193af8634a..008ba7e63b7a 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -400,7 +400,7 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 	if (opt == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_FLOW_MAX, opt, flow_policy);
+	err = nla_parse_nested(tb, TCA_FLOW_MAX, opt, flow_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 9d0c99d2e9fb..3e7bd7801aa8 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -848,7 +848,8 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 	if (!tb)
 		return -ENOBUFS;
 
-	err = nla_parse_nested(tb, TCA_FLOWER_MAX, tca[TCA_OPTIONS], fl_policy);
+	err = nla_parse_nested(tb, TCA_FLOWER_MAX, tca[TCA_OPTIONS],
+			       fl_policy, NULL);
 	if (err < 0)
 		goto errout_tb;
 
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index 9dc63d54e167..996209083c6b 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -250,7 +250,7 @@ static int fw_change(struct net *net, struct sk_buff *in_skb,
 	if (!opt)
 		return handle ? -EINVAL : 0; /* Succeed if it is old method. */
 
-	err = nla_parse_nested(tb, TCA_FW_MAX, opt, fw_policy);
+	err = nla_parse_nested(tb, TCA_FW_MAX, opt, fw_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
index 224eb2c14346..0dbcca62aa6a 100644
--- a/net/sched/cls_matchall.c
+++ b/net/sched/cls_matchall.c
@@ -161,8 +161,8 @@ static int mall_change(struct net *net, struct sk_buff *in_skb,
 	if (head)
 		return -EEXIST;
 
-	err = nla_parse_nested(tb, TCA_MATCHALL_MAX,
-			       tca[TCA_OPTIONS], mall_policy);
+	err = nla_parse_nested(tb, TCA_MATCHALL_MAX, tca[TCA_OPTIONS],
+			       mall_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index 455fc8f83d0a..a371075c1d7a 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -489,7 +489,7 @@ static int route4_change(struct net *net, struct sk_buff *in_skb,
 	if (opt == NULL)
 		return handle ? -EINVAL : 0;
 
-	err = nla_parse_nested(tb, TCA_ROUTE4_MAX, opt, route4_policy);
+	err = nla_parse_nested(tb, TCA_ROUTE4_MAX, opt, route4_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index 322438fb3ffc..d7f2923e6ebd 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -484,7 +484,7 @@ static int rsvp_change(struct net *net, struct sk_buff *in_skb,
 	if (opt == NULL)
 		return handle ? -EINVAL : 0;
 
-	err = nla_parse_nested(tb, TCA_RSVP_MAX, opt, rsvp_policy);
+	err = nla_parse_nested(tb, TCA_RSVP_MAX, opt, rsvp_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index 0751245a6ace..2ab001361457 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -482,7 +482,7 @@ tcindex_change(struct net *net, struct sk_buff *in_skb,
 	if (!opt)
 		return 0;
 
-	err = nla_parse_nested(tb, TCA_TCINDEX_MAX, opt, tcindex_policy);
+	err = nla_parse_nested(tb, TCA_TCINDEX_MAX, opt, tcindex_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 4dbe0c680fe6..9e2f330ac80f 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -860,7 +860,7 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 	if (opt == NULL)
 		return handle ? -EINVAL : 0;
 
-	err = nla_parse_nested(tb, TCA_U32_MAX, opt, u32_policy);
+	err = nla_parse_nested(tb, TCA_U32_MAX, opt, u32_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index ae7e4f5b348b..eb0e9bab54c1 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -912,7 +912,7 @@ static int em_meta_change(struct net *net, void *data, int len,
 	struct tcf_meta_hdr *hdr;
 	struct meta_match *meta = NULL;
 
-	err = nla_parse(tb, TCA_EM_META_MAX, data, len, meta_policy);
+	err = nla_parse(tb, TCA_EM_META_MAX, data, len, meta_policy, NULL);
 	if (err < 0)
 		goto errout;
 
diff --git a/net/sched/ematch.c b/net/sched/ematch.c
index fbb7ebfc58c6..03b677bc0700 100644
--- a/net/sched/ematch.c
+++ b/net/sched/ematch.c
@@ -314,7 +314,7 @@ int tcf_em_tree_validate(struct tcf_proto *tp, struct nlattr *nla,
 	if (!nla)
 		return 0;
 
-	err = nla_parse_nested(tb, TCA_EMATCH_TREE_MAX, nla, em_policy);
+	err = nla_parse_nested(tb, TCA_EMATCH_TREE_MAX, nla, em_policy, NULL);
 	if (err < 0)
 		goto errout;
 
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 62567bfe52c7..fcb5ae581c04 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -457,7 +457,7 @@ static struct qdisc_size_table *qdisc_get_stab(struct nlattr *opt)
 	u16 *tab = NULL;
 	int err;
 
-	err = nla_parse_nested(tb, TCA_STAB_MAX, opt, stab_policy);
+	err = nla_parse_nested(tb, TCA_STAB_MAX, opt, stab_policy, NULL);
 	if (err < 0)
 		return ERR_PTR(err);
 	if (!tb[TCA_STAB_BASE])
@@ -1131,7 +1131,7 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n)
 	    !netlink_ns_capable(skb, net->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
-	err = nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL);
+	err = nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL, NULL);
 	if (err < 0)
 		return err;
 
@@ -1200,7 +1200,7 @@ static int tc_modify_qdisc(struct sk_buff *skb, struct nlmsghdr *n)
 
 replay:
 	/* Reinit, just in case something touches this. */
-	err = nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL);
+	err = nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL, NULL);
 	if (err < 0)
 		return err;
 
@@ -1515,7 +1515,7 @@ static int tc_dump_qdisc(struct sk_buff *skb, struct netlink_callback *cb)
 	idx = 0;
 	ASSERT_RTNL();
 
-	err = nlmsg_parse(nlh, sizeof(*tcm), tca, TCA_MAX, NULL);
+	err = nlmsg_parse(nlh, sizeof(*tcm), tca, TCA_MAX, NULL, NULL);
 	if (err < 0)
 		return err;
 
@@ -1577,7 +1577,7 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n)
 	    !netlink_ns_capable(skb, net->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
-	err = nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL);
+	err = nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 2209c2ddacbf..40cbceed4de8 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -214,7 +214,7 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 	if (opt == NULL)
 		return -EINVAL;
 
-	error = nla_parse_nested(tb, TCA_ATM_MAX, opt, atm_policy);
+	error = nla_parse_nested(tb, TCA_ATM_MAX, opt, atm_policy, NULL);
 	if (error < 0)
 		return error;
 
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index cf93e5ff3d63..7415859fd4c3 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1137,7 +1137,7 @@ static int cbq_init(struct Qdisc *sch, struct nlattr *opt)
 	struct tc_ratespec *r;
 	int err;
 
-	err = nla_parse_nested(tb, TCA_CBQ_MAX, opt, cbq_policy);
+	err = nla_parse_nested(tb, TCA_CBQ_MAX, opt, cbq_policy, NULL);
 	if (err < 0)
 		return err;
 
@@ -1474,7 +1474,7 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 	if (opt == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_CBQ_MAX, opt, cbq_policy);
+	err = nla_parse_nested(tb, TCA_CBQ_MAX, opt, cbq_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index 593183a5b5b5..d00f4c7c2f3a 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -357,7 +357,7 @@ static int choke_change(struct Qdisc *sch, struct nlattr *opt)
 	if (opt == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_CHOKE_MAX, opt, choke_policy);
+	err = nla_parse_nested(tb, TCA_CHOKE_MAX, opt, choke_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/sch_codel.c b/net/sched/sch_codel.c
index 5bfa79ee657c..c518a1efcb9d 100644
--- a/net/sched/sch_codel.c
+++ b/net/sched/sch_codel.c
@@ -140,7 +140,7 @@ static int codel_change(struct Qdisc *sch, struct nlattr *opt)
 	if (!opt)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_CODEL_MAX, opt, codel_policy);
+	err = nla_parse_nested(tb, TCA_CODEL_MAX, opt, codel_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 9fe67e257dfa..58a8c32eab23 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -76,7 +76,7 @@ static int drr_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	if (!opt)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_DRR_MAX, opt, drr_policy);
+	err = nla_parse_nested(tb, TCA_DRR_MAX, opt, drr_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index cfa1f2cdbaf7..1c0f877f673a 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -129,7 +129,7 @@ static int dsmark_change(struct Qdisc *sch, u32 classid, u32 parent,
 	if (!opt)
 		goto errout;
 
-	err = nla_parse_nested(tb, TCA_DSMARK_MAX, opt, dsmark_policy);
+	err = nla_parse_nested(tb, TCA_DSMARK_MAX, opt, dsmark_policy, NULL);
 	if (err < 0)
 		goto errout;
 
@@ -342,7 +342,7 @@ static int dsmark_init(struct Qdisc *sch, struct nlattr *opt)
 	if (!opt)
 		goto errout;
 
-	err = nla_parse_nested(tb, TCA_DSMARK_MAX, opt, dsmark_policy);
+	err = nla_parse_nested(tb, TCA_DSMARK_MAX, opt, dsmark_policy, NULL);
 	if (err < 0)
 		goto errout;
 
diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index a4f738ac7728..da4f67bda0ee 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -698,7 +698,7 @@ static int fq_change(struct Qdisc *sch, struct nlattr *opt)
 	if (!opt)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_FQ_MAX, opt, fq_policy);
+	err = nla_parse_nested(tb, TCA_FQ_MAX, opt, fq_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 097bbe9857a5..18bbb5476c83 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -383,7 +383,8 @@ static int fq_codel_change(struct Qdisc *sch, struct nlattr *opt)
 	if (!opt)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_FQ_CODEL_MAX, opt, fq_codel_policy);
+	err = nla_parse_nested(tb, TCA_FQ_CODEL_MAX, opt, fq_codel_policy,
+			       NULL);
 	if (err < 0)
 		return err;
 	if (tb[TCA_FQ_CODEL_FLOWS]) {
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index c78a093c551a..17c7130454bd 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -401,7 +401,7 @@ static int gred_change(struct Qdisc *sch, struct nlattr *opt)
 	if (opt == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_GRED_MAX, opt, gred_policy);
+	err = nla_parse_nested(tb, TCA_GRED_MAX, opt, gred_policy, NULL);
 	if (err < 0)
 		return err;
 
@@ -470,7 +470,7 @@ static int gred_init(struct Qdisc *sch, struct nlattr *opt)
 	if (opt == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_GRED_MAX, opt, gred_policy);
+	err = nla_parse_nested(tb, TCA_GRED_MAX, opt, gred_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 0198c6cdda49..5cb82f6c1b06 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -957,7 +957,7 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	if (opt == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_HFSC_MAX, opt, hfsc_policy);
+	err = nla_parse_nested(tb, TCA_HFSC_MAX, opt, hfsc_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
index 2fae8b5f1b80..c19d346e6c5a 100644
--- a/net/sched/sch_hhf.c
+++ b/net/sched/sch_hhf.c
@@ -529,7 +529,7 @@ static int hhf_change(struct Qdisc *sch, struct nlattr *opt)
 	if (!opt)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_HHF_MAX, opt, hhf_policy);
+	err = nla_parse_nested(tb, TCA_HHF_MAX, opt, hhf_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 95867033542e..570ef3b0c09b 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1017,7 +1017,7 @@ static int htb_init(struct Qdisc *sch, struct nlattr *opt)
 	if (!opt)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_HTB_MAX, opt, htb_policy);
+	err = nla_parse_nested(tb, TCA_HTB_MAX, opt, htb_policy, NULL);
 	if (err < 0)
 		return err;
 
@@ -1342,7 +1342,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 	if (!opt)
 		goto failure;
 
-	err = nla_parse_nested(tb, TCA_HTB_MAX, opt, htb_policy);
+	err = nla_parse_nested(tb, TCA_HTB_MAX, opt, htb_policy, NULL);
 	if (err < 0)
 		goto failure;
 
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 94b4928ad413..f0ce4780f395 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -843,7 +843,7 @@ static int parse_attr(struct nlattr *tb[], int maxtype, struct nlattr *nla,
 
 	if (nested_len >= nla_attr_size(0))
 		return nla_parse(tb, maxtype, nla_data(nla) + NLA_ALIGN(len),
-				 nested_len, policy);
+				 nested_len, policy, NULL);
 
 	memset(tb, 0, sizeof(struct nlattr *) * (maxtype + 1));
 	return 0;
diff --git a/net/sched/sch_pie.c b/net/sched/sch_pie.c
index 5c3a99d6aa82..6c2791d6102d 100644
--- a/net/sched/sch_pie.c
+++ b/net/sched/sch_pie.c
@@ -190,7 +190,7 @@ static int pie_change(struct Qdisc *sch, struct nlattr *opt)
 	if (!opt)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_PIE_MAX, opt, pie_policy);
+	err = nla_parse_nested(tb, TCA_PIE_MAX, opt, pie_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 6c85f3e9239b..041eba3006cc 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -418,7 +418,8 @@ static int qfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 		return -EINVAL;
 	}
 
-	err = nla_parse_nested(tb, TCA_QFQ_MAX, tca[TCA_OPTIONS], qfq_policy);
+	err = nla_parse_nested(tb, TCA_QFQ_MAX, tca[TCA_OPTIONS], qfq_policy,
+			       NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 799ea6dd69b2..11292adce412 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -173,7 +173,7 @@ static int red_change(struct Qdisc *sch, struct nlattr *opt)
 	if (opt == NULL)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_RED_MAX, opt, red_policy);
+	err = nla_parse_nested(tb, TCA_RED_MAX, opt, red_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index ae862f172c94..0f777273ba29 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -495,7 +495,7 @@ static int sfb_change(struct Qdisc *sch, struct nlattr *opt)
 	int err;
 
 	if (opt) {
-		err = nla_parse_nested(tb, TCA_SFB_MAX, opt, sfb_policy);
+		err = nla_parse_nested(tb, TCA_SFB_MAX, opt, sfb_policy, NULL);
 		if (err < 0)
 			return -EINVAL;
 
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 9850126129a3..b2e4b6ad241a 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -315,7 +315,7 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 	s64 buffer, mtu;
 	u64 rate64 = 0, prate64 = 0;
 
-	err = nla_parse_nested(tb, TCA_TBF_MAX, opt, tbf_policy);
+	err = nla_parse_nested(tb, TCA_TBF_MAX, opt, tbf_policy, NULL);
 	if (err < 0)
 		return err;
 
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 017801f9dbaa..8d40a7d31c99 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -826,7 +826,7 @@ static int switchdev_port_br_setlink_protinfo(struct net_device *dev,
 	int err;
 
 	err = nla_validate_nested(protinfo, IFLA_BRPORT_MAX,
-				  switchdev_port_bridge_policy);
+				  switchdev_port_bridge_policy, NULL);
 	if (err)
 		return err;
 
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 33a5bdfbef76..9b5c45f48f60 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -802,7 +802,7 @@ int tipc_nl_bearer_get(struct sk_buff *skb, struct genl_info *info)
 
 	err = nla_parse_nested(attrs, TIPC_NLA_BEARER_MAX,
 			       info->attrs[TIPC_NLA_BEARER],
-			       tipc_nl_bearer_policy);
+			       tipc_nl_bearer_policy, NULL);
 	if (err)
 		return err;
 
@@ -851,7 +851,7 @@ int tipc_nl_bearer_disable(struct sk_buff *skb, struct genl_info *info)
 
 	err = nla_parse_nested(attrs, TIPC_NLA_BEARER_MAX,
 			       info->attrs[TIPC_NLA_BEARER],
-			       tipc_nl_bearer_policy);
+			       tipc_nl_bearer_policy, NULL);
 	if (err)
 		return err;
 
@@ -891,7 +891,7 @@ int tipc_nl_bearer_enable(struct sk_buff *skb, struct genl_info *info)
 
 	err = nla_parse_nested(attrs, TIPC_NLA_BEARER_MAX,
 			       info->attrs[TIPC_NLA_BEARER],
-			       tipc_nl_bearer_policy);
+			       tipc_nl_bearer_policy, NULL);
 	if (err)
 		return err;
 
@@ -939,7 +939,7 @@ int tipc_nl_bearer_add(struct sk_buff *skb, struct genl_info *info)
 
 	err = nla_parse_nested(attrs, TIPC_NLA_BEARER_MAX,
 			       info->attrs[TIPC_NLA_BEARER],
-			       tipc_nl_bearer_policy);
+			       tipc_nl_bearer_policy, NULL);
 	if (err)
 		return err;
 
@@ -982,7 +982,7 @@ int tipc_nl_bearer_set(struct sk_buff *skb, struct genl_info *info)
 
 	err = nla_parse_nested(attrs, TIPC_NLA_BEARER_MAX,
 			       info->attrs[TIPC_NLA_BEARER],
-			       tipc_nl_bearer_policy);
+			       tipc_nl_bearer_policy, NULL);
 	if (err)
 		return err;
 
@@ -1104,7 +1104,7 @@ int tipc_nl_media_get(struct sk_buff *skb, struct genl_info *info)
 
 	err = nla_parse_nested(attrs, TIPC_NLA_MEDIA_MAX,
 			       info->attrs[TIPC_NLA_MEDIA],
-			       tipc_nl_media_policy);
+			       tipc_nl_media_policy, NULL);
 	if (err)
 		return err;
 
@@ -1152,7 +1152,7 @@ int tipc_nl_media_set(struct sk_buff *skb, struct genl_info *info)
 
 	err = nla_parse_nested(attrs, TIPC_NLA_MEDIA_MAX,
 			       info->attrs[TIPC_NLA_MEDIA],
-			       tipc_nl_media_policy);
+			       tipc_nl_media_policy, NULL);
 
 	if (!attrs[TIPC_NLA_MEDIA_NAME])
 		return -EINVAL;
diff --git a/net/tipc/link.c b/net/tipc/link.c
index ddd2dd6f77aa..60820dc35a08 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1827,7 +1827,7 @@ int tipc_nl_parse_link_prop(struct nlattr *prop, struct nlattr *props[])
 	int err;
 
 	err = nla_parse_nested(props, TIPC_NLA_PROP_MAX, prop,
-			       tipc_nl_prop_policy);
+			       tipc_nl_prop_policy, NULL);
 	if (err)
 		return err;
 
diff --git a/net/tipc/net.c b/net/tipc/net.c
index ab8a2d5d1e32..836da66cd852 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -211,8 +211,8 @@ int tipc_nl_net_set(struct sk_buff *skb, struct genl_info *info)
 		return -EINVAL;
 
 	err = nla_parse_nested(attrs, TIPC_NLA_NET_MAX,
-			       info->attrs[TIPC_NLA_NET],
-			       tipc_nl_net_policy);
+			       info->attrs[TIPC_NLA_NET], tipc_nl_net_policy,
+			       NULL);
 	if (err)
 		return err;
 
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index 26ca8dd64ded..b76f13f6fea1 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -268,7 +268,8 @@ int tipc_nlmsg_parse(const struct nlmsghdr *nlh, struct nlattr ***attr)
 	if (!*attr)
 		return -EOPNOTSUPP;
 
-	return nlmsg_parse(nlh, GENL_HDRLEN, *attr, maxattr, tipc_nl_policy);
+	return nlmsg_parse(nlh, GENL_HDRLEN, *attr, maxattr, tipc_nl_policy,
+			   NULL);
 }
 
 int __init tipc_netlink_start(void)
diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
index e1ae8a8a2b8e..9bfe886ab330 100644
--- a/net/tipc/netlink_compat.c
+++ b/net/tipc/netlink_compat.c
@@ -296,7 +296,7 @@ static int __tipc_nl_compat_doit(struct tipc_nl_compat_cmd_doit *cmd,
 
 	err = nla_parse(attrbuf, tipc_genl_family.maxattr,
 			(const struct nlattr *)trans_buf->data,
-			trans_buf->len, NULL);
+			trans_buf->len, NULL, NULL);
 	if (err)
 		goto parse_out;
 
@@ -352,7 +352,7 @@ static int tipc_nl_compat_bearer_dump(struct tipc_nl_compat_msg *msg,
 		return -EINVAL;
 
 	err = nla_parse_nested(bearer, TIPC_NLA_BEARER_MAX,
-			       attrs[TIPC_NLA_BEARER], NULL);
+			       attrs[TIPC_NLA_BEARER], NULL, NULL);
 	if (err)
 		return err;
 
@@ -472,7 +472,7 @@ static int tipc_nl_compat_link_stat_dump(struct tipc_nl_compat_msg *msg,
 		return -EINVAL;
 
 	err = nla_parse_nested(link, TIPC_NLA_LINK_MAX, attrs[TIPC_NLA_LINK],
-			       NULL);
+			       NULL, NULL);
 	if (err)
 		return err;
 
@@ -480,7 +480,7 @@ static int tipc_nl_compat_link_stat_dump(struct tipc_nl_compat_msg *msg,
 		return -EINVAL;
 
 	err = nla_parse_nested(prop, TIPC_NLA_PROP_MAX,
-			       link[TIPC_NLA_LINK_PROP], NULL);
+			       link[TIPC_NLA_LINK_PROP], NULL, NULL);
 	if (err)
 		return err;
 
@@ -488,7 +488,7 @@ static int tipc_nl_compat_link_stat_dump(struct tipc_nl_compat_msg *msg,
 		return -EINVAL;
 
 	err = nla_parse_nested(stats, TIPC_NLA_STATS_MAX,
-			       link[TIPC_NLA_LINK_STATS], NULL);
+			       link[TIPC_NLA_LINK_STATS], NULL, NULL);
 	if (err)
 		return err;
 
@@ -598,7 +598,7 @@ static int tipc_nl_compat_link_dump(struct tipc_nl_compat_msg *msg,
 		return -EINVAL;
 
 	err = nla_parse_nested(link, TIPC_NLA_LINK_MAX, attrs[TIPC_NLA_LINK],
-			       NULL);
+			       NULL, NULL);
 	if (err)
 		return err;
 
@@ -795,7 +795,7 @@ static int tipc_nl_compat_name_table_dump(struct tipc_nl_compat_msg *msg,
 		return -EINVAL;
 
 	err = nla_parse_nested(nt, TIPC_NLA_NAME_TABLE_MAX,
-			       attrs[TIPC_NLA_NAME_TABLE], NULL);
+			       attrs[TIPC_NLA_NAME_TABLE], NULL, NULL);
 	if (err)
 		return err;
 
@@ -803,7 +803,7 @@ static int tipc_nl_compat_name_table_dump(struct tipc_nl_compat_msg *msg,
 		return -EINVAL;
 
 	err = nla_parse_nested(publ, TIPC_NLA_PUBL_MAX,
-			       nt[TIPC_NLA_NAME_TABLE_PUBL], NULL);
+			       nt[TIPC_NLA_NAME_TABLE_PUBL], NULL, NULL);
 	if (err)
 		return err;
 
@@ -863,7 +863,7 @@ static int __tipc_nl_compat_publ_dump(struct tipc_nl_compat_msg *msg,
 		return -EINVAL;
 
 	err = nla_parse_nested(publ, TIPC_NLA_PUBL_MAX, attrs[TIPC_NLA_PUBL],
-			       NULL);
+			       NULL, NULL);
 	if (err)
 		return err;
 
@@ -929,7 +929,7 @@ static int tipc_nl_compat_sk_dump(struct tipc_nl_compat_msg *msg,
 		return -EINVAL;
 
 	err = nla_parse_nested(sock, TIPC_NLA_SOCK_MAX, attrs[TIPC_NLA_SOCK],
-			       NULL);
+			       NULL, NULL);
 	if (err)
 		return err;
 
@@ -940,8 +940,8 @@ static int tipc_nl_compat_sk_dump(struct tipc_nl_compat_msg *msg,
 		u32 node;
 		struct nlattr *con[TIPC_NLA_CON_MAX + 1];
 
-		nla_parse_nested(con, TIPC_NLA_CON_MAX, sock[TIPC_NLA_SOCK_CON],
-				 NULL);
+		nla_parse_nested(con, TIPC_NLA_CON_MAX,
+				 sock[TIPC_NLA_SOCK_CON], NULL, NULL);
 
 		node = nla_get_u32(con[TIPC_NLA_CON_NODE]);
 		tipc_tlv_sprintf(msg->rep, "  connected to <%u.%u.%u:%u>",
@@ -977,8 +977,8 @@ static int tipc_nl_compat_media_dump(struct tipc_nl_compat_msg *msg,
 	if (!attrs[TIPC_NLA_MEDIA])
 		return -EINVAL;
 
-	err = nla_parse_nested(media, TIPC_NLA_MEDIA_MAX, attrs[TIPC_NLA_MEDIA],
-			       NULL);
+	err = nla_parse_nested(media, TIPC_NLA_MEDIA_MAX,
+			       attrs[TIPC_NLA_MEDIA], NULL, NULL);
 	if (err)
 		return err;
 
@@ -998,7 +998,7 @@ static int tipc_nl_compat_node_dump(struct tipc_nl_compat_msg *msg,
 		return -EINVAL;
 
 	err = nla_parse_nested(node, TIPC_NLA_NODE_MAX, attrs[TIPC_NLA_NODE],
-			       NULL);
+			       NULL, NULL);
 	if (err)
 		return err;
 
@@ -1045,7 +1045,7 @@ static int tipc_nl_compat_net_dump(struct tipc_nl_compat_msg *msg,
 		return -EINVAL;
 
 	err = nla_parse_nested(net, TIPC_NLA_NET_MAX, attrs[TIPC_NLA_NET],
-			       NULL);
+			       NULL, NULL);
 	if (err)
 		return err;
 
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 4512e83652b1..1dcde24c7053 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -1607,8 +1607,8 @@ int tipc_nl_peer_rm(struct sk_buff *skb, struct genl_info *info)
 		return -EINVAL;
 
 	err = nla_parse_nested(attrs, TIPC_NLA_NET_MAX,
-			       info->attrs[TIPC_NLA_NET],
-			       tipc_nl_net_policy);
+			       info->attrs[TIPC_NLA_NET], tipc_nl_net_policy,
+			       NULL);
 	if (err)
 		return err;
 
@@ -1774,7 +1774,7 @@ int tipc_nl_node_set_link(struct sk_buff *skb, struct genl_info *info)
 
 	err = nla_parse_nested(attrs, TIPC_NLA_LINK_MAX,
 			       info->attrs[TIPC_NLA_LINK],
-			       tipc_nl_link_policy);
+			       tipc_nl_link_policy, NULL);
 	if (err)
 		return err;
 
@@ -1902,7 +1902,7 @@ int tipc_nl_node_reset_link_stats(struct sk_buff *skb, struct genl_info *info)
 
 	err = nla_parse_nested(attrs, TIPC_NLA_LINK_MAX,
 			       info->attrs[TIPC_NLA_LINK],
-			       tipc_nl_link_policy);
+			       tipc_nl_link_policy, NULL);
 	if (err)
 		return err;
 
@@ -2042,7 +2042,7 @@ int tipc_nl_node_set_monitor(struct sk_buff *skb, struct genl_info *info)
 
 	err = nla_parse_nested(attrs, TIPC_NLA_MON_MAX,
 			       info->attrs[TIPC_NLA_MON],
-			       tipc_nl_monitor_policy);
+			       tipc_nl_monitor_policy, NULL);
 	if (err)
 		return err;
 
@@ -2163,7 +2163,7 @@ int tipc_nl_node_dump_monitor_peer(struct sk_buff *skb,
 
 		err = nla_parse_nested(mon, TIPC_NLA_MON_MAX,
 				       attrs[TIPC_NLA_MON],
-				       tipc_nl_monitor_policy);
+				       tipc_nl_monitor_policy, NULL);
 		if (err)
 			return err;
 
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 15f6ce7bf868..740100abeec3 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -2866,7 +2866,7 @@ int tipc_nl_publ_dump(struct sk_buff *skb, struct netlink_callback *cb)
 
 		err = nla_parse_nested(sock, TIPC_NLA_SOCK_MAX,
 				       attrs[TIPC_NLA_SOCK],
-				       tipc_nl_sock_policy);
+				       tipc_nl_sock_policy, NULL);
 		if (err)
 			return err;
 
diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
index 46061cf48cd1..ecca64fc6a6f 100644
--- a/net/tipc/udp_media.c
+++ b/net/tipc/udp_media.c
@@ -457,7 +457,7 @@ int tipc_udp_nl_dump_remoteip(struct sk_buff *skb, struct netlink_callback *cb)
 
 		err = nla_parse_nested(battrs, TIPC_NLA_BEARER_MAX,
 				       attrs[TIPC_NLA_BEARER],
-				       tipc_nl_bearer_policy);
+				       tipc_nl_bearer_policy, NULL);
 		if (err)
 			return err;
 
@@ -609,7 +609,8 @@ int tipc_udp_nl_bearer_add(struct tipc_bearer *b, struct nlattr *attr)
 	struct nlattr *opts[TIPC_NLA_UDP_MAX + 1];
 	struct udp_media_addr *dst;
 
-	if (nla_parse_nested(opts, TIPC_NLA_UDP_MAX, attr, tipc_nl_udp_policy))
+	if (nla_parse_nested(opts, TIPC_NLA_UDP_MAX, attr,
+			     tipc_nl_udp_policy, NULL))
 		return -EINVAL;
 
 	if (!opts[TIPC_NLA_UDP_REMOTE])
@@ -662,7 +663,7 @@ static int tipc_udp_enable(struct net *net, struct tipc_bearer *b,
 
 	if (nla_parse_nested(opts, TIPC_NLA_UDP_MAX,
 			     attrs[TIPC_NLA_BEARER_UDP_OPTS],
-			     tipc_nl_udp_policy))
+			     tipc_nl_udp_policy, NULL))
 		goto err;
 
 	if (!opts[TIPC_NLA_UDP_LOCAL] || !opts[TIPC_NLA_UDP_REMOTE]) {
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 2312dc2ffdb9..e7594a3a0ab6 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -548,7 +548,7 @@ static int nl80211_prepare_wdev_dump(struct sk_buff *skb,
 	if (!cb->args[0]) {
 		err = nlmsg_parse(cb->nlh, GENL_HDRLEN + nl80211_fam.hdrsize,
 				  genl_family_attrbuf(&nl80211_fam),
-				  nl80211_fam.maxattr, nl80211_policy);
+				  nl80211_fam.maxattr, nl80211_policy, NULL);
 		if (err)
 			return err;
 
@@ -719,7 +719,7 @@ static int nl80211_parse_key_new(struct nlattr *key, struct key_parse *k)
 {
 	struct nlattr *tb[NL80211_KEY_MAX + 1];
 	int err = nla_parse_nested(tb, NL80211_KEY_MAX, key,
-				   nl80211_key_policy);
+				   nl80211_key_policy, NULL);
 	if (err)
 		return err;
 
@@ -760,7 +760,7 @@ static int nl80211_parse_key_new(struct nlattr *key, struct key_parse *k)
 
 		err = nla_parse_nested(kdt, NUM_NL80211_KEY_DEFAULT_TYPES - 1,
 				       tb[NL80211_KEY_DEFAULT_TYPES],
-				       nl80211_key_default_policy);
+				       nl80211_key_default_policy, NULL);
 		if (err)
 			return err;
 
@@ -807,10 +807,10 @@ static int nl80211_parse_key_old(struct genl_info *info, struct key_parse *k)
 
 	if (info->attrs[NL80211_ATTR_KEY_DEFAULT_TYPES]) {
 		struct nlattr *kdt[NUM_NL80211_KEY_DEFAULT_TYPES];
-		int err = nla_parse_nested(
-				kdt, NUM_NL80211_KEY_DEFAULT_TYPES - 1,
-				info->attrs[NL80211_ATTR_KEY_DEFAULT_TYPES],
-				nl80211_key_default_policy);
+		int err = nla_parse_nested(kdt,
+					   NUM_NL80211_KEY_DEFAULT_TYPES - 1,
+					   info->attrs[NL80211_ATTR_KEY_DEFAULT_TYPES],
+					   nl80211_key_default_policy, NULL);
 		if (err)
 			return err;
 
@@ -1892,8 +1892,8 @@ static int nl80211_dump_wiphy_parse(struct sk_buff *skb,
 				    struct nl80211_dump_wiphy_state *state)
 {
 	struct nlattr **tb = genl_family_attrbuf(&nl80211_fam);
-	int ret = nlmsg_parse(cb->nlh, GENL_HDRLEN + nl80211_fam.hdrsize,
-			      tb, nl80211_fam.maxattr, nl80211_policy);
+	int ret = nlmsg_parse(cb->nlh, GENL_HDRLEN + nl80211_fam.hdrsize, tb,
+			      nl80211_fam.maxattr, nl80211_policy, NULL);
 	/* ignore parse errors for backward compatibility */
 	if (ret)
 		return 0;
@@ -2308,7 +2308,7 @@ static int nl80211_set_wiphy(struct sk_buff *skb, struct genl_info *info)
 				    rem_txq_params) {
 			result = nla_parse_nested(tb, NL80211_TXQ_ATTR_MAX,
 						  nl_txq_params,
-						  txq_params_policy);
+						  txq_params_policy, NULL);
 			if (result)
 				return result;
 			result = parse_txq_params(tb, &txq_params);
@@ -2695,8 +2695,8 @@ static int parse_monitor_flags(struct nlattr *nla, u32 *mntrflags)
 	if (!nla)
 		return -EINVAL;
 
-	if (nla_parse_nested(flags, NL80211_MNTR_FLAG_MAX,
-			     nla, mntr_flags_policy))
+	if (nla_parse_nested(flags, NL80211_MNTR_FLAG_MAX, nla,
+			     mntr_flags_policy, NULL))
 		return -EINVAL;
 
 	for (flag = 1; flag <= NL80211_MNTR_FLAG_MAX; flag++)
@@ -3561,7 +3561,7 @@ static int nl80211_parse_tx_bitrate_mask(struct genl_info *info,
 		if (sband == NULL)
 			return -EINVAL;
 		err = nla_parse_nested(tb, NL80211_TXRATE_MAX, tx_rates,
-				       nl80211_txattr_policy);
+				       nl80211_txattr_policy, NULL);
 		if (err)
 			return err;
 		if (tb[NL80211_TXRATE_LEGACY]) {
@@ -4100,8 +4100,8 @@ static int parse_station_flags(struct genl_info *info,
 	if (!nla)
 		return 0;
 
-	if (nla_parse_nested(flags, NL80211_STA_FLAG_MAX,
-			     nla, sta_flags_policy))
+	if (nla_parse_nested(flags, NL80211_STA_FLAG_MAX, nla,
+			     sta_flags_policy, NULL))
 		return -EINVAL;
 
 	/*
@@ -4728,7 +4728,7 @@ static int nl80211_parse_sta_wme(struct genl_info *info,
 
 	nla = info->attrs[NL80211_ATTR_STA_WME];
 	err = nla_parse_nested(tb, NL80211_STA_WME_MAX, nla,
-			       nl80211_sta_wme_policy);
+			       nl80211_sta_wme_policy, NULL);
 	if (err)
 		return err;
 
@@ -5853,7 +5853,7 @@ do {									    \
 		return -EINVAL;
 	if (nla_parse_nested(tb, NL80211_MESHCONF_ATTR_MAX,
 			     info->attrs[NL80211_ATTR_MESH_CONFIG],
-			     nl80211_meshconf_params_policy))
+			     nl80211_meshconf_params_policy, NULL))
 		return -EINVAL;
 
 	/* This makes sure that there aren't more than 32 mesh config
@@ -6002,7 +6002,7 @@ static int nl80211_parse_mesh_setup(struct genl_info *info,
 		return -EINVAL;
 	if (nla_parse_nested(tb, NL80211_MESH_SETUP_ATTR_MAX,
 			     info->attrs[NL80211_ATTR_MESH_SETUP],
-			     nl80211_mesh_setup_params_policy))
+			     nl80211_mesh_setup_params_policy, NULL))
 		return -EINVAL;
 
 	if (tb[NL80211_MESH_SETUP_ENABLE_VENDOR_SYNC])
@@ -6393,7 +6393,7 @@ static int nl80211_set_reg(struct sk_buff *skb, struct genl_info *info)
 	nla_for_each_nested(nl_reg_rule, info->attrs[NL80211_ATTR_REG_RULES],
 			    rem_reg_rules) {
 		r = nla_parse_nested(tb, NL80211_REG_RULE_ATTR_MAX,
-				     nl_reg_rule, reg_rule_policy);
+				     nl_reg_rule, reg_rule_policy, NULL);
 		if (r)
 			goto bad_reg;
 		r = parse_reg_rule(tb, &rd->reg_rules[rule_idx]);
@@ -6461,7 +6461,7 @@ static int parse_bss_select(struct nlattr *nla, struct wiphy *wiphy,
 		return -EINVAL;
 
 	err = nla_parse_nested(attr, NL80211_BSS_SELECT_ATTR_MAX, nest,
-			       nl80211_bss_select_policy);
+			       nl80211_bss_select_policy, NULL);
 	if (err)
 		return err;
 
@@ -6862,7 +6862,7 @@ nl80211_parse_sched_scan_plans(struct wiphy *wiphy, int n_plans,
 			return -EINVAL;
 
 		err = nla_parse_nested(plan, NL80211_SCHED_SCAN_PLAN_MAX,
-				       attr, nl80211_plan_policy);
+				       attr, nl80211_plan_policy, NULL);
 		if (err)
 			return err;
 
@@ -6953,7 +6953,8 @@ nl80211_parse_sched_scan(struct wiphy *wiphy, struct wireless_dev *wdev,
 
 			err = nla_parse_nested(tb,
 					       NL80211_SCHED_SCAN_MATCH_ATTR_MAX,
-					       attr, nl80211_match_policy);
+					       attr, nl80211_match_policy,
+					       NULL);
 			if (err)
 				return ERR_PTR(err);
 			/* add other standalone attributes here */
@@ -7132,7 +7133,8 @@ nl80211_parse_sched_scan(struct wiphy *wiphy, struct wireless_dev *wdev,
 
 			err = nla_parse_nested(tb,
 					       NL80211_SCHED_SCAN_MATCH_ATTR_MAX,
-					       attr, nl80211_match_policy);
+					       attr, nl80211_match_policy,
+					       NULL);
 			if (err)
 				goto out_free;
 			ssid = tb[NL80211_SCHED_SCAN_MATCH_ATTR_SSID];
@@ -7433,7 +7435,7 @@ static int nl80211_channel_switch(struct sk_buff *skb, struct genl_info *info)
 
 	err = nla_parse_nested(csa_attrs, NL80211_ATTR_MAX,
 			       info->attrs[NL80211_ATTR_CSA_IES],
-			       nl80211_policy);
+			       nl80211_policy, NULL);
 	if (err)
 		return err;
 
@@ -8639,7 +8641,8 @@ static int nl80211_testmode_dump(struct sk_buff *skb,
 		struct nlattr **attrbuf = genl_family_attrbuf(&nl80211_fam);
 
 		err = nlmsg_parse(cb->nlh, GENL_HDRLEN + nl80211_fam.hdrsize,
-				  attrbuf, nl80211_fam.maxattr, nl80211_policy);
+				  attrbuf, nl80211_fam.maxattr,
+				  nl80211_policy, NULL);
 		if (err)
 			goto out_err;
 
@@ -9530,7 +9533,7 @@ static int nl80211_set_cqm(struct sk_buff *skb, struct genl_info *info)
 		return -EINVAL;
 
 	err = nla_parse_nested(attrs, NL80211_ATTR_CQM_MAX, cqm,
-			       nl80211_attr_cqm_policy);
+			       nl80211_attr_cqm_policy, NULL);
 	if (err)
 		return err;
 
@@ -9940,7 +9943,7 @@ static int nl80211_parse_wowlan_tcp(struct cfg80211_registered_device *rdev,
 		return -EINVAL;
 
 	err = nla_parse_nested(tb, MAX_NL80211_WOWLAN_TCP, attr,
-			       nl80211_wowlan_tcp_policy);
+			       nl80211_wowlan_tcp_policy, NULL);
 	if (err)
 		return err;
 
@@ -10085,7 +10088,8 @@ static int nl80211_parse_wowlan_nd(struct cfg80211_registered_device *rdev,
 		goto out;
 	}
 
-	err = nla_parse_nested(tb, NL80211_ATTR_MAX, attr, nl80211_policy);
+	err = nla_parse_nested(tb, NL80211_ATTR_MAX, attr, nl80211_policy,
+			       NULL);
 	if (err)
 		goto out;
 
@@ -10122,7 +10126,7 @@ static int nl80211_set_wowlan(struct sk_buff *skb, struct genl_info *info)
 
 	err = nla_parse_nested(tb, MAX_NL80211_WOWLAN_TRIG,
 			       info->attrs[NL80211_ATTR_WOWLAN_TRIGGERS],
-			       nl80211_wowlan_policy);
+			       nl80211_wowlan_policy, NULL);
 	if (err)
 		return err;
 
@@ -10205,7 +10209,7 @@ static int nl80211_set_wowlan(struct sk_buff *skb, struct genl_info *info)
 			u8 *mask_pat;
 
 			nla_parse_nested(pat_tb, MAX_NL80211_PKTPAT, pat,
-					 NULL);
+					 NULL, NULL);
 			err = -EINVAL;
 			if (!pat_tb[NL80211_PKTPAT_MASK] ||
 			    !pat_tb[NL80211_PKTPAT_PATTERN])
@@ -10416,7 +10420,7 @@ static int nl80211_parse_coalesce_rule(struct cfg80211_registered_device *rdev,
 	struct nlattr *pat_tb[NUM_NL80211_PKTPAT];
 
 	err = nla_parse_nested(tb, NL80211_ATTR_COALESCE_RULE_MAX, rule,
-			       nl80211_coalesce_policy);
+			       nl80211_coalesce_policy, NULL);
 	if (err)
 		return err;
 
@@ -10454,7 +10458,7 @@ static int nl80211_parse_coalesce_rule(struct cfg80211_registered_device *rdev,
 			    rem) {
 		u8 *mask_pat;
 
-		nla_parse_nested(pat_tb, MAX_NL80211_PKTPAT, pat, NULL);
+		nla_parse_nested(pat_tb, MAX_NL80211_PKTPAT, pat, NULL, NULL);
 		if (!pat_tb[NL80211_PKTPAT_MASK] ||
 		    !pat_tb[NL80211_PKTPAT_PATTERN])
 			return -EINVAL;
@@ -10575,7 +10579,7 @@ static int nl80211_set_rekey_data(struct sk_buff *skb, struct genl_info *info)
 
 	err = nla_parse_nested(tb, MAX_NL80211_REKEY_DATA,
 			       info->attrs[NL80211_ATTR_REKEY_DATA],
-			       nl80211_rekey_policy);
+			       nl80211_rekey_policy, NULL);
 	if (err)
 		return err;
 
@@ -10892,7 +10896,7 @@ static int nl80211_nan_add_func(struct sk_buff *skb,
 
 	err = nla_parse_nested(tb, NL80211_NAN_FUNC_ATTR_MAX,
 			       info->attrs[NL80211_ATTR_NAN_FUNC],
-			       nl80211_nan_func_policy);
+			       nl80211_nan_func_policy, NULL);
 	if (err)
 		return err;
 
@@ -10989,7 +10993,7 @@ static int nl80211_nan_add_func(struct sk_buff *skb,
 
 		err = nla_parse_nested(srf_tb, NL80211_NAN_SRF_ATTR_MAX,
 				       tb[NL80211_NAN_FUNC_SRF],
-				       nl80211_nan_srf_policy);
+				       nl80211_nan_srf_policy, NULL);
 		if (err)
 			goto out;
 
@@ -11524,8 +11528,8 @@ static int nl80211_prepare_vendor_dump(struct sk_buff *skb,
 		return 0;
 	}
 
-	err = nlmsg_parse(cb->nlh, GENL_HDRLEN + nl80211_fam.hdrsize,
-			  attrbuf, nl80211_fam.maxattr, nl80211_policy);
+	err = nlmsg_parse(cb->nlh, GENL_HDRLEN + nl80211_fam.hdrsize, attrbuf,
+			  nl80211_fam.maxattr, nl80211_policy, NULL);
 	if (err)
 		return err;
 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 1ba8c115a993..0db72dd82c7e 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -932,8 +932,8 @@ static int xfrm_dump_sa(struct sk_buff *skb, struct netlink_callback *cb)
 		u8 proto = 0;
 		int err;
 
-		err = nlmsg_parse(cb->nlh, 0, attrs, XFRMA_MAX,
-				  xfrma_policy);
+		err = nlmsg_parse(cb->nlh, 0, attrs, XFRMA_MAX, xfrma_policy,
+				  NULL);
 		if (err < 0)
 			return err;
 
@@ -2489,7 +2489,7 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	err = nlmsg_parse(nlh, xfrm_msg_min[type], attrs,
 			  link->nla_max ? : XFRMA_MAX,
-			  link->nla_pol ? : xfrma_policy);
+			  link->nla_pol ? : xfrma_policy, NULL);
 	if (err < 0)
 		return err;
 
-- 
2.11.0
