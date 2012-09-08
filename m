From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] netlink: Rename pid to portid to avoid confusion
Date: Fri, 07 Sep 2012 23:12:54 -0700
Message-ID: <87fw6tjb4p.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:53099 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750902Ab2IHGNi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Sep 2012 02:13:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It is a frequent mistake to confuse the netlink port identifier with a
process identifier.  Try to reduce this confusion by renaming fields
that hold port identifiers portid instead of pid.

I have carefully avoided changing the structures exported to
userspace to avoid changing the userspace API.

I have successfully built an allyesconfig kernel with this change.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 crypto/crypto_user.c                        |    4 +-
 drivers/net/team/team.c                     |   38 +++---
 drivers/net/wireless/mac80211_hwsim.c       |   46 ++++----
 drivers/scsi/scsi_transport_iscsi.c         |    4 +-
 drivers/staging/gdm72xx/netlink_k.c         |    2 +-
 fs/dlm/netlink.c                            |    8 +-
 include/linux/netlink.h                     |   14 +-
 include/net/cfg80211.h                      |    2 +-
 include/net/genetlink.h                     |   34 +++---
 include/net/netfilter/nf_conntrack_ecache.h |   32 +++---
 include/net/netlink.h                       |   26 ++--
 include/net/nfc/nfc.h                       |    2 +-
 include/net/xfrm.h                          |    6 +-
 kernel/audit.c                              |   20 ++--
 kernel/taskstats.c                          |    4 +-
 net/bridge/br_fdb.c                         |    6 +-
 net/bridge/br_netlink.c                     |    2 +-
 net/can/gw.c                                |    2 +-
 net/core/fib_rules.c                        |    6 +-
 net/core/neighbour.c                        |    8 +-
 net/core/rtnetlink.c                        |   12 +-
 net/dcb/dcbnl.c                             |   18 ++--
 net/decnet/dn_dev.c                         |    6 +-
 net/decnet/dn_route.c                       |   10 +-
 net/decnet/dn_table.c                       |   12 +-
 net/ieee802154/nl-mac.c                     |    6 +-
 net/ieee802154/nl-phy.c                     |    6 +-
 net/ipv4/devinet.c                          |   28 ++--
 net/ipv4/fib_frontend.c                     |   10 +-
 net/ipv4/fib_semantics.c                    |    8 +-
 net/ipv4/fib_trie.c                         |    2 +-
 net/ipv4/inet_diag.c                        |   32 +++---
 net/ipv4/ipmr.c                             |   10 +-
 net/ipv4/route.c                            |    8 +-
 net/ipv4/tcp_metrics.c                      |    2 +-
 net/ipv4/udp_diag.c                         |    6 +-
 net/ipv6/addrconf.c                         |   32 +++---
 net/ipv6/addrlabel.c                        |   10 +-
 net/ipv6/ip6mr.c                            |   10 +-
 net/ipv6/route.c                            |   20 ++--
 net/irda/irnetlink.c                        |    2 +-
 net/key/af_key.c                            |   32 +++---
 net/l2tp/l2tp_netlink.c                     |   24 ++--
 net/netfilter/ipset/ip_set_core.c           |   24 ++--
 net/netfilter/ipvs/ip_vs_ctl.c              |    6 +-
 net/netfilter/nf_conntrack_ecache.c         |    2 +-
 net/netfilter/nf_conntrack_netlink.c        |   78 ++++++------
 net/netfilter/nfnetlink_acct.c              |   12 +-
 net/netfilter/nfnetlink_cthelper.c          |   12 +-
 net/netfilter/nfnetlink_cttimeout.c         |   12 +-
 net/netfilter/nfnetlink_log.c               |   18 ++--
 net/netfilter/nfnetlink_queue_core.c        |   28 ++--
 net/netlabel/netlabel_cipso_v4.c            |    2 +-
 net/netlabel/netlabel_mgmt.c                |    4 +-
 net/netlabel/netlabel_unlabeled.c           |    2 +-
 net/netlink/af_netlink.c                    |  172 +++++++++++++-------------
 net/netlink/genetlink.c                     |   42 ++++----
 net/nfc/netlink.c                           |   26 ++--
 net/openvswitch/actions.c                   |    4 +-
 net/openvswitch/datapath.c                  |   84 +++++++-------
 net/openvswitch/datapath.h                  |    2 +-
 net/openvswitch/vport.c                     |    2 +-
 net/openvswitch/vport.h                     |    6 +-
 net/packet/diag.c                           |    6 +-
 net/phonet/pn_netlink.c                     |   14 +-
 net/sched/act_api.c                         |   52 ++++----
 net/sched/cls_api.c                         |   14 +-
 net/sched/sch_api.c                         |   44 ++++----
 net/tipc/netlink.c                          |    2 +-
 net/unix/diag.c                             |   14 +-
 net/wireless/core.h                         |    2 +-
 net/wireless/mlme.c                         |   16 ++--
 net/wireless/nl80211.c                      |  110 +++++++++---------
 net/xfrm/xfrm_state.c                       |   10 +-
 net/xfrm/xfrm_user.c                        |   62 +++++-----
 75 files changed, 728 insertions(+), 728 deletions(-)

diff --git a/crypto/crypto_user.c b/crypto/crypto_user.c
index ba2c611..73b19ca 100644
--- a/crypto/crypto_user.c
+++ b/crypto/crypto_user.c
@@ -166,7 +166,7 @@ static int crypto_report_alg(struct crypto_alg *alg,
 	struct crypto_user_alg *ualg;
 	int err = 0;
 
-	nlh = nlmsg_put(skb, NETLINK_CB(in_skb).pid, info->nlmsg_seq,
+	nlh = nlmsg_put(skb, NETLINK_CB(in_skb).portid, info->nlmsg_seq,
 			CRYPTO_MSG_GETALG, sizeof(*ualg), info->nlmsg_flags);
 	if (!nlh) {
 		err = -EMSGSIZE;
@@ -216,7 +216,7 @@ static int crypto_report(struct sk_buff *in_skb, struct nlmsghdr *in_nlh,
 	if (err)
 		return err;
 
-	return nlmsg_unicast(crypto_nlsk, skb, NETLINK_CB(in_skb).pid);
+	return nlmsg_unicast(crypto_nlsk, skb, NETLINK_CB(in_skb).portid);
 }
 
 static int crypto_dump_report(struct sk_buff *skb, struct netlink_callback *cb)
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index b4f67b5..266af7b 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1886,7 +1886,7 @@ static int team_nl_cmd_noop(struct sk_buff *skb, struct genl_info *info)
 	if (!msg)
 		return -ENOMEM;
 
-	hdr = genlmsg_put(msg, info->snd_pid, info->snd_seq,
+	hdr = genlmsg_put(msg, info->snd_portid, info->snd_seq,
 			  &team_nl_family, 0, TEAM_CMD_NOOP);
 	if (IS_ERR(hdr)) {
 		err = PTR_ERR(hdr);
@@ -1895,7 +1895,7 @@ static int team_nl_cmd_noop(struct sk_buff *skb, struct genl_info *info)
 
 	genlmsg_end(msg, hdr);
 
-	return genlmsg_unicast(genl_info_net(info), msg, info->snd_pid);
+	return genlmsg_unicast(genl_info_net(info), msg, info->snd_portid);
 
 err_msg_put:
 	nlmsg_free(msg);
@@ -1952,7 +1952,7 @@ static int team_nl_send_generic(struct genl_info *info, struct team *team,
 	if (err < 0)
 		goto err_fill;
 
-	err = genlmsg_unicast(genl_info_net(info), skb, info->snd_pid);
+	err = genlmsg_unicast(genl_info_net(info), skb, info->snd_portid);
 	return err;
 
 err_fill:
@@ -1961,11 +1961,11 @@ err_fill:
 }
 
 typedef int team_nl_send_func_t(struct sk_buff *skb,
-				struct team *team, u32 pid);
+				struct team *team, u32 portid);
 
-static int team_nl_send_unicast(struct sk_buff *skb, struct team *team, u32 pid)
+static int team_nl_send_unicast(struct sk_buff *skb, struct team *team, u32 portid)
 {
-	return genlmsg_unicast(dev_net(team->dev), skb, pid);
+	return genlmsg_unicast(dev_net(team->dev), skb, portid);
 }
 
 static int team_nl_fill_one_option_get(struct sk_buff *skb, struct team *team,
@@ -2050,13 +2050,13 @@ nest_cancel:
 }
 
 static int __send_and_alloc_skb(struct sk_buff **pskb,
-				struct team *team, u32 pid,
+				struct team *team, u32 portid,
 				team_nl_send_func_t *send_func)
 {
 	int err;
 
 	if (*pskb) {
-		err = send_func(*pskb, team, pid);
+		err = send_func(*pskb, team, portid);
 		if (err)
 			return err;
 	}
@@ -2066,7 +2066,7 @@ static int __send_and_alloc_skb(struct sk_buff **pskb,
 	return 0;
 }
 
-static int team_nl_send_options_get(struct team *team, u32 pid, u32 seq,
+static int team_nl_send_options_get(struct team *team, u32 portid, u32 seq,
 				    int flags, team_nl_send_func_t *send_func,
 				    struct list_head *sel_opt_inst_list)
 {
@@ -2083,11 +2083,11 @@ static int team_nl_send_options_get(struct team *team, u32 pid, u32 seq,
 				    struct team_option_inst, tmp_list);
 
 start_again:
-	err = __send_and_alloc_skb(&skb, team, pid, send_func);
+	err = __send_and_alloc_skb(&skb, team, portid, send_func);
 	if (err)
 		return err;
 
-	hdr = genlmsg_put(skb, pid, seq, &team_nl_family, flags | NLM_F_MULTI,
+	hdr = genlmsg_put(skb, portid, seq, &team_nl_family, flags | NLM_F_MULTI,
 			  TEAM_CMD_OPTIONS_GET);
 	if (IS_ERR(hdr))
 		return PTR_ERR(hdr);
@@ -2120,15 +2120,15 @@ start_again:
 		goto start_again;
 
 send_done:
-	nlh = nlmsg_put(skb, pid, seq, NLMSG_DONE, 0, flags | NLM_F_MULTI);
+	nlh = nlmsg_put(skb, portid, seq, NLMSG_DONE, 0, flags | NLM_F_MULTI);
 	if (!nlh) {
-		err = __send_and_alloc_skb(&skb, team, pid, send_func);
+		err = __send_and_alloc_skb(&skb, team, portid, send_func);
 		if (err)
 			goto errout;
 		goto send_done;
 	}
 
-	return send_func(skb, team, pid);
+	return send_func(skb, team, portid);
 
 nla_put_failure:
 	err = -EMSGSIZE;
@@ -2151,7 +2151,7 @@ static int team_nl_cmd_options_get(struct sk_buff *skb, struct genl_info *info)
 
 	list_for_each_entry(opt_inst, &team->option_inst_list, list)
 		list_add_tail(&opt_inst->tmp_list, &sel_opt_inst_list);
-	err = team_nl_send_options_get(team, info->snd_pid, info->snd_seq,
+	err = team_nl_send_options_get(team, info->snd_portid, info->snd_seq,
 				       NLM_F_ACK, team_nl_send_unicast,
 				       &sel_opt_inst_list);
 
@@ -2305,7 +2305,7 @@ team_put:
 }
 
 static int team_nl_fill_port_list_get(struct sk_buff *skb,
-				      u32 pid, u32 seq, int flags,
+				      u32 portid, u32 seq, int flags,
 				      struct team *team,
 				      bool fillall)
 {
@@ -2313,7 +2313,7 @@ static int team_nl_fill_port_list_get(struct sk_buff *skb,
 	void *hdr;
 	struct team_port *port;
 
-	hdr = genlmsg_put(skb, pid, seq, &team_nl_family, flags,
+	hdr = genlmsg_put(skb, portid, seq, &team_nl_family, flags,
 			  TEAM_CMD_PORT_LIST_GET);
 	if (IS_ERR(hdr))
 		return PTR_ERR(hdr);
@@ -2362,7 +2362,7 @@ static int team_nl_fill_port_list_get_all(struct sk_buff *skb,
 					  struct genl_info *info, int flags,
 					  struct team *team)
 {
-	return team_nl_fill_port_list_get(skb, info->snd_pid,
+	return team_nl_fill_port_list_get(skb, info->snd_portid,
 					  info->snd_seq, NLM_F_ACK,
 					  team, true);
 }
@@ -2415,7 +2415,7 @@ static struct genl_multicast_group team_change_event_mcgrp = {
 };
 
 static int team_nl_send_multicast(struct sk_buff *skb,
-				  struct team *team, u32 pid)
+				  struct team *team, u32 portid)
 {
 	return genlmsg_multicast_netns(dev_net(team->dev), skb, 0,
 				       team_change_event_mcgrp.id, GFP_KERNEL);
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 72b0456..9d45b3b 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -38,7 +38,7 @@ MODULE_AUTHOR("Jouni Malinen");
 MODULE_DESCRIPTION("Software simulator of 802.11 radio(s) for mac80211");
 MODULE_LICENSE("GPL");
 
-static u32 wmediumd_pid;
+static u32 wmediumd_portid;
 
 static int radios = 2;
 module_param(radios, int, 0444);
@@ -545,7 +545,7 @@ static bool mac80211_hwsim_addr_match(struct mac80211_hwsim_data *data,
 
 static void mac80211_hwsim_tx_frame_nl(struct ieee80211_hw *hw,
 				       struct sk_buff *my_skb,
-				       int dst_pid)
+				       int dst_portid)
 {
 	struct sk_buff *skb;
 	struct mac80211_hwsim_data *data = hw->priv;
@@ -619,7 +619,7 @@ static void mac80211_hwsim_tx_frame_nl(struct ieee80211_hw *hw,
 		goto nla_put_failure;
 
 	genlmsg_end(skb, msg_head);
-	genlmsg_unicast(&init_net, skb, dst_pid);
+	genlmsg_unicast(&init_net, skb, dst_portid);
 
 	/* Enqueue the packet */
 	skb_queue_tail(&data->pending, my_skb);
@@ -715,7 +715,7 @@ static void mac80211_hwsim_tx(struct ieee80211_hw *hw,
 {
 	bool ack;
 	struct ieee80211_tx_info *txi;
-	u32 _pid;
+	u32 _portid;
 
 	mac80211_hwsim_monitor_rx(hw, skb);
 
@@ -726,10 +726,10 @@ static void mac80211_hwsim_tx(struct ieee80211_hw *hw,
 	}
 
 	/* wmediumd mode check */
-	_pid = ACCESS_ONCE(wmediumd_pid);
+	_portid = ACCESS_ONCE(wmediumd_portid);
 
-	if (_pid)
-		return mac80211_hwsim_tx_frame_nl(hw, skb, _pid);
+	if (_portid)
+		return mac80211_hwsim_tx_frame_nl(hw, skb, _portid);
 
 	/* NO wmediumd detected, perfect medium simulation */
 	ack = mac80211_hwsim_tx_frame_no_nl(hw, skb);
@@ -814,7 +814,7 @@ static void mac80211_hwsim_beacon_tx(void *arg, u8 *mac,
 	struct ieee80211_hw *hw = arg;
 	struct sk_buff *skb;
 	struct ieee80211_tx_info *info;
-	u32 _pid;
+	u32 _portid;
 
 	hwsim_check_magic(vif);
 
@@ -831,10 +831,10 @@ static void mac80211_hwsim_beacon_tx(void *arg, u8 *mac,
 	mac80211_hwsim_monitor_rx(hw, skb);
 
 	/* wmediumd mode check */
-	_pid = ACCESS_ONCE(wmediumd_pid);
+	_portid = ACCESS_ONCE(wmediumd_portid);
 
-	if (_pid)
-		return mac80211_hwsim_tx_frame_nl(hw, skb, _pid);
+	if (_portid)
+		return mac80211_hwsim_tx_frame_nl(hw, skb, _portid);
 
 	mac80211_hwsim_tx_frame_no_nl(hw, skb);
 	dev_kfree_skb(skb);
@@ -1315,7 +1315,7 @@ static void hwsim_send_ps_poll(void *dat, u8 *mac, struct ieee80211_vif *vif)
 	struct hwsim_vif_priv *vp = (void *)vif->drv_priv;
 	struct sk_buff *skb;
 	struct ieee80211_pspoll *pspoll;
-	u32 _pid;
+	u32 _portid;
 
 	if (!vp->assoc)
 		return;
@@ -1336,10 +1336,10 @@ static void hwsim_send_ps_poll(void *dat, u8 *mac, struct ieee80211_vif *vif)
 	memcpy(pspoll->ta, mac, ETH_ALEN);
 
 	/* wmediumd mode check */
-	_pid = ACCESS_ONCE(wmediumd_pid);
+	_portid = ACCESS_ONCE(wmediumd_portid);
 
-	if (_pid)
-		return mac80211_hwsim_tx_frame_nl(data->hw, skb, _pid);
+	if (_portid)
+		return mac80211_hwsim_tx_frame_nl(data->hw, skb, _portid);
 
 	if (!mac80211_hwsim_tx_frame_no_nl(data->hw, skb))
 		printk(KERN_DEBUG "%s: PS-poll frame not ack'ed\n", __func__);
@@ -1353,7 +1353,7 @@ static void hwsim_send_nullfunc(struct mac80211_hwsim_data *data, u8 *mac,
 	struct hwsim_vif_priv *vp = (void *)vif->drv_priv;
 	struct sk_buff *skb;
 	struct ieee80211_hdr *hdr;
-	u32 _pid;
+	u32 _portid;
 
 	if (!vp->assoc)
 		return;
@@ -1375,10 +1375,10 @@ static void hwsim_send_nullfunc(struct mac80211_hwsim_data *data, u8 *mac,
 	memcpy(hdr->addr3, vp->bssid, ETH_ALEN);
 
 	/* wmediumd mode check */
-	_pid = ACCESS_ONCE(wmediumd_pid);
+	_portid = ACCESS_ONCE(wmediumd_portid);
 
-	if (_pid)
-		return mac80211_hwsim_tx_frame_nl(data->hw, skb, _pid);
+	if (_portid)
+		return mac80211_hwsim_tx_frame_nl(data->hw, skb, _portid);
 
 	if (!mac80211_hwsim_tx_frame_no_nl(data->hw, skb))
 		printk(KERN_DEBUG "%s: nullfunc frame not ack'ed\n", __func__);
@@ -1632,10 +1632,10 @@ static int hwsim_register_received_nl(struct sk_buff *skb_2,
 	if (info == NULL)
 		goto out;
 
-	wmediumd_pid = info->snd_pid;
+	wmediumd_portid = info->snd_portid;
 
 	printk(KERN_DEBUG "mac80211_hwsim: received a REGISTER, "
-	       "switching to wmediumd mode with pid %d\n", info->snd_pid);
+	       "switching to wmediumd mode with pid %d\n", info->snd_portid);
 
 	return 0;
 out:
@@ -1672,10 +1672,10 @@ static int mac80211_hwsim_netlink_notify(struct notifier_block *nb,
 	if (state != NETLINK_URELEASE)
 		return NOTIFY_DONE;
 
-	if (notify->pid == wmediumd_pid) {
+	if (notify->portid == wmediumd_portid) {
 		printk(KERN_INFO "mac80211_hwsim: wmediumd released netlink"
 		       " socket, switching to perfect channel medium\n");
-		wmediumd_pid = 0;
+		wmediumd_portid = 0;
 	}
 	return NOTIFY_DONE;
 
diff --git a/drivers/scsi/scsi_transport_iscsi.c b/drivers/scsi/scsi_transport_iscsi.c
index fa1dfaa..0f9ab01 100644
--- a/drivers/scsi/scsi_transport_iscsi.c
+++ b/drivers/scsi/scsi_transport_iscsi.c
@@ -2119,7 +2119,7 @@ iscsi_if_recv_msg(struct sk_buff *skb, struct nlmsghdr *nlh, uint32_t *group)
 	switch (nlh->nlmsg_type) {
 	case ISCSI_UEVENT_CREATE_SESSION:
 		err = iscsi_if_create_session(priv, ep, ev,
-					      NETLINK_CB(skb).pid,
+					      NETLINK_CB(skb).portid,
 					      ev->u.c_session.initial_cmdsn,
 					      ev->u.c_session.cmds_max,
 					      ev->u.c_session.queue_depth);
@@ -2132,7 +2132,7 @@ iscsi_if_recv_msg(struct sk_buff *skb, struct nlmsghdr *nlh, uint32_t *group)
 		}
 
 		err = iscsi_if_create_session(priv, ep, ev,
-					NETLINK_CB(skb).pid,
+					NETLINK_CB(skb).portid,
 					ev->u.c_bound_session.initial_cmdsn,
 					ev->u.c_bound_session.cmds_max,
 					ev->u.c_bound_session.queue_depth);
diff --git a/drivers/staging/gdm72xx/netlink_k.c b/drivers/staging/gdm72xx/netlink_k.c
index 3abb31d..0664ee8 100644
--- a/drivers/staging/gdm72xx/netlink_k.c
+++ b/drivers/staging/gdm72xx/netlink_k.c
@@ -135,7 +135,7 @@ int netlink_send(struct sock *sock, int group, u16 type, void *msg, int len)
 	}
 	memcpy(nlmsg_data(nlh), msg, len);
 
-	NETLINK_CB(skb).pid = 0;
+	NETLINK_CB(skb).portid = 0;
 	NETLINK_CB(skb).dst_group = 0;
 
 	ret = netlink_broadcast(sock, skb, 0, group+1, GFP_ATOMIC);
diff --git a/fs/dlm/netlink.c b/fs/dlm/netlink.c
index ef17e01..60a3278 100644
--- a/fs/dlm/netlink.c
+++ b/fs/dlm/netlink.c
@@ -14,7 +14,7 @@
 #include "dlm_internal.h"
 
 static uint32_t dlm_nl_seqnum;
-static uint32_t listener_nlpid;
+static uint32_t listener_nlportid;
 
 static struct genl_family family = {
 	.id		= GENL_ID_GENERATE,
@@ -64,13 +64,13 @@ static int send_data(struct sk_buff *skb)
 		return rv;
 	}
 
-	return genlmsg_unicast(&init_net, skb, listener_nlpid);
+	return genlmsg_unicast(&init_net, skb, listener_nlportid);
 }
 
 static int user_cmd(struct sk_buff *skb, struct genl_info *info)
 {
-	listener_nlpid = info->snd_pid;
-	printk("user_cmd nlpid %u\n", listener_nlpid);
+	listener_nlportid = info->snd_portid;
+	printk("user_cmd nlpid %u\n", listener_nlportid);
 	return 0;
 }
 
diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index c9fdde2..b8ff93c 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -163,7 +163,7 @@ static inline struct nlmsghdr *nlmsg_hdr(const struct sk_buff *skb)
 
 struct netlink_skb_parms {
 	struct ucred		creds;		/* Skb credentials	*/
-	__u32			pid;
+	__u32			portid;
 	__u32			dst_group;
 	struct sock		*ssk;
 };
@@ -193,14 +193,14 @@ extern void __netlink_clear_multicast_users(struct sock *sk, unsigned int group)
 extern void netlink_clear_multicast_users(struct sock *sk, unsigned int group);
 extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
 extern int netlink_has_listeners(struct sock *sk, unsigned int group);
-extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 pid, int nonblock);
-extern int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, __u32 pid,
+extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 portid, int nonblock);
+extern int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, __u32 portid,
 			     __u32 group, gfp_t allocation);
 extern int netlink_broadcast_filtered(struct sock *ssk, struct sk_buff *skb,
-	__u32 pid, __u32 group, gfp_t allocation,
+	__u32 portid, __u32 group, gfp_t allocation,
 	int (*filter)(struct sock *dsk, struct sk_buff *skb, void *data),
 	void *filter_data);
-extern int netlink_set_err(struct sock *ssk, __u32 pid, __u32 group, int code);
+extern int netlink_set_err(struct sock *ssk, __u32 portid, __u32 group, int code);
 extern int netlink_register_notifier(struct notifier_block *nb);
 extern int netlink_unregister_notifier(struct notifier_block *nb);
 
@@ -241,12 +241,12 @@ struct netlink_callback {
 
 struct netlink_notify {
 	struct net *net;
-	int pid;
+	int portid;
 	int protocol;
 };
 
 struct nlmsghdr *
-__nlmsg_put(struct sk_buff *skb, u32 pid, u32 seq, int type, int len, int flags);
+__nlmsg_put(struct sk_buff *skb, u32 portid, u32 seq, int type, int len, int flags);
 
 struct netlink_dump_control {
 	int (*dump)(struct sk_buff *skb, struct netlink_callback *);
diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index ba2e616..7b3b056 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -2458,7 +2458,7 @@ struct wireless_dev {
 
 	int beacon_interval;
 
-	u32 ap_unexpected_nlpid;
+	u32 ap_unexpected_nlportid;
 
 #ifdef CONFIG_CFG80211_WEXT
 	/* wext data */
diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 48905cd..bdfbe68 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -65,7 +65,7 @@ struct genl_family {
 /**
  * struct genl_info - receiving information
  * @snd_seq: sending sequence number
- * @snd_pid: netlink pid of sender
+ * @snd_portid: netlink portid of sender
  * @nlhdr: netlink message header
  * @genlhdr: generic netlink message header
  * @userhdr: user specific header
@@ -75,7 +75,7 @@ struct genl_family {
  */
 struct genl_info {
 	u32			snd_seq;
-	u32			snd_pid;
+	u32			snd_portid;
 	struct nlmsghdr *	nlhdr;
 	struct genlmsghdr *	genlhdr;
 	void *			userhdr;
@@ -130,10 +130,10 @@ extern int genl_register_mc_group(struct genl_family *family,
 				  struct genl_multicast_group *grp);
 extern void genl_unregister_mc_group(struct genl_family *family,
 				     struct genl_multicast_group *grp);
-extern void genl_notify(struct sk_buff *skb, struct net *net, u32 pid,
+extern void genl_notify(struct sk_buff *skb, struct net *net, u32 portid,
 			u32 group, struct nlmsghdr *nlh, gfp_t flags);
 
-void *genlmsg_put(struct sk_buff *skb, u32 pid, u32 seq,
+void *genlmsg_put(struct sk_buff *skb, u32 portid, u32 seq,
 				struct genl_family *family, int flags, u8 cmd);
 
 /**
@@ -183,7 +183,7 @@ static inline void *genlmsg_put_reply(struct sk_buff *skb,
 				      struct genl_family *family,
 				      int flags, u8 cmd)
 {
-	return genlmsg_put(skb, info->snd_pid, info->snd_seq, family,
+	return genlmsg_put(skb, info->snd_portid, info->snd_seq, family,
 			   flags, cmd);
 }
 
@@ -212,49 +212,49 @@ static inline void genlmsg_cancel(struct sk_buff *skb, void *hdr)
  * genlmsg_multicast_netns - multicast a netlink message to a specific netns
  * @net: the net namespace
  * @skb: netlink message as socket buffer
- * @pid: own netlink pid to avoid sending to yourself
+ * @portid: own netlink portid to avoid sending to yourself
  * @group: multicast group id
  * @flags: allocation flags
  */
 static inline int genlmsg_multicast_netns(struct net *net, struct sk_buff *skb,
-					  u32 pid, unsigned int group, gfp_t flags)
+					  u32 portid, unsigned int group, gfp_t flags)
 {
-	return nlmsg_multicast(net->genl_sock, skb, pid, group, flags);
+	return nlmsg_multicast(net->genl_sock, skb, portid, group, flags);
 }
 
 /**
  * genlmsg_multicast - multicast a netlink message to the default netns
  * @skb: netlink message as socket buffer
- * @pid: own netlink pid to avoid sending to yourself
+ * @portid: own netlink portid to avoid sending to yourself
  * @group: multicast group id
  * @flags: allocation flags
  */
-static inline int genlmsg_multicast(struct sk_buff *skb, u32 pid,
+static inline int genlmsg_multicast(struct sk_buff *skb, u32 portid,
 				    unsigned int group, gfp_t flags)
 {
-	return genlmsg_multicast_netns(&init_net, skb, pid, group, flags);
+	return genlmsg_multicast_netns(&init_net, skb, portid, group, flags);
 }
 
 /**
  * genlmsg_multicast_allns - multicast a netlink message to all net namespaces
  * @skb: netlink message as socket buffer
- * @pid: own netlink pid to avoid sending to yourself
+ * @portid: own netlink portid to avoid sending to yourself
  * @group: multicast group id
  * @flags: allocation flags
  *
  * This function must hold the RTNL or rcu_read_lock().
  */
-int genlmsg_multicast_allns(struct sk_buff *skb, u32 pid,
+int genlmsg_multicast_allns(struct sk_buff *skb, u32 portid,
 			    unsigned int group, gfp_t flags);
 
 /**
  * genlmsg_unicast - unicast a netlink message
  * @skb: netlink message as socket buffer
- * @pid: netlink pid of the destination socket
+ * @portid: netlink portid of the destination socket
  */
-static inline int genlmsg_unicast(struct net *net, struct sk_buff *skb, u32 pid)
+static inline int genlmsg_unicast(struct net *net, struct sk_buff *skb, u32 portid)
 {
-	return nlmsg_unicast(net->genl_sock, skb, pid);
+	return nlmsg_unicast(net->genl_sock, skb, portid);
 }
 
 /**
@@ -264,7 +264,7 @@ static inline int genlmsg_unicast(struct net *net, struct sk_buff *skb, u32 pid)
  */
 static inline int genlmsg_reply(struct sk_buff *skb, struct genl_info *info)
 {
-	return genlmsg_unicast(genl_info_net(info), skb, info->snd_pid);
+	return genlmsg_unicast(genl_info_net(info), skb, info->snd_portid);
 }
 
 /**
diff --git a/include/net/netfilter/nf_conntrack_ecache.h b/include/net/netfilter/nf_conntrack_ecache.h
index 4a045cd..5654d29 100644
--- a/include/net/netfilter/nf_conntrack_ecache.h
+++ b/include/net/netfilter/nf_conntrack_ecache.h
@@ -17,7 +17,7 @@ struct nf_conntrack_ecache {
 	unsigned long missed;	/* missed events */
 	u16 ctmask;		/* bitmask of ct events to be delivered */
 	u16 expmask;		/* bitmask of expect events to be delivered */
-	u32 pid;		/* netlink pid of destroyer */
+	u32 portid;		/* netlink portid of destroyer */
 	struct timer_list timeout;
 };
 
@@ -60,7 +60,7 @@ nf_ct_ecache_ext_add(struct nf_conn *ct, u16 ctmask, u16 expmask, gfp_t gfp)
 /* This structure is passed to event handler */
 struct nf_ct_event {
 	struct nf_conn *ct;
-	u32 pid;
+	u32 portid;
 	int report;
 };
 
@@ -92,7 +92,7 @@ nf_conntrack_event_cache(enum ip_conntrack_events event, struct nf_conn *ct)
 static inline int
 nf_conntrack_eventmask_report(unsigned int eventmask,
 			      struct nf_conn *ct,
-			      u32 pid,
+			      u32 portid,
 			      int report)
 {
 	int ret = 0;
@@ -112,11 +112,11 @@ nf_conntrack_eventmask_report(unsigned int eventmask,
 	if (nf_ct_is_confirmed(ct) && !nf_ct_is_dying(ct)) {
 		struct nf_ct_event item = {
 			.ct 	= ct,
-			.pid	= e->pid ? e->pid : pid,
+			.portid	= e->portid ? e->portid : portid,
 			.report = report
 		};
 		/* This is a resent of a destroy event? If so, skip missed */
-		unsigned long missed = e->pid ? 0 : e->missed;
+		unsigned long missed = e->portid ? 0 : e->missed;
 
 		if (!((eventmask | missed) & e->ctmask))
 			goto out_unlock;
@@ -126,11 +126,11 @@ nf_conntrack_eventmask_report(unsigned int eventmask,
 			spin_lock_bh(&ct->lock);
 			if (ret < 0) {
 				/* This is a destroy event that has been
-				 * triggered by a process, we store the PID
+				 * triggered by a process, we store the PORTID
 				 * to include it in the retransmission. */
 				if (eventmask & (1 << IPCT_DESTROY) &&
-				    e->pid == 0 && pid != 0)
-					e->pid = pid;
+				    e->portid == 0 && portid != 0)
+					e->portid = portid;
 				else
 					e->missed |= eventmask;
 			} else
@@ -145,9 +145,9 @@ out_unlock:
 
 static inline int
 nf_conntrack_event_report(enum ip_conntrack_events event, struct nf_conn *ct,
-			  u32 pid, int report)
+			  u32 portid, int report)
 {
-	return nf_conntrack_eventmask_report(1 << event, ct, pid, report);
+	return nf_conntrack_eventmask_report(1 << event, ct, portid, report);
 }
 
 static inline int
@@ -158,7 +158,7 @@ nf_conntrack_event(enum ip_conntrack_events event, struct nf_conn *ct)
 
 struct nf_exp_event {
 	struct nf_conntrack_expect *exp;
-	u32 pid;
+	u32 portid;
 	int report;
 };
 
@@ -172,7 +172,7 @@ extern void nf_ct_expect_unregister_notifier(struct net *net, struct nf_exp_even
 static inline void
 nf_ct_expect_event_report(enum ip_conntrack_expect_events event,
 			  struct nf_conntrack_expect *exp,
-			  u32 pid,
+			  u32 portid,
 			  int report)
 {
 	struct net *net = nf_ct_exp_net(exp);
@@ -191,7 +191,7 @@ nf_ct_expect_event_report(enum ip_conntrack_expect_events event,
 	if (e->expmask & (1 << event)) {
 		struct nf_exp_event item = {
 			.exp	= exp,
-			.pid	= pid,
+			.portid	= portid,
 			.report = report
 		};
 		notify->fcn(1 << event, &item);
@@ -216,20 +216,20 @@ static inline void nf_conntrack_event_cache(enum ip_conntrack_events event,
 					    struct nf_conn *ct) {}
 static inline int nf_conntrack_eventmask_report(unsigned int eventmask,
 						struct nf_conn *ct,
-						u32 pid,
+						u32 portid,
 						int report) { return 0; }
 static inline int nf_conntrack_event(enum ip_conntrack_events event,
 				     struct nf_conn *ct) { return 0; }
 static inline int nf_conntrack_event_report(enum ip_conntrack_events event,
 					    struct nf_conn *ct,
-					    u32 pid,
+					    u32 portid,
 					    int report) { return 0; }
 static inline void nf_ct_deliver_cached_events(const struct nf_conn *ct) {}
 static inline void nf_ct_expect_event(enum ip_conntrack_expect_events event,
 				      struct nf_conntrack_expect *exp) {}
 static inline void nf_ct_expect_event_report(enum ip_conntrack_expect_events e,
 					     struct nf_conntrack_expect *exp,
- 					     u32 pid,
+ 					     u32 portid,
  					     int report) {}
 
 static inline int nf_conntrack_ecache_init(struct net *net)
diff --git a/include/net/netlink.h b/include/net/netlink.h
index 09175d5..9690b0f 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -217,19 +217,19 @@ struct nla_policy {
 /**
  * struct nl_info - netlink source information
  * @nlh: Netlink message header of original request
- * @pid: Netlink PID of requesting application
+ * @portid: Netlink PORTID of requesting application
  */
 struct nl_info {
 	struct nlmsghdr		*nlh;
 	struct net		*nl_net;
-	u32			pid;
+	u32			portid;
 };
 
 extern int		netlink_rcv_skb(struct sk_buff *skb,
 					int (*cb)(struct sk_buff *,
 						  struct nlmsghdr *));
 extern int		nlmsg_notify(struct sock *sk, struct sk_buff *skb,
-				     u32 pid, unsigned int group, int report,
+				     u32 portid, unsigned int group, int report,
 				     gfp_t flags);
 
 extern int		nla_validate(const struct nlattr *head,
@@ -444,7 +444,7 @@ static inline int nlmsg_report(const struct nlmsghdr *nlh)
 /**
  * nlmsg_put - Add a new netlink message to an skb
  * @skb: socket buffer to store message in
- * @pid: netlink process id
+ * @portid: netlink process id
  * @seq: sequence number of message
  * @type: message type
  * @payload: length of message payload
@@ -453,13 +453,13 @@ static inline int nlmsg_report(const struct nlmsghdr *nlh)
  * Returns NULL if the tailroom of the skb is insufficient to store
  * the message header and payload.
  */
-static inline struct nlmsghdr *nlmsg_put(struct sk_buff *skb, u32 pid, u32 seq,
+static inline struct nlmsghdr *nlmsg_put(struct sk_buff *skb, u32 portid, u32 seq,
 					 int type, int payload, int flags)
 {
 	if (unlikely(skb_tailroom(skb) < nlmsg_total_size(payload)))
 		return NULL;
 
-	return __nlmsg_put(skb, pid, seq, type, payload, flags);
+	return __nlmsg_put(skb, portid, seq, type, payload, flags);
 }
 
 /**
@@ -478,7 +478,7 @@ static inline struct nlmsghdr *nlmsg_put_answer(struct sk_buff *skb,
 						int type, int payload,
 						int flags)
 {
-	return nlmsg_put(skb, NETLINK_CB(cb->skb).pid, cb->nlh->nlmsg_seq,
+	return nlmsg_put(skb, NETLINK_CB(cb->skb).portid, cb->nlh->nlmsg_seq,
 			 type, payload, flags);
 }
 
@@ -563,18 +563,18 @@ static inline void nlmsg_free(struct sk_buff *skb)
  * nlmsg_multicast - multicast a netlink message
  * @sk: netlink socket to spread messages to
  * @skb: netlink message as socket buffer
- * @pid: own netlink pid to avoid sending to yourself
+ * @portid: own netlink portid to avoid sending to yourself
  * @group: multicast group id
  * @flags: allocation flags
  */
 static inline int nlmsg_multicast(struct sock *sk, struct sk_buff *skb,
-				  u32 pid, unsigned int group, gfp_t flags)
+				  u32 portid, unsigned int group, gfp_t flags)
 {
 	int err;
 
 	NETLINK_CB(skb).dst_group = group;
 
-	err = netlink_broadcast(sk, skb, pid, group, flags);
+	err = netlink_broadcast(sk, skb, portid, group, flags);
 	if (err > 0)
 		err = 0;
 
@@ -585,13 +585,13 @@ static inline int nlmsg_multicast(struct sock *sk, struct sk_buff *skb,
  * nlmsg_unicast - unicast a netlink message
  * @sk: netlink socket to spread message to
  * @skb: netlink message as socket buffer
- * @pid: netlink pid of the destination socket
+ * @portid: netlink portid of the destination socket
  */
-static inline int nlmsg_unicast(struct sock *sk, struct sk_buff *skb, u32 pid)
+static inline int nlmsg_unicast(struct sock *sk, struct sk_buff *skb, u32 portid)
 {
 	int err;
 
-	err = netlink_unicast(sk, skb, pid, MSG_DONTWAIT);
+	err = netlink_unicast(sk, skb, portid, MSG_DONTWAIT);
 	if (err > 0)
 		err = 0;
 
diff --git a/include/net/nfc/nfc.h b/include/net/nfc/nfc.h
index 6431f5e..6735909 100644
--- a/include/net/nfc/nfc.h
+++ b/include/net/nfc/nfc.h
@@ -89,7 +89,7 @@ struct nfc_target {
 };
 
 struct nfc_genl_data {
-	u32 poll_req_pid;
+	u32 poll_req_portid;
 	struct mutex genl_data_mutex;
 };
 
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 36ad56b..ee8613f 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -263,7 +263,7 @@ struct km_event {
 	} data;
 
 	u32	seq;
-	u32	pid;
+	u32	portid;
 	u32	event;
 	struct net *net;
 };
@@ -310,7 +310,7 @@ extern void km_state_notify(struct xfrm_state *x, const struct km_event *c);
 
 struct xfrm_tmpl;
 extern int km_query(struct xfrm_state *x, struct xfrm_tmpl *t, struct xfrm_policy *pol);
-extern void km_state_expired(struct xfrm_state *x, int hard, u32 pid);
+extern void km_state_expired(struct xfrm_state *x, int hard, u32 portid);
 extern int __xfrm_state_delete(struct xfrm_state *x);
 
 struct xfrm_state_afinfo {
@@ -1554,7 +1554,7 @@ extern int xfrm_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 #endif
 
 extern int km_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr, __be16 sport);
-extern void km_policy_expired(struct xfrm_policy *pol, int dir, int hard, u32 pid);
+extern void km_policy_expired(struct xfrm_policy *pol, int dir, int hard, u32 portid);
 extern int km_report(struct net *net, u8 proto, struct xfrm_selector *sel, xfrm_address_t *addr);
 
 extern void xfrm_input_init(void);
diff --git a/kernel/audit.c b/kernel/audit.c
index ea3b7b6..896be75 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -87,11 +87,11 @@ static int	audit_failure = AUDIT_FAIL_PRINTK;
 
 /*
  * If audit records are to be written to the netlink socket, audit_pid
- * contains the pid of the auditd process and audit_nlk_pid contains
- * the pid to use to send netlink messages to that process.
+ * contains the pid of the auditd process and audit_nlk_portid contains
+ * the portid to use to send netlink messages to that process.
  */
 int		audit_pid;
-static int	audit_nlk_pid;
+static int	audit_nlk_portid;
 
 /* If audit_rate_limit is non-zero, limit the rate of sending audit records
  * to that number per second.  This prevents DoS attacks, but results in
@@ -401,7 +401,7 @@ static void kauditd_send_skb(struct sk_buff *skb)
 	int err;
 	/* take a reference in case we can't send it and we want to hold it */
 	skb_get(skb);
-	err = netlink_unicast(audit_sock, skb, audit_nlk_pid, 0);
+	err = netlink_unicast(audit_sock, skb, audit_nlk_portid, 0);
 	if (err < 0) {
 		BUG_ON(err != -ECONNREFUSED); /* Shouldn't happen */
 		printk(KERN_ERR "audit: *NO* daemon at audit_pid=%d\n", audit_pid);
@@ -692,7 +692,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		status_set.backlog_limit = audit_backlog_limit;
 		status_set.lost		 = atomic_read(&audit_lost);
 		status_set.backlog	 = skb_queue_len(&audit_skb_queue);
-		audit_send_reply(NETLINK_CB(skb).pid, seq, AUDIT_GET, 0, 0,
+		audit_send_reply(NETLINK_CB(skb).portid, seq, AUDIT_GET, 0, 0,
 				 &status_set, sizeof(status_set));
 		break;
 	case AUDIT_SET:
@@ -720,7 +720,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 							sessionid, sid, 1);
 
 			audit_pid = new_pid;
-			audit_nlk_pid = NETLINK_CB(skb).pid;
+			audit_nlk_portid = NETLINK_CB(skb).portid;
 		}
 		if (status_get->mask & AUDIT_STATUS_RATE_LIMIT) {
 			err = audit_set_rate_limit(status_get->rate_limit,
@@ -782,7 +782,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		}
 		/* fallthrough */
 	case AUDIT_LIST:
-		err = audit_receive_filter(msg_type, NETLINK_CB(skb).pid,
+		err = audit_receive_filter(msg_type, NETLINK_CB(skb).portid,
 					   uid, seq, data, nlmsg_len(nlh),
 					   loginuid, sessionid, sid);
 		break;
@@ -801,7 +801,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		}
 		/* fallthrough */
 	case AUDIT_LIST_RULES:
-		err = audit_receive_filter(msg_type, NETLINK_CB(skb).pid,
+		err = audit_receive_filter(msg_type, NETLINK_CB(skb).portid,
 					   uid, seq, data, nlmsg_len(nlh),
 					   loginuid, sessionid, sid);
 		break;
@@ -872,7 +872,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 			memcpy(sig_data->ctx, ctx, len);
 			security_release_secctx(ctx, len);
 		}
-		audit_send_reply(NETLINK_CB(skb).pid, seq, AUDIT_SIGNAL_INFO,
+		audit_send_reply(NETLINK_CB(skb).portid, seq, AUDIT_SIGNAL_INFO,
 				0, 0, sig_data, sizeof(*sig_data) + len);
 		kfree(sig_data);
 		break;
@@ -891,7 +891,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		rcu_read_unlock();
 
 		if (!err)
-			audit_send_reply(NETLINK_CB(skb).pid, seq,
+			audit_send_reply(NETLINK_CB(skb).portid, seq,
 					 AUDIT_TTY_GET, 0, 0, &s, sizeof(s));
 		break;
 	}
diff --git a/kernel/taskstats.c b/kernel/taskstats.c
index d0a3279..123793c 100644
--- a/kernel/taskstats.c
+++ b/kernel/taskstats.c
@@ -467,7 +467,7 @@ static int cmd_attr_register_cpumask(struct genl_info *info)
 	rc = parse(info->attrs[TASKSTATS_CMD_ATTR_REGISTER_CPUMASK], mask);
 	if (rc < 0)
 		goto out;
-	rc = add_del_listener(info->snd_pid, mask, REGISTER);
+	rc = add_del_listener(info->snd_portid, mask, REGISTER);
 out:
 	free_cpumask_var(mask);
 	return rc;
@@ -483,7 +483,7 @@ static int cmd_attr_deregister_cpumask(struct genl_info *info)
 	rc = parse(info->attrs[TASKSTATS_CMD_ATTR_DEREGISTER_CPUMASK], mask);
 	if (rc < 0)
 		goto out;
-	rc = add_del_listener(info->snd_pid, mask, DEREGISTER);
+	rc = add_del_listener(info->snd_portid, mask, DEREGISTER);
 out:
 	free_cpumask_var(mask);
 	return rc;
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 9ce430b..ddf93ef 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -467,14 +467,14 @@ static int fdb_to_nud(const struct net_bridge_fdb_entry *fdb)
 
 static int fdb_fill_info(struct sk_buff *skb, const struct net_bridge *br,
 			 const struct net_bridge_fdb_entry *fdb,
-			 u32 pid, u32 seq, int type, unsigned int flags)
+			 u32 portid, u32 seq, int type, unsigned int flags)
 {
 	unsigned long now = jiffies;
 	struct nda_cacheinfo ci;
 	struct nlmsghdr *nlh;
 	struct ndmsg *ndm;
 
-	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ndm), flags);
+	nlh = nlmsg_put(skb, portid, seq, type, sizeof(*ndm), flags);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
@@ -555,7 +555,7 @@ int br_fdb_dump(struct sk_buff *skb,
 				goto skip;
 
 			if (fdb_fill_info(skb, br, f,
-					  NETLINK_CB(cb->skb).pid,
+					  NETLINK_CB(cb->skb).portid,
 					  cb->nlh->nlmsg_seq,
 					  RTM_NEWNEIGH,
 					  NLM_F_MULTI) < 0)
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index fe41260..093f527 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -127,7 +127,7 @@ static int br_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 			goto skip;
 
 		if (br_fill_ifinfo(skb, port,
-				   NETLINK_CB(cb->skb).pid,
+				   NETLINK_CB(cb->skb).portid,
 				   cb->nlh->nlmsg_seq, RTM_NEWLINK,
 				   NLM_F_MULTI) < 0)
 			break;
diff --git a/net/can/gw.c b/net/can/gw.c
index b54d5e6..127879c 100644
--- a/net/can/gw.c
+++ b/net/can/gw.c
@@ -549,7 +549,7 @@ static int cgw_dump_jobs(struct sk_buff *skb, struct netlink_callback *cb)
 		if (idx < s_idx)
 			goto cont;
 
-		if (cgw_put_job(skb, gwj, RTM_NEWROUTE, NETLINK_CB(cb->skb).pid,
+		if (cgw_put_job(skb, gwj, RTM_NEWROUTE, NETLINK_CB(cb->skb).portid,
 		    cb->nlh->nlmsg_seq, NLM_F_MULTI) < 0)
 			break;
 cont:
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index ab7db83..58a4ba2 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -402,7 +402,7 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 	if (unresolved)
 		ops->unresolved_rules++;
 
-	notify_rule_change(RTM_NEWRULE, rule, ops, nlh, NETLINK_CB(skb).pid);
+	notify_rule_change(RTM_NEWRULE, rule, ops, nlh, NETLINK_CB(skb).portid);
 	flush_route_cache(ops);
 	rules_ops_put(ops);
 	return 0;
@@ -500,7 +500,7 @@ static int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 		}
 
 		notify_rule_change(RTM_DELRULE, rule, ops, nlh,
-				   NETLINK_CB(skb).pid);
+				   NETLINK_CB(skb).portid);
 		if (ops->delete)
 			ops->delete(rule);
 		fib_rule_put(rule);
@@ -601,7 +601,7 @@ static int dump_rules(struct sk_buff *skb, struct netlink_callback *cb,
 		if (idx < cb->args[1])
 			goto skip;
 
-		if (fib_nl_fill_rule(skb, rule, NETLINK_CB(cb->skb).pid,
+		if (fib_nl_fill_rule(skb, rule, NETLINK_CB(cb->skb).portid,
 				     cb->nlh->nlmsg_seq, RTM_NEWRULE,
 				     NLM_F_MULTI, ops) < 0)
 			break;
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 117afaf..c160adb 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2102,7 +2102,7 @@ static int neightbl_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
 		if (tidx < tbl_skip || (family && tbl->family != family))
 			continue;
 
-		if (neightbl_fill_info(skb, tbl, NETLINK_CB(cb->skb).pid,
+		if (neightbl_fill_info(skb, tbl, NETLINK_CB(cb->skb).portid,
 				       cb->nlh->nlmsg_seq, RTM_NEWNEIGHTBL,
 				       NLM_F_MULTI) <= 0)
 			break;
@@ -2115,7 +2115,7 @@ static int neightbl_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
 				goto next;
 
 			if (neightbl_fill_param_info(skb, tbl, p,
-						     NETLINK_CB(cb->skb).pid,
+						     NETLINK_CB(cb->skb).portid,
 						     cb->nlh->nlmsg_seq,
 						     RTM_NEWNEIGHTBL,
 						     NLM_F_MULTI) <= 0)
@@ -2244,7 +2244,7 @@ static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 				continue;
 			if (idx < s_idx)
 				goto next;
-			if (neigh_fill_info(skb, n, NETLINK_CB(cb->skb).pid,
+			if (neigh_fill_info(skb, n, NETLINK_CB(cb->skb).portid,
 					    cb->nlh->nlmsg_seq,
 					    RTM_NEWNEIGH,
 					    NLM_F_MULTI) <= 0) {
@@ -2281,7 +2281,7 @@ static int pneigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 				continue;
 			if (idx < s_idx)
 				goto next;
-			if (pneigh_fill_info(skb, n, NETLINK_CB(cb->skb).pid,
+			if (pneigh_fill_info(skb, n, NETLINK_CB(cb->skb).portid,
 					    cb->nlh->nlmsg_seq,
 					    RTM_NEWNEIGH,
 					    NLM_F_MULTI, tbl) <= 0) {
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index c64efcf..579097a 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1081,7 +1081,7 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 			if (idx < s_idx)
 				goto cont;
 			if (rtnl_fill_ifinfo(skb, dev, RTM_NEWLINK,
-					     NETLINK_CB(cb->skb).pid,
+					     NETLINK_CB(cb->skb).portid,
 					     cb->nlh->nlmsg_seq, 0,
 					     NLM_F_MULTI,
 					     ext_filter_mask) <= 0)
@@ -1899,14 +1899,14 @@ static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 	if (nskb == NULL)
 		return -ENOBUFS;
 
-	err = rtnl_fill_ifinfo(nskb, dev, RTM_NEWLINK, NETLINK_CB(skb).pid,
+	err = rtnl_fill_ifinfo(nskb, dev, RTM_NEWLINK, NETLINK_CB(skb).portid,
 			       nlh->nlmsg_seq, 0, 0, ext_filter_mask);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in if_nlmsg_size */
 		WARN_ON(err == -EMSGSIZE);
 		kfree_skb(nskb);
 	} else
-		err = rtnl_unicast(nskb, net, NETLINK_CB(skb).pid);
+		err = rtnl_unicast(nskb, net, NETLINK_CB(skb).portid);
 
 	return err;
 }
@@ -2180,9 +2180,9 @@ static int nlmsg_populate_fdb(struct sk_buff *skb,
 {
 	struct netdev_hw_addr *ha;
 	int err;
-	u32 pid, seq;
+	u32 portid, seq;
 
-	pid = NETLINK_CB(cb->skb).pid;
+	portid = NETLINK_CB(cb->skb).portid;
 	seq = cb->nlh->nlmsg_seq;
 
 	list_for_each_entry(ha, &list->list, list) {
@@ -2190,7 +2190,7 @@ static int nlmsg_populate_fdb(struct sk_buff *skb,
 			goto skip;
 
 		err = nlmsg_populate_fdb_fill(skb, dev, ha->addr,
-					      pid, seq, 0, NTF_SELF);
+					      portid, seq, 0, NTF_SELF);
 		if (err < 0)
 			return err;
 skip:
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 81f2bb6..70989e6 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1319,7 +1319,7 @@ nla_put_failure:
 }
 
 static int dcbnl_notify(struct net_device *dev, int event, int cmd,
-			u32 seq, u32 pid, int dcbx_ver)
+			u32 seq, u32 portid, int dcbx_ver)
 {
 	struct net *net = dev_net(dev);
 	struct sk_buff *skb;
@@ -1330,7 +1330,7 @@ static int dcbnl_notify(struct net_device *dev, int event, int cmd,
 	if (!ops)
 		return -EOPNOTSUPP;
 
-	skb = dcbnl_newmsg(event, cmd, pid, seq, 0, &nlh);
+	skb = dcbnl_newmsg(event, cmd, portid, seq, 0, &nlh);
 	if (!skb)
 		return -ENOBUFS;
 
@@ -1353,16 +1353,16 @@ static int dcbnl_notify(struct net_device *dev, int event, int cmd,
 }
 
 int dcbnl_ieee_notify(struct net_device *dev, int event, int cmd,
-		      u32 seq, u32 pid)
+		      u32 seq, u32 portid)
 {
-	return dcbnl_notify(dev, event, cmd, seq, pid, DCB_CAP_DCBX_VER_IEEE);
+	return dcbnl_notify(dev, event, cmd, seq, portid, DCB_CAP_DCBX_VER_IEEE);
 }
 EXPORT_SYMBOL(dcbnl_ieee_notify);
 
 int dcbnl_cee_notify(struct net_device *dev, int event, int cmd,
-		     u32 seq, u32 pid)
+		     u32 seq, u32 portid)
 {
-	return dcbnl_notify(dev, event, cmd, seq, pid, DCB_CAP_DCBX_VER_CEE);
+	return dcbnl_notify(dev, event, cmd, seq, portid, DCB_CAP_DCBX_VER_CEE);
 }
 EXPORT_SYMBOL(dcbnl_cee_notify);
 
@@ -1656,7 +1656,7 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	struct net_device *netdev;
 	struct dcbmsg *dcb = nlmsg_data(nlh);
 	struct nlattr *tb[DCB_ATTR_MAX + 1];
-	u32 pid = skb ? NETLINK_CB(skb).pid : 0;
+	u32 portid = skb ? NETLINK_CB(skb).portid : 0;
 	int ret = -EINVAL;
 	struct sk_buff *reply_skb;
 	struct nlmsghdr *reply_nlh = NULL;
@@ -1690,7 +1690,7 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		goto out;
 	}
 
-	reply_skb = dcbnl_newmsg(fn->type, dcb->cmd, pid, nlh->nlmsg_seq,
+	reply_skb = dcbnl_newmsg(fn->type, dcb->cmd, portid, nlh->nlmsg_seq,
 				 nlh->nlmsg_flags, &reply_nlh);
 	if (!reply_skb) {
 		ret = -ENOBUFS;
@@ -1705,7 +1705,7 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 
 	nlmsg_end(reply_skb, reply_nlh);
 
-	ret = rtnl_unicast(reply_skb, &init_net, pid);
+	ret = rtnl_unicast(reply_skb, &init_net, portid);
 out:
 	dev_put(netdev);
 	return ret;
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index f3924ab..7b7e561 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -667,12 +667,12 @@ static inline size_t dn_ifaddr_nlmsg_size(void)
 }
 
 static int dn_nl_fill_ifaddr(struct sk_buff *skb, struct dn_ifaddr *ifa,
-			     u32 pid, u32 seq, int event, unsigned int flags)
+			     u32 portid, u32 seq, int event, unsigned int flags)
 {
 	struct ifaddrmsg *ifm;
 	struct nlmsghdr *nlh;
 
-	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*ifm), flags);
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*ifm), flags);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
@@ -753,7 +753,7 @@ static int dn_nl_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
 			if (dn_idx < skip_naddr)
 				continue;
 
-			if (dn_nl_fill_ifaddr(skb, ifa, NETLINK_CB(cb->skb).pid,
+			if (dn_nl_fill_ifaddr(skb, ifa, NETLINK_CB(cb->skb).portid,
 					      cb->nlh->nlmsg_seq, RTM_NEWADDR,
 					      NLM_F_MULTI) < 0)
 				goto done;
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index c855e8d..b57419c 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1543,7 +1543,7 @@ static int dn_route_input(struct sk_buff *skb)
 	return dn_route_input_slow(skb);
 }
 
-static int dn_rt_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
+static int dn_rt_fill_info(struct sk_buff *skb, u32 portid, u32 seq,
 			   int event, int nowait, unsigned int flags)
 {
 	struct dn_route *rt = (struct dn_route *)skb_dst(skb);
@@ -1551,7 +1551,7 @@ static int dn_rt_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
 	struct nlmsghdr *nlh;
 	long expires;
 
-	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*r), flags);
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*r), flags);
 	if (!nlh)
 		return -EMSGSIZE;
 
@@ -1685,7 +1685,7 @@ static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void
 	if (rtm->rtm_flags & RTM_F_NOTIFY)
 		rt->rt_flags |= RTCF_NOTIFY;
 
-	err = dn_rt_fill_info(skb, NETLINK_CB(in_skb).pid, nlh->nlmsg_seq, RTM_NEWROUTE, 0, 0);
+	err = dn_rt_fill_info(skb, NETLINK_CB(in_skb).portid, nlh->nlmsg_seq, RTM_NEWROUTE, 0, 0);
 
 	if (err == 0)
 		goto out_free;
@@ -1694,7 +1694,7 @@ static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void
 		goto out_free;
 	}
 
-	return rtnl_unicast(skb, &init_net, NETLINK_CB(in_skb).pid);
+	return rtnl_unicast(skb, &init_net, NETLINK_CB(in_skb).portid);
 
 out_free:
 	kfree_skb(skb);
@@ -1737,7 +1737,7 @@ int dn_cache_dump(struct sk_buff *skb, struct netlink_callback *cb)
 			if (idx < s_idx)
 				continue;
 			skb_dst_set(skb, dst_clone(&rt->dst));
-			if (dn_rt_fill_info(skb, NETLINK_CB(cb->skb).pid,
+			if (dn_rt_fill_info(skb, NETLINK_CB(cb->skb).portid,
 					cb->nlh->nlmsg_seq, RTM_NEWROUTE,
 					1, NLM_F_MULTI) <= 0) {
 				skb_dst_drop(skb);
diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
index 16c986a..f968c1b 100644
--- a/net/decnet/dn_table.c
+++ b/net/decnet/dn_table.c
@@ -291,14 +291,14 @@ static inline size_t dn_fib_nlmsg_size(struct dn_fib_info *fi)
 	return payload;
 }
 
-static int dn_fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
+static int dn_fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 			u32 tb_id, u8 type, u8 scope, void *dst, int dst_len,
 			struct dn_fib_info *fi, unsigned int flags)
 {
 	struct rtmsg *rtm;
 	struct nlmsghdr *nlh;
 
-	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*rtm), flags);
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*rtm), flags);
 	if (!nlh)
 		return -EMSGSIZE;
 
@@ -374,14 +374,14 @@ static void dn_rtmsg_fib(int event, struct dn_fib_node *f, int z, u32 tb_id,
 			struct nlmsghdr *nlh, struct netlink_skb_parms *req)
 {
 	struct sk_buff *skb;
-	u32 pid = req ? req->pid : 0;
+	u32 portid = req ? req->portid : 0;
 	int err = -ENOBUFS;
 
 	skb = nlmsg_new(dn_fib_nlmsg_size(DN_FIB_INFO(f)), GFP_KERNEL);
 	if (skb == NULL)
 		goto errout;
 
-	err = dn_fib_dump_info(skb, pid, nlh->nlmsg_seq, event, tb_id,
+	err = dn_fib_dump_info(skb, portid, nlh->nlmsg_seq, event, tb_id,
 			       f->fn_type, f->fn_scope, &f->fn_key, z,
 			       DN_FIB_INFO(f), 0);
 	if (err < 0) {
@@ -390,7 +390,7 @@ static void dn_rtmsg_fib(int event, struct dn_fib_node *f, int z, u32 tb_id,
 		kfree_skb(skb);
 		goto errout;
 	}
-	rtnl_notify(skb, &init_net, pid, RTNLGRP_DECnet_ROUTE, nlh, GFP_KERNEL);
+	rtnl_notify(skb, &init_net, portid, RTNLGRP_DECnet_ROUTE, nlh, GFP_KERNEL);
 	return;
 errout:
 	if (err < 0)
@@ -411,7 +411,7 @@ static __inline__ int dn_hash_dump_bucket(struct sk_buff *skb,
 			continue;
 		if (f->fn_state & DN_S_ZOMBIE)
 			continue;
-		if (dn_fib_dump_info(skb, NETLINK_CB(cb->skb).pid,
+		if (dn_fib_dump_info(skb, NETLINK_CB(cb->skb).portid,
 				cb->nlh->nlmsg_seq,
 				RTM_NEWROUTE,
 				tb->n,
diff --git a/net/ieee802154/nl-mac.c b/net/ieee802154/nl-mac.c
index 1e99171..96bb08a 100644
--- a/net/ieee802154/nl-mac.c
+++ b/net/ieee802154/nl-mac.c
@@ -246,7 +246,7 @@ nla_put_failure:
 }
 EXPORT_SYMBOL(ieee802154_nl_start_confirm);
 
-static int ieee802154_nl_fill_iface(struct sk_buff *msg, u32 pid,
+static int ieee802154_nl_fill_iface(struct sk_buff *msg, u32 portid,
 	u32 seq, int flags, struct net_device *dev)
 {
 	void *hdr;
@@ -534,7 +534,7 @@ static int ieee802154_list_iface(struct sk_buff *skb,
 	if (!msg)
 		goto out_dev;
 
-	rc = ieee802154_nl_fill_iface(msg, info->snd_pid, info->snd_seq,
+	rc = ieee802154_nl_fill_iface(msg, info->snd_portid, info->snd_seq,
 			0, dev);
 	if (rc < 0)
 		goto out_free;
@@ -565,7 +565,7 @@ static int ieee802154_dump_iface(struct sk_buff *skb,
 		if (idx < s_idx || (dev->type != ARPHRD_IEEE802154))
 			goto cont;
 
-		if (ieee802154_nl_fill_iface(skb, NETLINK_CB(cb->skb).pid,
+		if (ieee802154_nl_fill_iface(skb, NETLINK_CB(cb->skb).portid,
 			cb->nlh->nlmsg_seq, NLM_F_MULTI, dev) < 0)
 			break;
 cont:
diff --git a/net/ieee802154/nl-phy.c b/net/ieee802154/nl-phy.c
index d54be34..22b1a70 100644
--- a/net/ieee802154/nl-phy.c
+++ b/net/ieee802154/nl-phy.c
@@ -35,7 +35,7 @@
 
 #include "ieee802154.h"
 
-static int ieee802154_nl_fill_phy(struct sk_buff *msg, u32 pid,
+static int ieee802154_nl_fill_phy(struct sk_buff *msg, u32 portid,
 	u32 seq, int flags, struct wpan_phy *phy)
 {
 	void *hdr;
@@ -105,7 +105,7 @@ static int ieee802154_list_phy(struct sk_buff *skb,
 	if (!msg)
 		goto out_dev;
 
-	rc = ieee802154_nl_fill_phy(msg, info->snd_pid, info->snd_seq,
+	rc = ieee802154_nl_fill_phy(msg, info->snd_portid, info->snd_seq,
 			0, phy);
 	if (rc < 0)
 		goto out_free;
@@ -138,7 +138,7 @@ static int ieee802154_dump_phy_iter(struct wpan_phy *phy, void *_data)
 		return 0;
 
 	rc = ieee802154_nl_fill_phy(data->skb,
-			NETLINK_CB(data->cb->skb).pid,
+			NETLINK_CB(data->cb->skb).portid,
 			data->cb->nlh->nlmsg_seq,
 			NLM_F_MULTI,
 			phy);
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index adf273f..c369639 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -311,7 +311,7 @@ int inet_addr_onlink(struct in_device *in_dev, __be32 a, __be32 b)
 }
 
 static void __inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
-			 int destroy, struct nlmsghdr *nlh, u32 pid)
+			 int destroy, struct nlmsghdr *nlh, u32 portid)
 {
 	struct in_ifaddr *promote = NULL;
 	struct in_ifaddr *ifa, *ifa1 = *ifap;
@@ -345,7 +345,7 @@ static void __inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
 				inet_hash_remove(ifa);
 				*ifap1 = ifa->ifa_next;
 
-				rtmsg_ifa(RTM_DELADDR, ifa, nlh, pid);
+				rtmsg_ifa(RTM_DELADDR, ifa, nlh, portid);
 				blocking_notifier_call_chain(&inetaddr_chain,
 						NETDEV_DOWN, ifa);
 				inet_free_ifa(ifa);
@@ -382,7 +382,7 @@ static void __inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
 	   is valid, it will try to restore deleted routes... Grr.
 	   So that, this order is correct.
 	 */
-	rtmsg_ifa(RTM_DELADDR, ifa1, nlh, pid);
+	rtmsg_ifa(RTM_DELADDR, ifa1, nlh, portid);
 	blocking_notifier_call_chain(&inetaddr_chain, NETDEV_DOWN, ifa1);
 
 	if (promote) {
@@ -395,7 +395,7 @@ static void __inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
 		}
 
 		promote->ifa_flags &= ~IFA_F_SECONDARY;
-		rtmsg_ifa(RTM_NEWADDR, promote, nlh, pid);
+		rtmsg_ifa(RTM_NEWADDR, promote, nlh, portid);
 		blocking_notifier_call_chain(&inetaddr_chain,
 				NETDEV_UP, promote);
 		for (ifa = next_sec; ifa; ifa = ifa->ifa_next) {
@@ -417,7 +417,7 @@ static void inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
 }
 
 static int __inet_insert_ifa(struct in_ifaddr *ifa, struct nlmsghdr *nlh,
-			     u32 pid)
+			     u32 portid)
 {
 	struct in_device *in_dev = ifa->ifa_dev;
 	struct in_ifaddr *ifa1, **ifap, **last_primary;
@@ -464,7 +464,7 @@ static int __inet_insert_ifa(struct in_ifaddr *ifa, struct nlmsghdr *nlh,
 	/* Send message first, then call notifier.
 	   Notifier will trigger FIB update, so that
 	   listeners of netlink will know about new ifaddr */
-	rtmsg_ifa(RTM_NEWADDR, ifa, nlh, pid);
+	rtmsg_ifa(RTM_NEWADDR, ifa, nlh, portid);
 	blocking_notifier_call_chain(&inetaddr_chain, NETDEV_UP, ifa);
 
 	return 0;
@@ -563,7 +563,7 @@ static int inet_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg
 		    !inet_ifa_match(nla_get_be32(tb[IFA_ADDRESS]), ifa)))
 			continue;
 
-		__inet_del_ifa(in_dev, ifap, 1, nlh, NETLINK_CB(skb).pid);
+		__inet_del_ifa(in_dev, ifap, 1, nlh, NETLINK_CB(skb).portid);
 		return 0;
 	}
 
@@ -649,7 +649,7 @@ static int inet_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg
 	if (IS_ERR(ifa))
 		return PTR_ERR(ifa);
 
-	return __inet_insert_ifa(ifa, nlh, NETLINK_CB(skb).pid);
+	return __inet_insert_ifa(ifa, nlh, NETLINK_CB(skb).portid);
 }
 
 /*
@@ -1246,12 +1246,12 @@ static size_t inet_nlmsg_size(void)
 }
 
 static int inet_fill_ifaddr(struct sk_buff *skb, struct in_ifaddr *ifa,
-			    u32 pid, u32 seq, int event, unsigned int flags)
+			    u32 portid, u32 seq, int event, unsigned int flags)
 {
 	struct ifaddrmsg *ifm;
 	struct nlmsghdr  *nlh;
 
-	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*ifm), flags);
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*ifm), flags);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
@@ -1313,7 +1313,7 @@ static int inet_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
 				if (ip_idx < s_ip_idx)
 					continue;
 				if (inet_fill_ifaddr(skb, ifa,
-					     NETLINK_CB(cb->skb).pid,
+					     NETLINK_CB(cb->skb).portid,
 					     cb->nlh->nlmsg_seq,
 					     RTM_NEWADDR, NLM_F_MULTI) <= 0) {
 					rcu_read_unlock();
@@ -1335,7 +1335,7 @@ done:
 }
 
 static void rtmsg_ifa(int event, struct in_ifaddr *ifa, struct nlmsghdr *nlh,
-		      u32 pid)
+		      u32 portid)
 {
 	struct sk_buff *skb;
 	u32 seq = nlh ? nlh->nlmsg_seq : 0;
@@ -1347,14 +1347,14 @@ static void rtmsg_ifa(int event, struct in_ifaddr *ifa, struct nlmsghdr *nlh,
 	if (skb == NULL)
 		goto errout;
 
-	err = inet_fill_ifaddr(skb, ifa, pid, seq, event, 0);
+	err = inet_fill_ifaddr(skb, ifa, portid, seq, event, 0);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in inet_nlmsg_size() */
 		WARN_ON(err == -EMSGSIZE);
 		kfree_skb(skb);
 		goto errout;
 	}
-	rtnl_notify(skb, net, pid, RTNLGRP_IPV4_IFADDR, nlh, GFP_KERNEL);
+	rtnl_notify(skb, net, portid, RTNLGRP_IPV4_IFADDR, nlh, GFP_KERNEL);
 	return;
 errout:
 	if (err < 0)
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index acdee32..78ccb60 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -557,7 +557,7 @@ static int rtm_to_fib_config(struct net *net, struct sk_buff *skb,
 	cfg->fc_flags = rtm->rtm_flags;
 	cfg->fc_nlflags = nlh->nlmsg_flags;
 
-	cfg->fc_nlinfo.pid = NETLINK_CB(skb).pid;
+	cfg->fc_nlinfo.portid = NETLINK_CB(skb).portid;
 	cfg->fc_nlinfo.nlh = nlh;
 	cfg->fc_nlinfo.nl_net = net;
 
@@ -955,7 +955,7 @@ static void nl_fib_input(struct sk_buff *skb)
 	struct fib_result_nl *frn;
 	struct nlmsghdr *nlh;
 	struct fib_table *tb;
-	u32 pid;
+	u32 portid;
 
 	net = sock_net(skb->sk);
 	nlh = nlmsg_hdr(skb);
@@ -973,10 +973,10 @@ static void nl_fib_input(struct sk_buff *skb)
 
 	nl_fib_lookup(frn, tb);
 
-	pid = NETLINK_CB(skb).pid;      /* pid of sending process */
-	NETLINK_CB(skb).pid = 0;        /* from kernel */
+	portid = NETLINK_CB(skb).portid;      /* pid of sending process */
+	NETLINK_CB(skb).portid = 0;        /* from kernel */
 	NETLINK_CB(skb).dst_group = 0;  /* unicast */
-	netlink_unicast(net->ipv4.fibnl, skb, pid, MSG_DONTWAIT);
+	netlink_unicast(net->ipv4.fibnl, skb, portid, MSG_DONTWAIT);
 }
 
 static int __net_init nl_fib_lookup_init(struct net *net)
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index da80dc1..3509065 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -391,7 +391,7 @@ void rtmsg_fib(int event, __be32 key, struct fib_alias *fa,
 	if (skb == NULL)
 		goto errout;
 
-	err = fib_dump_info(skb, info->pid, seq, event, tb_id,
+	err = fib_dump_info(skb, info->portid, seq, event, tb_id,
 			    fa->fa_type, key, dst_len,
 			    fa->fa_tos, fa->fa_info, nlm_flags);
 	if (err < 0) {
@@ -400,7 +400,7 @@ void rtmsg_fib(int event, __be32 key, struct fib_alias *fa,
 		kfree_skb(skb);
 		goto errout;
 	}
-	rtnl_notify(skb, info->nl_net, info->pid, RTNLGRP_IPV4_ROUTE,
+	rtnl_notify(skb, info->nl_net, info->portid, RTNLGRP_IPV4_ROUTE,
 		    info->nlh, GFP_KERNEL);
 	return;
 errout:
@@ -989,14 +989,14 @@ failure:
 	return ERR_PTR(err);
 }
 
-int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
+int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 		  u32 tb_id, u8 type, __be32 dst, int dst_len, u8 tos,
 		  struct fib_info *fi, unsigned int flags)
 {
 	struct nlmsghdr *nlh;
 	struct rtmsg *rtm;
 
-	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*rtm), flags);
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*rtm), flags);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 3c820da..340de6d 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1873,7 +1873,7 @@ static int fn_trie_dump_fa(t_key key, int plen, struct list_head *fah,
 			continue;
 		}
 
-		if (fib_dump_info(skb, NETLINK_CB(cb->skb).pid,
+		if (fib_dump_info(skb, NETLINK_CB(cb->skb).portid,
 				  cb->nlh->nlmsg_seq,
 				  RTM_NEWROUTE,
 				  tb->tb_id,
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 8bc005b..535584c 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -70,7 +70,7 @@ static inline void inet_diag_unlock_handler(
 int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 			      struct sk_buff *skb, struct inet_diag_req_v2 *req,
 			      struct user_namespace *user_ns,		      	
-			      u32 pid, u32 seq, u16 nlmsg_flags,
+			      u32 portid, u32 seq, u16 nlmsg_flags,
 			      const struct nlmsghdr *unlh)
 {
 	const struct inet_sock *inet = inet_sk(sk);
@@ -84,7 +84,7 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 	handler = inet_diag_table[req->sdiag_protocol];
 	BUG_ON(handler == NULL);
 
-	nlh = nlmsg_put(skb, pid, seq, unlh->nlmsg_type, sizeof(*r),
+	nlh = nlmsg_put(skb, portid, seq, unlh->nlmsg_type, sizeof(*r),
 			nlmsg_flags);
 	if (!nlh)
 		return -EMSGSIZE;
@@ -201,23 +201,23 @@ EXPORT_SYMBOL_GPL(inet_sk_diag_fill);
 static int inet_csk_diag_fill(struct sock *sk,
 			      struct sk_buff *skb, struct inet_diag_req_v2 *req,
 			      struct user_namespace *user_ns,
-			      u32 pid, u32 seq, u16 nlmsg_flags,
+			      u32 portid, u32 seq, u16 nlmsg_flags,
 			      const struct nlmsghdr *unlh)
 {
 	return inet_sk_diag_fill(sk, inet_csk(sk),
-			skb, req, user_ns, pid, seq, nlmsg_flags, unlh);
+			skb, req, user_ns, portid, seq, nlmsg_flags, unlh);
 }
 
 static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
 			       struct sk_buff *skb, struct inet_diag_req_v2 *req,
-			       u32 pid, u32 seq, u16 nlmsg_flags,
+			       u32 portid, u32 seq, u16 nlmsg_flags,
 			       const struct nlmsghdr *unlh)
 {
 	long tmo;
 	struct inet_diag_msg *r;
 	struct nlmsghdr *nlh;
 
-	nlh = nlmsg_put(skb, pid, seq, unlh->nlmsg_type, sizeof(*r),
+	nlh = nlmsg_put(skb, portid, seq, unlh->nlmsg_type, sizeof(*r),
 			nlmsg_flags);
 	if (!nlh)
 		return -EMSGSIZE;
@@ -260,14 +260,14 @@ static int inet_twsk_diag_fill(struct inet_timewait_sock *tw,
 static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 			struct inet_diag_req_v2 *r,
 			struct user_namespace *user_ns,
-			u32 pid, u32 seq, u16 nlmsg_flags,
+			u32 portid, u32 seq, u16 nlmsg_flags,
 			const struct nlmsghdr *unlh)
 {
 	if (sk->sk_state == TCP_TIME_WAIT)
 		return inet_twsk_diag_fill((struct inet_timewait_sock *)sk,
-					   skb, r, pid, seq, nlmsg_flags,
+					   skb, r, portid, seq, nlmsg_flags,
 					   unlh);
-	return inet_csk_diag_fill(sk, skb, r, user_ns, pid, seq, nlmsg_flags, unlh);
+	return inet_csk_diag_fill(sk, skb, r, user_ns, portid, seq, nlmsg_flags, unlh);
 }
 
 int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *in_skb,
@@ -316,14 +316,14 @@ int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *in_s
 
 	err = sk_diag_fill(sk, rep, req,
 			   sk_user_ns(NETLINK_CB(in_skb).ssk),
-			   NETLINK_CB(in_skb).pid,
+			   NETLINK_CB(in_skb).portid,
 			   nlh->nlmsg_seq, 0, nlh);
 	if (err < 0) {
 		WARN_ON(err == -EMSGSIZE);
 		nlmsg_free(rep);
 		goto out;
 	}
-	err = netlink_unicast(net->diag_nlsk, rep, NETLINK_CB(in_skb).pid,
+	err = netlink_unicast(net->diag_nlsk, rep, NETLINK_CB(in_skb).portid,
 			      MSG_DONTWAIT);
 	if (err > 0)
 		err = 0;
@@ -557,7 +557,7 @@ static int inet_csk_diag_dump(struct sock *sk,
 
 	return inet_csk_diag_fill(sk, skb, r,
 				  sk_user_ns(NETLINK_CB(cb->skb).ssk),
-				  NETLINK_CB(cb->skb).pid,
+				  NETLINK_CB(cb->skb).portid,
 				  cb->nlh->nlmsg_seq, NLM_F_MULTI, cb->nlh);
 }
 
@@ -592,14 +592,14 @@ static int inet_twsk_diag_dump(struct inet_timewait_sock *tw,
 	}
 
 	return inet_twsk_diag_fill(tw, skb, r,
-				   NETLINK_CB(cb->skb).pid,
+				   NETLINK_CB(cb->skb).portid,
 				   cb->nlh->nlmsg_seq, NLM_F_MULTI, cb->nlh);
 }
 
 static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
 			      struct request_sock *req,
 			      struct user_namespace *user_ns,
-			      u32 pid, u32 seq,
+			      u32 portid, u32 seq,
 			      const struct nlmsghdr *unlh)
 {
 	const struct inet_request_sock *ireq = inet_rsk(req);
@@ -608,7 +608,7 @@ static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
 	struct nlmsghdr *nlh;
 	long tmo;
 
-	nlh = nlmsg_put(skb, pid, seq, unlh->nlmsg_type, sizeof(*r),
+	nlh = nlmsg_put(skb, portid, seq, unlh->nlmsg_type, sizeof(*r),
 			NLM_F_MULTI);
 	if (!nlh)
 		return -EMSGSIZE;
@@ -711,7 +711,7 @@ static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
 
 			err = inet_diag_fill_req(skb, sk, req,
 					       sk_user_ns(NETLINK_CB(cb->skb).ssk),
-					       NETLINK_CB(cb->skb).pid,
+					       NETLINK_CB(cb->skb).portid,
 					       cb->nlh->nlmsg_seq, cb->nlh);
 			if (err < 0) {
 				cb->args[3] = j + 1;
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 8aa7a4c..1daa95c 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -626,7 +626,7 @@ static void ipmr_destroy_unres(struct mr_table *mrt, struct mfc_cache *c)
 			e->error = -ETIMEDOUT;
 			memset(&e->msg, 0, sizeof(e->msg));
 
-			rtnl_unicast(skb, net, NETLINK_CB(skb).pid);
+			rtnl_unicast(skb, net, NETLINK_CB(skb).portid);
 		} else {
 			kfree_skb(skb);
 		}
@@ -870,7 +870,7 @@ static void ipmr_cache_resolve(struct net *net, struct mr_table *mrt,
 				memset(&e->msg, 0, sizeof(e->msg));
 			}
 
-			rtnl_unicast(skb, net, NETLINK_CB(skb).pid);
+			rtnl_unicast(skb, net, NETLINK_CB(skb).portid);
 		} else {
 			ip_mr_forward(net, mrt, skb, c, 0);
 		}
@@ -2117,12 +2117,12 @@ int ipmr_get_route(struct net *net, struct sk_buff *skb,
 }
 
 static int ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
-			    u32 pid, u32 seq, struct mfc_cache *c)
+			    u32 portid, u32 seq, struct mfc_cache *c)
 {
 	struct nlmsghdr *nlh;
 	struct rtmsg *rtm;
 
-	nlh = nlmsg_put(skb, pid, seq, RTM_NEWROUTE, sizeof(*rtm), NLM_F_MULTI);
+	nlh = nlmsg_put(skb, portid, seq, RTM_NEWROUTE, sizeof(*rtm), NLM_F_MULTI);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
@@ -2176,7 +2176,7 @@ static int ipmr_rtm_dumproute(struct sk_buff *skb, struct netlink_callback *cb)
 				if (e < s_e)
 					goto next_entry;
 				if (ipmr_fill_mroute(mrt, skb,
-						     NETLINK_CB(cb->skb).pid,
+						     NETLINK_CB(cb->skb).portid,
 						     cb->nlh->nlmsg_seq,
 						     mfc) < 0)
 					goto done;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index dc9549b..37f742f 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2154,7 +2154,7 @@ struct rtable *ip_route_output_flow(struct net *net, struct flowi4 *flp4,
 EXPORT_SYMBOL_GPL(ip_route_output_flow);
 
 static int rt_fill_info(struct net *net,  __be32 dst, __be32 src,
-			struct flowi4 *fl4, struct sk_buff *skb, u32 pid,
+			struct flowi4 *fl4, struct sk_buff *skb, u32 portid,
 			u32 seq, int event, int nowait, unsigned int flags)
 {
 	struct rtable *rt = skb_rtable(skb);
@@ -2164,7 +2164,7 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src,
 	u32 error;
 	u32 metrics[RTAX_MAX];
 
-	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*r), flags);
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*r), flags);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
@@ -2324,12 +2324,12 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void
 		rt->rt_flags |= RTCF_NOTIFY;
 
 	err = rt_fill_info(net, dst, src, &fl4, skb,
-			   NETLINK_CB(in_skb).pid, nlh->nlmsg_seq,
+			   NETLINK_CB(in_skb).portid, nlh->nlmsg_seq,
 			   RTM_NEWROUTE, 0, 0);
 	if (err <= 0)
 		goto errout_free;
 
-	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).pid);
+	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid);
 errout:
 	return err;
 
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 988edb6..4c752a6 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -803,7 +803,7 @@ static int tcp_metrics_dump_info(struct sk_buff *skb,
 {
 	void *hdr;
 
-	hdr = genlmsg_put(skb, NETLINK_CB(cb->skb).pid, cb->nlh->nlmsg_seq,
+	hdr = genlmsg_put(skb, NETLINK_CB(cb->skb).portid, cb->nlh->nlmsg_seq,
 			  &tcp_metrics_nl_family, NLM_F_MULTI,
 			  TCP_METRICS_CMD_GET);
 	if (!hdr)
diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index d2f336e..505b30a 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -26,7 +26,7 @@ static int sk_diag_dump(struct sock *sk, struct sk_buff *skb,
 
 	return inet_sk_diag_fill(sk, NULL, skb, req,
 			sk_user_ns(NETLINK_CB(cb->skb).ssk),
-			NETLINK_CB(cb->skb).pid,
+			NETLINK_CB(cb->skb).portid,
 			cb->nlh->nlmsg_seq, NLM_F_MULTI, cb->nlh);
 }
 
@@ -72,14 +72,14 @@ static int udp_dump_one(struct udp_table *tbl, struct sk_buff *in_skb,
 
 	err = inet_sk_diag_fill(sk, NULL, rep, req,
 			   sk_user_ns(NETLINK_CB(in_skb).ssk),
-			   NETLINK_CB(in_skb).pid,
+			   NETLINK_CB(in_skb).portid,
 			   nlh->nlmsg_seq, 0, nlh);
 	if (err < 0) {
 		WARN_ON(err == -EMSGSIZE);
 		kfree_skb(rep);
 		goto out;
 	}
-	err = netlink_unicast(net->diag_nlsk, rep, NETLINK_CB(in_skb).pid,
+	err = netlink_unicast(net->diag_nlsk, rep, NETLINK_CB(in_skb).portid,
 			      MSG_DONTWAIT);
 	if (err > 0)
 		err = 0;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 572cb66..1237d5d 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3534,12 +3534,12 @@ static inline int inet6_ifaddr_msgsize(void)
 }
 
 static int inet6_fill_ifaddr(struct sk_buff *skb, struct inet6_ifaddr *ifa,
-			     u32 pid, u32 seq, int event, unsigned int flags)
+			     u32 portid, u32 seq, int event, unsigned int flags)
 {
 	struct nlmsghdr  *nlh;
 	u32 preferred, valid;
 
-	nlh = nlmsg_put(skb, pid, seq, event, sizeof(struct ifaddrmsg), flags);
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(struct ifaddrmsg), flags);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
@@ -3577,7 +3577,7 @@ static int inet6_fill_ifaddr(struct sk_buff *skb, struct inet6_ifaddr *ifa,
 }
 
 static int inet6_fill_ifmcaddr(struct sk_buff *skb, struct ifmcaddr6 *ifmca,
-				u32 pid, u32 seq, int event, u16 flags)
+				u32 portid, u32 seq, int event, u16 flags)
 {
 	struct nlmsghdr  *nlh;
 	u8 scope = RT_SCOPE_UNIVERSE;
@@ -3586,7 +3586,7 @@ static int inet6_fill_ifmcaddr(struct sk_buff *skb, struct ifmcaddr6 *ifmca,
 	if (ipv6_addr_scope(&ifmca->mca_addr) & IFA_SITE)
 		scope = RT_SCOPE_SITE;
 
-	nlh = nlmsg_put(skb, pid, seq, event, sizeof(struct ifaddrmsg), flags);
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(struct ifaddrmsg), flags);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
@@ -3602,7 +3602,7 @@ static int inet6_fill_ifmcaddr(struct sk_buff *skb, struct ifmcaddr6 *ifmca,
 }
 
 static int inet6_fill_ifacaddr(struct sk_buff *skb, struct ifacaddr6 *ifaca,
-				u32 pid, u32 seq, int event, unsigned int flags)
+				u32 portid, u32 seq, int event, unsigned int flags)
 {
 	struct nlmsghdr  *nlh;
 	u8 scope = RT_SCOPE_UNIVERSE;
@@ -3611,7 +3611,7 @@ static int inet6_fill_ifacaddr(struct sk_buff *skb, struct ifacaddr6 *ifaca,
 	if (ipv6_addr_scope(&ifaca->aca_addr) & IFA_SITE)
 		scope = RT_SCOPE_SITE;
 
-	nlh = nlmsg_put(skb, pid, seq, event, sizeof(struct ifaddrmsg), flags);
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(struct ifaddrmsg), flags);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
@@ -3652,7 +3652,7 @@ static int in6_dump_addrs(struct inet6_dev *idev, struct sk_buff *skb,
 			if (++ip_idx < s_ip_idx)
 				continue;
 			err = inet6_fill_ifaddr(skb, ifa,
-						NETLINK_CB(cb->skb).pid,
+						NETLINK_CB(cb->skb).portid,
 						cb->nlh->nlmsg_seq,
 						RTM_NEWADDR,
 						NLM_F_MULTI);
@@ -3668,7 +3668,7 @@ static int in6_dump_addrs(struct inet6_dev *idev, struct sk_buff *skb,
 			if (ip_idx < s_ip_idx)
 				continue;
 			err = inet6_fill_ifmcaddr(skb, ifmca,
-						  NETLINK_CB(cb->skb).pid,
+						  NETLINK_CB(cb->skb).portid,
 						  cb->nlh->nlmsg_seq,
 						  RTM_GETMULTICAST,
 						  NLM_F_MULTI);
@@ -3683,7 +3683,7 @@ static int in6_dump_addrs(struct inet6_dev *idev, struct sk_buff *skb,
 			if (ip_idx < s_ip_idx)
 				continue;
 			err = inet6_fill_ifacaddr(skb, ifaca,
-						  NETLINK_CB(cb->skb).pid,
+						  NETLINK_CB(cb->skb).portid,
 						  cb->nlh->nlmsg_seq,
 						  RTM_GETANYCAST,
 						  NLM_F_MULTI);
@@ -3805,7 +3805,7 @@ static int inet6_rtm_getaddr(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 		goto errout_ifa;
 	}
 
-	err = inet6_fill_ifaddr(skb, ifa, NETLINK_CB(in_skb).pid,
+	err = inet6_fill_ifaddr(skb, ifa, NETLINK_CB(in_skb).portid,
 				nlh->nlmsg_seq, RTM_NEWADDR, 0);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in inet6_ifaddr_msgsize() */
@@ -3813,7 +3813,7 @@ static int inet6_rtm_getaddr(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 		kfree_skb(skb);
 		goto errout_ifa;
 	}
-	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).pid);
+	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid);
 errout_ifa:
 	in6_ifa_put(ifa);
 errout:
@@ -4015,14 +4015,14 @@ static int inet6_fill_link_af(struct sk_buff *skb, const struct net_device *dev)
 }
 
 static int inet6_fill_ifinfo(struct sk_buff *skb, struct inet6_dev *idev,
-			     u32 pid, u32 seq, int event, unsigned int flags)
+			     u32 portid, u32 seq, int event, unsigned int flags)
 {
 	struct net_device *dev = idev->dev;
 	struct ifinfomsg *hdr;
 	struct nlmsghdr *nlh;
 	void *protoinfo;
 
-	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*hdr), flags);
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*hdr), flags);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
@@ -4080,7 +4080,7 @@ static int inet6_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 			if (!idev)
 				goto cont;
 			if (inet6_fill_ifinfo(skb, idev,
-					      NETLINK_CB(cb->skb).pid,
+					      NETLINK_CB(cb->skb).portid,
 					      cb->nlh->nlmsg_seq,
 					      RTM_NEWLINK, NLM_F_MULTI) <= 0)
 				goto out;
@@ -4128,14 +4128,14 @@ static inline size_t inet6_prefix_nlmsg_size(void)
 }
 
 static int inet6_fill_prefix(struct sk_buff *skb, struct inet6_dev *idev,
-			     struct prefix_info *pinfo, u32 pid, u32 seq,
+			     struct prefix_info *pinfo, u32 portid, u32 seq,
 			     int event, unsigned int flags)
 {
 	struct prefixmsg *pmsg;
 	struct nlmsghdr *nlh;
 	struct prefix_cacheinfo	ci;
 
-	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*pmsg), flags);
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*pmsg), flags);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index eb6a636..0b01715 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -470,10 +470,10 @@ static void ip6addrlbl_putmsg(struct nlmsghdr *nlh,
 static int ip6addrlbl_fill(struct sk_buff *skb,
 			   struct ip6addrlbl_entry *p,
 			   u32 lseq,
-			   u32 pid, u32 seq, int event,
+			   u32 portid, u32 seq, int event,
 			   unsigned int flags)
 {
-	struct nlmsghdr *nlh = nlmsg_put(skb, pid, seq, event,
+	struct nlmsghdr *nlh = nlmsg_put(skb, portid, seq, event,
 					 sizeof(struct ifaddrlblmsg), flags);
 	if (!nlh)
 		return -EMSGSIZE;
@@ -503,7 +503,7 @@ static int ip6addrlbl_dump(struct sk_buff *skb, struct netlink_callback *cb)
 		    net_eq(ip6addrlbl_net(p), net)) {
 			if ((err = ip6addrlbl_fill(skb, p,
 						   ip6addrlbl_table.seq,
-						   NETLINK_CB(cb->skb).pid,
+						   NETLINK_CB(cb->skb).portid,
 						   cb->nlh->nlmsg_seq,
 						   RTM_NEWADDRLABEL,
 						   NLM_F_MULTI)) <= 0)
@@ -574,7 +574,7 @@ static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr* nlh,
 	}
 
 	err = ip6addrlbl_fill(skb, p, lseq,
-			      NETLINK_CB(in_skb).pid, nlh->nlmsg_seq,
+			      NETLINK_CB(in_skb).portid, nlh->nlmsg_seq,
 			      RTM_NEWADDRLABEL, 0);
 
 	ip6addrlbl_put(p);
@@ -585,7 +585,7 @@ static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr* nlh,
 		goto out;
 	}
 
-	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).pid);
+	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid);
 out:
 	return err;
 }
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 4532973..08ea3f0b 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -838,7 +838,7 @@ static void ip6mr_destroy_unres(struct mr6_table *mrt, struct mfc6_cache *c)
 			nlh->nlmsg_len = NLMSG_LENGTH(sizeof(struct nlmsgerr));
 			skb_trim(skb, nlh->nlmsg_len);
 			((struct nlmsgerr *)NLMSG_DATA(nlh))->error = -ETIMEDOUT;
-			rtnl_unicast(skb, net, NETLINK_CB(skb).pid);
+			rtnl_unicast(skb, net, NETLINK_CB(skb).portid);
 		} else
 			kfree_skb(skb);
 	}
@@ -1052,7 +1052,7 @@ static void ip6mr_cache_resolve(struct net *net, struct mr6_table *mrt,
 				skb_trim(skb, nlh->nlmsg_len);
 				((struct nlmsgerr *)NLMSG_DATA(nlh))->error = -EMSGSIZE;
 			}
-			rtnl_unicast(skb, net, NETLINK_CB(skb).pid);
+			rtnl_unicast(skb, net, NETLINK_CB(skb).portid);
 		} else
 			ip6_mr_forward(net, mrt, skb, c);
 	}
@@ -2202,12 +2202,12 @@ int ip6mr_get_route(struct net *net,
 }
 
 static int ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
-			     u32 pid, u32 seq, struct mfc6_cache *c)
+			     u32 portid, u32 seq, struct mfc6_cache *c)
 {
 	struct nlmsghdr *nlh;
 	struct rtmsg *rtm;
 
-	nlh = nlmsg_put(skb, pid, seq, RTM_NEWROUTE, sizeof(*rtm), NLM_F_MULTI);
+	nlh = nlmsg_put(skb, portid, seq, RTM_NEWROUTE, sizeof(*rtm), NLM_F_MULTI);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
@@ -2260,7 +2260,7 @@ static int ip6mr_rtm_dumproute(struct sk_buff *skb, struct netlink_callback *cb)
 				if (e < s_e)
 					goto next_entry;
 				if (ip6mr_fill_mroute(mrt, skb,
-						      NETLINK_CB(cb->skb).pid,
+						      NETLINK_CB(cb->skb).portid,
 						      cb->nlh->nlmsg_seq,
 						      mfc) < 0)
 					goto done;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index fa26444..06db38f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1871,7 +1871,7 @@ static struct rt6_info *rt6_add_route_info(struct net *net,
 		.fc_dst_len	= prefixlen,
 		.fc_flags	= RTF_GATEWAY | RTF_ADDRCONF | RTF_ROUTEINFO |
 				  RTF_UP | RTF_PREF(pref),
-		.fc_nlinfo.pid = 0,
+		.fc_nlinfo.portid = 0,
 		.fc_nlinfo.nlh = NULL,
 		.fc_nlinfo.nl_net = net,
 	};
@@ -1921,7 +1921,7 @@ struct rt6_info *rt6_add_dflt_router(const struct in6_addr *gwaddr,
 		.fc_ifindex	= dev->ifindex,
 		.fc_flags	= RTF_GATEWAY | RTF_ADDRCONF | RTF_DEFAULT |
 				  RTF_UP | RTF_EXPIRES | RTF_PREF(pref),
-		.fc_nlinfo.pid = 0,
+		.fc_nlinfo.portid = 0,
 		.fc_nlinfo.nlh = NULL,
 		.fc_nlinfo.nl_net = dev_net(dev),
 	};
@@ -2281,7 +2281,7 @@ static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (rtm->rtm_type == RTN_LOCAL)
 		cfg->fc_flags |= RTF_LOCAL;
 
-	cfg->fc_nlinfo.pid = NETLINK_CB(skb).pid;
+	cfg->fc_nlinfo.portid = NETLINK_CB(skb).portid;
 	cfg->fc_nlinfo.nlh = nlh;
 	cfg->fc_nlinfo.nl_net = sock_net(skb->sk);
 
@@ -2372,7 +2372,7 @@ static inline size_t rt6_nlmsg_size(void)
 static int rt6_fill_node(struct net *net,
 			 struct sk_buff *skb, struct rt6_info *rt,
 			 struct in6_addr *dst, struct in6_addr *src,
-			 int iif, int type, u32 pid, u32 seq,
+			 int iif, int type, u32 portid, u32 seq,
 			 int prefix, int nowait, unsigned int flags)
 {
 	struct rtmsg *rtm;
@@ -2388,7 +2388,7 @@ static int rt6_fill_node(struct net *net,
 		}
 	}
 
-	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*rtm), flags);
+	nlh = nlmsg_put(skb, portid, seq, type, sizeof(*rtm), flags);
 	if (!nlh)
 		return -EMSGSIZE;
 
@@ -2530,7 +2530,7 @@ int rt6_dump_route(struct rt6_info *rt, void *p_arg)
 
 	return rt6_fill_node(arg->net,
 		     arg->skb, rt, NULL, NULL, 0, RTM_NEWROUTE,
-		     NETLINK_CB(arg->cb->skb).pid, arg->cb->nlh->nlmsg_seq,
+		     NETLINK_CB(arg->cb->skb).portid, arg->cb->nlh->nlmsg_seq,
 		     prefix, 0, NLM_F_MULTI);
 }
 
@@ -2610,14 +2610,14 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 	skb_dst_set(skb, &rt->dst);
 
 	err = rt6_fill_node(net, skb, rt, &fl6.daddr, &fl6.saddr, iif,
-			    RTM_NEWROUTE, NETLINK_CB(in_skb).pid,
+			    RTM_NEWROUTE, NETLINK_CB(in_skb).portid,
 			    nlh->nlmsg_seq, 0, 0, 0);
 	if (err < 0) {
 		kfree_skb(skb);
 		goto errout;
 	}
 
-	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).pid);
+	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid);
 errout:
 	return err;
 }
@@ -2637,14 +2637,14 @@ void inet6_rt_notify(int event, struct rt6_info *rt, struct nl_info *info)
 		goto errout;
 
 	err = rt6_fill_node(net, skb, rt, NULL, NULL, 0,
-				event, info->pid, seq, 0, 0, 0);
+				event, info->portid, seq, 0, 0, 0);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in rt6_nlmsg_size() */
 		WARN_ON(err == -EMSGSIZE);
 		kfree_skb(skb);
 		goto errout;
 	}
-	rtnl_notify(skb, net, info->pid, RTNLGRP_IPV6_ROUTE,
+	rtnl_notify(skb, net, info->portid, RTNLGRP_IPV6_ROUTE,
 		    info->nlh, gfp_any());
 	return;
 errout:
diff --git a/net/irda/irnetlink.c b/net/irda/irnetlink.c
index 6c7c4b9..c329712 100644
--- a/net/irda/irnetlink.c
+++ b/net/irda/irnetlink.c
@@ -100,7 +100,7 @@ static int irda_nl_get_mode(struct sk_buff *skb, struct genl_info *info)
 		goto err_out;
 	}
 
-	hdr = genlmsg_put(msg, info->snd_pid, info->snd_seq,
+	hdr = genlmsg_put(msg, info->snd_portid, info->snd_seq,
 			  &irda_nl_family, 0,  IRDA_NL_CMD_GET_MODE);
 	if (hdr == NULL) {
 		ret = -EMSGSIZE;
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 334f93b..2ca7d7f 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -54,7 +54,7 @@ struct pfkey_sock {
 
 	struct {
 		uint8_t		msg_version;
-		uint32_t	msg_pid;
+		uint32_t	msg_portid;
 		int		(*dump)(struct pfkey_sock *sk);
 		void		(*done)(struct pfkey_sock *sk);
 		union {
@@ -1447,7 +1447,7 @@ static int key_notify_sa(struct xfrm_state *x, const struct km_event *c)
 	hdr->sadb_msg_errno = 0;
 	hdr->sadb_msg_reserved = 0;
 	hdr->sadb_msg_seq = c->seq;
-	hdr->sadb_msg_pid = c->pid;
+	hdr->sadb_msg_pid = c->portid;
 
 	pfkey_broadcast(skb, GFP_ATOMIC, BROADCAST_ALL, NULL, xs_net(x));
 
@@ -1486,7 +1486,7 @@ static int pfkey_add(struct sock *sk, struct sk_buff *skb, const struct sadb_msg
 	else
 		c.event = XFRM_MSG_UPDSA;
 	c.seq = hdr->sadb_msg_seq;
-	c.pid = hdr->sadb_msg_pid;
+	c.portid = hdr->sadb_msg_pid;
 	km_state_notify(x, &c);
 out:
 	xfrm_state_put(x);
@@ -1523,7 +1523,7 @@ static int pfkey_delete(struct sock *sk, struct sk_buff *skb, const struct sadb_
 		goto out;
 
 	c.seq = hdr->sadb_msg_seq;
-	c.pid = hdr->sadb_msg_pid;
+	c.portid = hdr->sadb_msg_pid;
 	c.event = XFRM_MSG_DELSA;
 	km_state_notify(x, &c);
 out:
@@ -1701,7 +1701,7 @@ static int key_notify_sa_flush(const struct km_event *c)
 	hdr->sadb_msg_satype = pfkey_proto2satype(c->data.proto);
 	hdr->sadb_msg_type = SADB_FLUSH;
 	hdr->sadb_msg_seq = c->seq;
-	hdr->sadb_msg_pid = c->pid;
+	hdr->sadb_msg_pid = c->portid;
 	hdr->sadb_msg_version = PF_KEY_V2;
 	hdr->sadb_msg_errno = (uint8_t) 0;
 	hdr->sadb_msg_len = (sizeof(struct sadb_msg) / sizeof(uint64_t));
@@ -1736,7 +1736,7 @@ static int pfkey_flush(struct sock *sk, struct sk_buff *skb, const struct sadb_m
 
 	c.data.proto = proto;
 	c.seq = hdr->sadb_msg_seq;
-	c.pid = hdr->sadb_msg_pid;
+	c.portid = hdr->sadb_msg_pid;
 	c.event = XFRM_MSG_FLUSHSA;
 	c.net = net;
 	km_state_notify(NULL, &c);
@@ -1764,7 +1764,7 @@ static int dump_sa(struct xfrm_state *x, int count, void *ptr)
 	out_hdr->sadb_msg_errno = 0;
 	out_hdr->sadb_msg_reserved = 0;
 	out_hdr->sadb_msg_seq = count + 1;
-	out_hdr->sadb_msg_pid = pfk->dump.msg_pid;
+	out_hdr->sadb_msg_pid = pfk->dump.msg_portid;
 
 	if (pfk->dump.skb)
 		pfkey_broadcast(pfk->dump.skb, GFP_ATOMIC, BROADCAST_ONE,
@@ -1798,7 +1798,7 @@ static int pfkey_dump(struct sock *sk, struct sk_buff *skb, const struct sadb_ms
 		return -EINVAL;
 
 	pfk->dump.msg_version = hdr->sadb_msg_version;
-	pfk->dump.msg_pid = hdr->sadb_msg_pid;
+	pfk->dump.msg_portid = hdr->sadb_msg_pid;
 	pfk->dump.dump = pfkey_dump_sa;
 	pfk->dump.done = pfkey_dump_sa_done;
 	xfrm_state_walk_init(&pfk->dump.u.state, proto);
@@ -2157,7 +2157,7 @@ static int key_notify_policy(struct xfrm_policy *xp, int dir, const struct km_ev
 		out_hdr->sadb_msg_type = event2poltype(c->event);
 	out_hdr->sadb_msg_errno = 0;
 	out_hdr->sadb_msg_seq = c->seq;
-	out_hdr->sadb_msg_pid = c->pid;
+	out_hdr->sadb_msg_pid = c->portid;
 	pfkey_broadcast(out_skb, GFP_ATOMIC, BROADCAST_ALL, NULL, xp_net(xp));
 	return 0;
 
@@ -2272,7 +2272,7 @@ static int pfkey_spdadd(struct sock *sk, struct sk_buff *skb, const struct sadb_
 		c.event = XFRM_MSG_NEWPOLICY;
 
 	c.seq = hdr->sadb_msg_seq;
-	c.pid = hdr->sadb_msg_pid;
+	c.portid = hdr->sadb_msg_pid;
 
 	km_policy_notify(xp, pol->sadb_x_policy_dir-1, &c);
 	xfrm_pol_put(xp);
@@ -2351,7 +2351,7 @@ static int pfkey_spddelete(struct sock *sk, struct sk_buff *skb, const struct sa
 		goto out;
 
 	c.seq = hdr->sadb_msg_seq;
-	c.pid = hdr->sadb_msg_pid;
+	c.portid = hdr->sadb_msg_pid;
 	c.data.byid = 0;
 	c.event = XFRM_MSG_DELPOLICY;
 	km_policy_notify(xp, pol->sadb_x_policy_dir-1, &c);
@@ -2597,7 +2597,7 @@ static int pfkey_spdget(struct sock *sk, struct sk_buff *skb, const struct sadb_
 		if (err)
 			goto out;
 		c.seq = hdr->sadb_msg_seq;
-		c.pid = hdr->sadb_msg_pid;
+		c.portid = hdr->sadb_msg_pid;
 		c.data.byid = 1;
 		c.event = XFRM_MSG_DELPOLICY;
 		km_policy_notify(xp, dir, &c);
@@ -2634,7 +2634,7 @@ static int dump_sp(struct xfrm_policy *xp, int dir, int count, void *ptr)
 	out_hdr->sadb_msg_satype = SADB_SATYPE_UNSPEC;
 	out_hdr->sadb_msg_errno = 0;
 	out_hdr->sadb_msg_seq = count + 1;
-	out_hdr->sadb_msg_pid = pfk->dump.msg_pid;
+	out_hdr->sadb_msg_pid = pfk->dump.msg_portid;
 
 	if (pfk->dump.skb)
 		pfkey_broadcast(pfk->dump.skb, GFP_ATOMIC, BROADCAST_ONE,
@@ -2663,7 +2663,7 @@ static int pfkey_spddump(struct sock *sk, struct sk_buff *skb, const struct sadb
 		return -EBUSY;
 
 	pfk->dump.msg_version = hdr->sadb_msg_version;
-	pfk->dump.msg_pid = hdr->sadb_msg_pid;
+	pfk->dump.msg_portid = hdr->sadb_msg_pid;
 	pfk->dump.dump = pfkey_dump_sp;
 	pfk->dump.done = pfkey_dump_sp_done;
 	xfrm_policy_walk_init(&pfk->dump.u.policy, XFRM_POLICY_TYPE_MAIN);
@@ -2682,7 +2682,7 @@ static int key_notify_policy_flush(const struct km_event *c)
 	hdr = (struct sadb_msg *) skb_put(skb_out, sizeof(struct sadb_msg));
 	hdr->sadb_msg_type = SADB_X_SPDFLUSH;
 	hdr->sadb_msg_seq = c->seq;
-	hdr->sadb_msg_pid = c->pid;
+	hdr->sadb_msg_pid = c->portid;
 	hdr->sadb_msg_version = PF_KEY_V2;
 	hdr->sadb_msg_errno = (uint8_t) 0;
 	hdr->sadb_msg_len = (sizeof(struct sadb_msg) / sizeof(uint64_t));
@@ -2711,7 +2711,7 @@ static int pfkey_spdflush(struct sock *sk, struct sk_buff *skb, const struct sad
 
 	c.data.type = XFRM_POLICY_TYPE_MAIN;
 	c.event = XFRM_MSG_FLUSHPOLICY;
-	c.pid = hdr->sadb_msg_pid;
+	c.portid = hdr->sadb_msg_pid;
 	c.seq = hdr->sadb_msg_seq;
 	c.net = net;
 	km_policy_notify(NULL, 0, &c);
diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index d71cd92..6ec3f67 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -78,7 +78,7 @@ static int l2tp_nl_cmd_noop(struct sk_buff *skb, struct genl_info *info)
 		goto out;
 	}
 
-	hdr = genlmsg_put(msg, info->snd_pid, info->snd_seq,
+	hdr = genlmsg_put(msg, info->snd_portid, info->snd_seq,
 			  &l2tp_nl_family, 0, L2TP_CMD_NOOP);
 	if (IS_ERR(hdr)) {
 		ret = PTR_ERR(hdr);
@@ -87,7 +87,7 @@ static int l2tp_nl_cmd_noop(struct sk_buff *skb, struct genl_info *info)
 
 	genlmsg_end(msg, hdr);
 
-	return genlmsg_unicast(genl_info_net(info), msg, info->snd_pid);
+	return genlmsg_unicast(genl_info_net(info), msg, info->snd_portid);
 
 err_out:
 	nlmsg_free(msg);
@@ -235,7 +235,7 @@ out:
 	return ret;
 }
 
-static int l2tp_nl_tunnel_send(struct sk_buff *skb, u32 pid, u32 seq, int flags,
+static int l2tp_nl_tunnel_send(struct sk_buff *skb, u32 portid, u32 seq, int flags,
 			       struct l2tp_tunnel *tunnel)
 {
 	void *hdr;
@@ -248,7 +248,7 @@ static int l2tp_nl_tunnel_send(struct sk_buff *skb, u32 pid, u32 seq, int flags,
 	struct l2tp_stats stats;
 	unsigned int start;
 
-	hdr = genlmsg_put(skb, pid, seq, &l2tp_nl_family, flags,
+	hdr = genlmsg_put(skb, portid, seq, &l2tp_nl_family, flags,
 			  L2TP_CMD_TUNNEL_GET);
 	if (IS_ERR(hdr))
 		return PTR_ERR(hdr);
@@ -359,12 +359,12 @@ static int l2tp_nl_cmd_tunnel_get(struct sk_buff *skb, struct genl_info *info)
 		goto out;
 	}
 
-	ret = l2tp_nl_tunnel_send(msg, info->snd_pid, info->snd_seq,
+	ret = l2tp_nl_tunnel_send(msg, info->snd_portid, info->snd_seq,
 				  NLM_F_ACK, tunnel);
 	if (ret < 0)
 		goto err_out;
 
-	return genlmsg_unicast(net, msg, info->snd_pid);
+	return genlmsg_unicast(net, msg, info->snd_portid);
 
 err_out:
 	nlmsg_free(msg);
@@ -384,7 +384,7 @@ static int l2tp_nl_cmd_tunnel_dump(struct sk_buff *skb, struct netlink_callback
 		if (tunnel == NULL)
 			goto out;
 
-		if (l2tp_nl_tunnel_send(skb, NETLINK_CB(cb->skb).pid,
+		if (l2tp_nl_tunnel_send(skb, NETLINK_CB(cb->skb).portid,
 					cb->nlh->nlmsg_seq, NLM_F_MULTI,
 					tunnel) <= 0)
 			goto out;
@@ -604,7 +604,7 @@ out:
 	return ret;
 }
 
-static int l2tp_nl_session_send(struct sk_buff *skb, u32 pid, u32 seq, int flags,
+static int l2tp_nl_session_send(struct sk_buff *skb, u32 portid, u32 seq, int flags,
 				struct l2tp_session *session)
 {
 	void *hdr;
@@ -616,7 +616,7 @@ static int l2tp_nl_session_send(struct sk_buff *skb, u32 pid, u32 seq, int flags
 
 	sk = tunnel->sock;
 
-	hdr = genlmsg_put(skb, pid, seq, &l2tp_nl_family, flags, L2TP_CMD_SESSION_GET);
+	hdr = genlmsg_put(skb, portid, seq, &l2tp_nl_family, flags, L2TP_CMD_SESSION_GET);
 	if (IS_ERR(hdr))
 		return PTR_ERR(hdr);
 
@@ -705,12 +705,12 @@ static int l2tp_nl_cmd_session_get(struct sk_buff *skb, struct genl_info *info)
 		goto out;
 	}
 
-	ret = l2tp_nl_session_send(msg, info->snd_pid, info->snd_seq,
+	ret = l2tp_nl_session_send(msg, info->snd_portid, info->snd_seq,
 				   0, session);
 	if (ret < 0)
 		goto err_out;
 
-	return genlmsg_unicast(genl_info_net(info), msg, info->snd_pid);
+	return genlmsg_unicast(genl_info_net(info), msg, info->snd_portid);
 
 err_out:
 	nlmsg_free(msg);
@@ -742,7 +742,7 @@ static int l2tp_nl_cmd_session_dump(struct sk_buff *skb, struct netlink_callback
 			continue;
 		}
 
-		if (l2tp_nl_session_send(skb, NETLINK_CB(cb->skb).pid,
+		if (l2tp_nl_session_send(skb, NETLINK_CB(cb->skb).portid,
 					 cb->nlh->nlmsg_seq, NLM_F_MULTI,
 					 session) <= 0)
 			break;
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 9730882..ad39ef4 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -563,13 +563,13 @@ flag_exist(const struct nlmsghdr *nlh)
 }
 
 static struct nlmsghdr *
-start_msg(struct sk_buff *skb, u32 pid, u32 seq, unsigned int flags,
+start_msg(struct sk_buff *skb, u32 portid, u32 seq, unsigned int flags,
 	  enum ipset_cmd cmd)
 {
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
 
-	nlh = nlmsg_put(skb, pid, seq, cmd | (NFNL_SUBSYS_IPSET << 8),
+	nlh = nlmsg_put(skb, portid, seq, cmd | (NFNL_SUBSYS_IPSET << 8),
 			sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		return NULL;
@@ -1045,7 +1045,7 @@ ip_set_dump_start(struct sk_buff *skb, struct netlink_callback *cb)
 	ip_set_id_t index = IPSET_INVALID_ID, max;
 	struct ip_set *set = NULL;
 	struct nlmsghdr *nlh = NULL;
-	unsigned int flags = NETLINK_CB(cb->skb).pid ? NLM_F_MULTI : 0;
+	unsigned int flags = NETLINK_CB(cb->skb).portid ? NLM_F_MULTI : 0;
 	u32 dump_type, dump_flags;
 	int ret = 0;
 
@@ -1093,7 +1093,7 @@ dump_last:
 			pr_debug("reference set\n");
 			__ip_set_get(index);
 		}
-		nlh = start_msg(skb, NETLINK_CB(cb->skb).pid,
+		nlh = start_msg(skb, NETLINK_CB(cb->skb).portid,
 				cb->nlh->nlmsg_seq, flags,
 				IPSET_CMD_LIST);
 		if (!nlh) {
@@ -1226,7 +1226,7 @@ call_ad(struct sock *ctnl, struct sk_buff *skb, struct ip_set *set,
 		skb2 = nlmsg_new(payload, GFP_KERNEL);
 		if (skb2 == NULL)
 			return -ENOMEM;
-		rep = __nlmsg_put(skb2, NETLINK_CB(skb).pid,
+		rep = __nlmsg_put(skb2, NETLINK_CB(skb).portid,
 				  nlh->nlmsg_seq, NLMSG_ERROR, payload, 0);
 		errmsg = nlmsg_data(rep);
 		errmsg->error = ret;
@@ -1241,7 +1241,7 @@ call_ad(struct sock *ctnl, struct sk_buff *skb, struct ip_set *set,
 
 		*errline = lineno;
 
-		netlink_unicast(ctnl, skb2, NETLINK_CB(skb).pid, MSG_DONTWAIT);
+		netlink_unicast(ctnl, skb2, NETLINK_CB(skb).portid, MSG_DONTWAIT);
 		/* Signal netlink not to send its ACK/errmsg.  */
 		return -EINTR;
 	}
@@ -1416,7 +1416,7 @@ ip_set_header(struct sock *ctnl, struct sk_buff *skb,
 	if (skb2 == NULL)
 		return -ENOMEM;
 
-	nlh2 = start_msg(skb2, NETLINK_CB(skb).pid, nlh->nlmsg_seq, 0,
+	nlh2 = start_msg(skb2, NETLINK_CB(skb).portid, nlh->nlmsg_seq, 0,
 			 IPSET_CMD_HEADER);
 	if (!nlh2)
 		goto nlmsg_failure;
@@ -1428,7 +1428,7 @@ ip_set_header(struct sock *ctnl, struct sk_buff *skb,
 		goto nla_put_failure;
 	nlmsg_end(skb2, nlh2);
 
-	ret = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).pid, MSG_DONTWAIT);
+	ret = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).portid, MSG_DONTWAIT);
 	if (ret < 0)
 		return ret;
 
@@ -1476,7 +1476,7 @@ ip_set_type(struct sock *ctnl, struct sk_buff *skb,
 	if (skb2 == NULL)
 		return -ENOMEM;
 
-	nlh2 = start_msg(skb2, NETLINK_CB(skb).pid, nlh->nlmsg_seq, 0,
+	nlh2 = start_msg(skb2, NETLINK_CB(skb).portid, nlh->nlmsg_seq, 0,
 			 IPSET_CMD_TYPE);
 	if (!nlh2)
 		goto nlmsg_failure;
@@ -1489,7 +1489,7 @@ ip_set_type(struct sock *ctnl, struct sk_buff *skb,
 	nlmsg_end(skb2, nlh2);
 
 	pr_debug("Send TYPE, nlmsg_len: %u\n", nlh2->nlmsg_len);
-	ret = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).pid, MSG_DONTWAIT);
+	ret = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).portid, MSG_DONTWAIT);
 	if (ret < 0)
 		return ret;
 
@@ -1525,7 +1525,7 @@ ip_set_protocol(struct sock *ctnl, struct sk_buff *skb,
 	if (skb2 == NULL)
 		return -ENOMEM;
 
-	nlh2 = start_msg(skb2, NETLINK_CB(skb).pid, nlh->nlmsg_seq, 0,
+	nlh2 = start_msg(skb2, NETLINK_CB(skb).portid, nlh->nlmsg_seq, 0,
 			 IPSET_CMD_PROTOCOL);
 	if (!nlh2)
 		goto nlmsg_failure;
@@ -1533,7 +1533,7 @@ ip_set_protocol(struct sock *ctnl, struct sk_buff *skb,
 		goto nla_put_failure;
 	nlmsg_end(skb2, nlh2);
 
-	ret = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).pid, MSG_DONTWAIT);
+	ret = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).portid, MSG_DONTWAIT);
 	if (ret < 0)
 		return ret;
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 767cc12..0f924bf 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2939,7 +2939,7 @@ static int ip_vs_genl_dump_service(struct sk_buff *skb,
 {
 	void *hdr;
 
-	hdr = genlmsg_put(skb, NETLINK_CB(cb->skb).pid, cb->nlh->nlmsg_seq,
+	hdr = genlmsg_put(skb, NETLINK_CB(cb->skb).portid, cb->nlh->nlmsg_seq,
 			  &ip_vs_genl_family, NLM_F_MULTI,
 			  IPVS_CMD_NEW_SERVICE);
 	if (!hdr)
@@ -3128,7 +3128,7 @@ static int ip_vs_genl_dump_dest(struct sk_buff *skb, struct ip_vs_dest *dest,
 {
 	void *hdr;
 
-	hdr = genlmsg_put(skb, NETLINK_CB(cb->skb).pid, cb->nlh->nlmsg_seq,
+	hdr = genlmsg_put(skb, NETLINK_CB(cb->skb).portid, cb->nlh->nlmsg_seq,
 			  &ip_vs_genl_family, NLM_F_MULTI,
 			  IPVS_CMD_NEW_DEST);
 	if (!hdr)
@@ -3257,7 +3257,7 @@ static int ip_vs_genl_dump_daemon(struct sk_buff *skb, __be32 state,
 				  struct netlink_callback *cb)
 {
 	void *hdr;
-	hdr = genlmsg_put(skb, NETLINK_CB(cb->skb).pid, cb->nlh->nlmsg_seq,
+	hdr = genlmsg_put(skb, NETLINK_CB(cb->skb).portid, cb->nlh->nlmsg_seq,
 			  &ip_vs_genl_family, NLM_F_MULTI,
 			  IPVS_CMD_NEW_DAEMON);
 	if (!hdr)
diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index e7be79e..de9781b 100644
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -61,7 +61,7 @@ void nf_ct_deliver_cached_events(struct nf_conn *ct)
 		goto out_unlock;
 
 	item.ct = ct;
-	item.pid = 0;
+	item.portid = 0;
 	item.report = 0;
 
 	ret = notify->fcn(events | missed, &item);
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index a205bd6..5977003 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -418,16 +418,16 @@ nla_put_failure:
 }
 
 static int
-ctnetlink_fill_info(struct sk_buff *skb, u32 pid, u32 seq, u32 type,
+ctnetlink_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 		    struct nf_conn *ct)
 {
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
 	struct nlattr *nest_parms;
-	unsigned int flags = pid ? NLM_F_MULTI : 0, event;
+	unsigned int flags = portid ? NLM_F_MULTI : 0, event;
 
 	event = (NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_CT_NEW);
-	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*nfmsg), flags);
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
 
@@ -604,7 +604,7 @@ ctnetlink_conntrack_event(unsigned int events, struct nf_ct_event *item)
 		goto errout;
 
 	type |= NFNL_SUBSYS_CTNETLINK << 8;
-	nlh = nlmsg_put(skb, item->pid, 0, type, sizeof(*nfmsg), flags);
+	nlh = nlmsg_put(skb, item->portid, 0, type, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
 
@@ -680,7 +680,7 @@ ctnetlink_conntrack_event(unsigned int events, struct nf_ct_event *item)
 	rcu_read_unlock();
 
 	nlmsg_end(skb, nlh);
-	err = nfnetlink_send(skb, net, item->pid, group, item->report,
+	err = nfnetlink_send(skb, net, item->portid, group, item->report,
 			     GFP_ATOMIC);
 	if (err == -ENOBUFS || err == -EAGAIN)
 		return -ENOBUFS;
@@ -757,7 +757,7 @@ restart:
 #endif
 			rcu_read_lock();
 			res =
-			ctnetlink_fill_info(skb, NETLINK_CB(cb->skb).pid,
+			ctnetlink_fill_info(skb, NETLINK_CB(cb->skb).portid,
 					    cb->nlh->nlmsg_seq,
 					    NFNL_MSG_TYPE(cb->nlh->nlmsg_type),
 					    ct);
@@ -961,7 +961,7 @@ ctnetlink_del_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	else {
 		/* Flush the whole table */
 		nf_conntrack_flush_report(net,
-					 NETLINK_CB(skb).pid,
+					 NETLINK_CB(skb).portid,
 					 nlmsg_report(nlh));
 		return 0;
 	}
@@ -985,7 +985,7 @@ ctnetlink_del_conntrack(struct sock *ctnl, struct sk_buff *skb,
 
 	if (del_timer(&ct->timeout)) {
 		if (nf_conntrack_event_report(IPCT_DESTROY, ct,
-					      NETLINK_CB(skb).pid,
+					      NETLINK_CB(skb).portid,
 					      nlmsg_report(nlh)) < 0) {
 			nf_ct_delete_from_lists(ct);
 			/* we failed to report the event, try later */
@@ -1069,14 +1069,14 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	}
 
 	rcu_read_lock();
-	err = ctnetlink_fill_info(skb2, NETLINK_CB(skb).pid, nlh->nlmsg_seq,
+	err = ctnetlink_fill_info(skb2, NETLINK_CB(skb).portid, nlh->nlmsg_seq,
 				  NFNL_MSG_TYPE(nlh->nlmsg_type), ct);
 	rcu_read_unlock();
 	nf_ct_put(ct);
 	if (err <= 0)
 		goto free;
 
-	err = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).pid, MSG_DONTWAIT);
+	err = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).portid, MSG_DONTWAIT);
 	if (err < 0)
 		goto out;
 
@@ -1616,7 +1616,7 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 						      (1 << IPCT_PROTOINFO) |
 						      (1 << IPCT_NATSEQADJ) |
 						      (1 << IPCT_MARK) | events,
-						      ct, NETLINK_CB(skb).pid,
+						      ct, NETLINK_CB(skb).portid,
 						      nlmsg_report(nlh));
 			nf_ct_put(ct);
 		}
@@ -1638,7 +1638,7 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 						      (1 << IPCT_PROTOINFO) |
 						      (1 << IPCT_NATSEQADJ) |
 						      (1 << IPCT_MARK),
-						      ct, NETLINK_CB(skb).pid,
+						      ct, NETLINK_CB(skb).portid,
 						      nlmsg_report(nlh));
 		}
 	}
@@ -1648,15 +1648,15 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 }
 
 static int
-ctnetlink_ct_stat_cpu_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
+ctnetlink_ct_stat_cpu_fill_info(struct sk_buff *skb, u32 portid, u32 seq,
 				__u16 cpu, const struct ip_conntrack_stat *st)
 {
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
-	unsigned int flags = pid ? NLM_F_MULTI : 0, event;
+	unsigned int flags = portid ? NLM_F_MULTI : 0, event;
 
 	event = (NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_CT_GET_STATS_CPU);
-	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*nfmsg), flags);
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
 
@@ -1708,7 +1708,7 @@ ctnetlink_ct_stat_cpu_dump(struct sk_buff *skb, struct netlink_callback *cb)
 
 		st = per_cpu_ptr(net->ct.stat, cpu);
 		if (ctnetlink_ct_stat_cpu_fill_info(skb,
-						    NETLINK_CB(cb->skb).pid,
+						    NETLINK_CB(cb->skb).portid,
 						    cb->nlh->nlmsg_seq,
 						    cpu, st) < 0)
 				break;
@@ -1734,16 +1734,16 @@ ctnetlink_stat_ct_cpu(struct sock *ctnl, struct sk_buff *skb,
 }
 
 static int
-ctnetlink_stat_ct_fill_info(struct sk_buff *skb, u32 pid, u32 seq, u32 type,
+ctnetlink_stat_ct_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 			    struct net *net)
 {
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
-	unsigned int flags = pid ? NLM_F_MULTI : 0, event;
+	unsigned int flags = portid ? NLM_F_MULTI : 0, event;
 	unsigned int nr_conntracks = atomic_read(&net->ct.count);
 
 	event = (NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_CT_GET_STATS);
-	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*nfmsg), flags);
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
 
@@ -1776,14 +1776,14 @@ ctnetlink_stat_ct(struct sock *ctnl, struct sk_buff *skb,
 	if (skb2 == NULL)
 		return -ENOMEM;
 
-	err = ctnetlink_stat_ct_fill_info(skb2, NETLINK_CB(skb).pid,
+	err = ctnetlink_stat_ct_fill_info(skb2, NETLINK_CB(skb).portid,
 					  nlh->nlmsg_seq,
 					  NFNL_MSG_TYPE(nlh->nlmsg_type),
 					  sock_net(skb->sk));
 	if (err <= 0)
 		goto free;
 
-	err = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).pid, MSG_DONTWAIT);
+	err = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).portid, MSG_DONTWAIT);
 	if (err < 0)
 		goto out;
 
@@ -2073,15 +2073,15 @@ nla_put_failure:
 }
 
 static int
-ctnetlink_exp_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
+ctnetlink_exp_fill_info(struct sk_buff *skb, u32 portid, u32 seq,
 			int event, const struct nf_conntrack_expect *exp)
 {
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
-	unsigned int flags = pid ? NLM_F_MULTI : 0;
+	unsigned int flags = portid ? NLM_F_MULTI : 0;
 
 	event |= NFNL_SUBSYS_CTNETLINK_EXP << 8;
-	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*nfmsg), flags);
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
 
@@ -2132,7 +2132,7 @@ ctnetlink_expect_event(unsigned int events, struct nf_exp_event *item)
 		goto errout;
 
 	type |= NFNL_SUBSYS_CTNETLINK_EXP << 8;
-	nlh = nlmsg_put(skb, item->pid, 0, type, sizeof(*nfmsg), flags);
+	nlh = nlmsg_put(skb, item->portid, 0, type, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
 
@@ -2147,7 +2147,7 @@ ctnetlink_expect_event(unsigned int events, struct nf_exp_event *item)
 	rcu_read_unlock();
 
 	nlmsg_end(skb, nlh);
-	nfnetlink_send(skb, net, item->pid, group, item->report, GFP_ATOMIC);
+	nfnetlink_send(skb, net, item->portid, group, item->report, GFP_ATOMIC);
 	return 0;
 
 nla_put_failure:
@@ -2190,7 +2190,7 @@ restart:
 				cb->args[1] = 0;
 			}
 			if (ctnetlink_exp_fill_info(skb,
-						    NETLINK_CB(cb->skb).pid,
+						    NETLINK_CB(cb->skb).portid,
 						    cb->nlh->nlmsg_seq,
 						    IPCTNL_MSG_EXP_NEW,
 						    exp) < 0) {
@@ -2283,14 +2283,14 @@ ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
 	}
 
 	rcu_read_lock();
-	err = ctnetlink_exp_fill_info(skb2, NETLINK_CB(skb).pid,
+	err = ctnetlink_exp_fill_info(skb2, NETLINK_CB(skb).portid,
 				      nlh->nlmsg_seq, IPCTNL_MSG_EXP_NEW, exp);
 	rcu_read_unlock();
 	nf_ct_expect_put(exp);
 	if (err <= 0)
 		goto free;
 
-	err = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).pid, MSG_DONTWAIT);
+	err = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).portid, MSG_DONTWAIT);
 	if (err < 0)
 		goto out;
 
@@ -2344,7 +2344,7 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 		/* after list removal, usage count == 1 */
 		spin_lock_bh(&nf_conntrack_lock);
 		if (del_timer(&exp->timeout)) {
-			nf_ct_unlink_expect_report(exp, NETLINK_CB(skb).pid,
+			nf_ct_unlink_expect_report(exp, NETLINK_CB(skb).portid,
 						   nlmsg_report(nlh));
 			nf_ct_expect_put(exp);
 		}
@@ -2366,7 +2366,7 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 				if (!strcmp(m_help->helper->name, name) &&
 				    del_timer(&exp->timeout)) {
 					nf_ct_unlink_expect_report(exp,
-							NETLINK_CB(skb).pid,
+							NETLINK_CB(skb).portid,
 							nlmsg_report(nlh));
 					nf_ct_expect_put(exp);
 				}
@@ -2382,7 +2382,7 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 						  hnode) {
 				if (del_timer(&exp->timeout)) {
 					nf_ct_unlink_expect_report(exp,
-							NETLINK_CB(skb).pid,
+							NETLINK_CB(skb).portid,
 							nlmsg_report(nlh));
 					nf_ct_expect_put(exp);
 				}
@@ -2447,7 +2447,7 @@ static int
 ctnetlink_create_expect(struct net *net, u16 zone,
 			const struct nlattr * const cda[],
 			u_int8_t u3,
-			u32 pid, int report)
+			u32 portid, int report)
 {
 	struct nf_conntrack_tuple tuple, mask, master_tuple;
 	struct nf_conntrack_tuple_hash *h = NULL;
@@ -2560,7 +2560,7 @@ ctnetlink_create_expect(struct net *net, u16 zone,
 		if (err < 0)
 			goto err_out;
 	}
-	err = nf_ct_expect_related_report(exp, pid, report);
+	err = nf_ct_expect_related_report(exp, portid, report);
 err_out:
 	nf_ct_expect_put(exp);
 out:
@@ -2603,7 +2603,7 @@ ctnetlink_new_expect(struct sock *ctnl, struct sk_buff *skb,
 		if (nlh->nlmsg_flags & NLM_F_CREATE) {
 			err = ctnetlink_create_expect(net, zone, cda,
 						      u3,
-						      NETLINK_CB(skb).pid,
+						      NETLINK_CB(skb).portid,
 						      nlmsg_report(nlh));
 		}
 		return err;
@@ -2618,15 +2618,15 @@ ctnetlink_new_expect(struct sock *ctnl, struct sk_buff *skb,
 }
 
 static int
-ctnetlink_exp_stat_fill_info(struct sk_buff *skb, u32 pid, u32 seq, int cpu,
+ctnetlink_exp_stat_fill_info(struct sk_buff *skb, u32 portid, u32 seq, int cpu,
 			     const struct ip_conntrack_stat *st)
 {
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
-	unsigned int flags = pid ? NLM_F_MULTI : 0, event;
+	unsigned int flags = portid ? NLM_F_MULTI : 0, event;
 
 	event = (NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_EXP_GET_STATS_CPU);
-	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*nfmsg), flags);
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
 
@@ -2665,7 +2665,7 @@ ctnetlink_exp_stat_cpu_dump(struct sk_buff *skb, struct netlink_callback *cb)
 			continue;
 
 		st = per_cpu_ptr(net->ct.stat, cpu);
-		if (ctnetlink_exp_stat_fill_info(skb, NETLINK_CB(cb->skb).pid,
+		if (ctnetlink_exp_stat_fill_info(skb, NETLINK_CB(cb->skb).portid,
 						 cb->nlh->nlmsg_seq,
 						 cpu, st) < 0)
 			break;
diff --git a/net/netfilter/nfnetlink_acct.c b/net/netfilter/nfnetlink_acct.c
index d7ec928..589d686 100644
--- a/net/netfilter/nfnetlink_acct.c
+++ b/net/netfilter/nfnetlink_acct.c
@@ -91,16 +91,16 @@ nfnl_acct_new(struct sock *nfnl, struct sk_buff *skb,
 }
 
 static int
-nfnl_acct_fill_info(struct sk_buff *skb, u32 pid, u32 seq, u32 type,
+nfnl_acct_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 		   int event, struct nf_acct *acct)
 {
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
-	unsigned int flags = pid ? NLM_F_MULTI : 0;
+	unsigned int flags = portid ? NLM_F_MULTI : 0;
 	u64 pkts, bytes;
 
 	event |= NFNL_SUBSYS_ACCT << 8;
-	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*nfmsg), flags);
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
 
@@ -150,7 +150,7 @@ nfnl_acct_dump(struct sk_buff *skb, struct netlink_callback *cb)
 		if (last && cur != last)
 			continue;
 
-		if (nfnl_acct_fill_info(skb, NETLINK_CB(cb->skb).pid,
+		if (nfnl_acct_fill_info(skb, NETLINK_CB(cb->skb).portid,
 				       cb->nlh->nlmsg_seq,
 				       NFNL_MSG_TYPE(cb->nlh->nlmsg_type),
 				       NFNL_MSG_ACCT_NEW, cur) < 0) {
@@ -195,7 +195,7 @@ nfnl_acct_get(struct sock *nfnl, struct sk_buff *skb,
 			break;
 		}
 
-		ret = nfnl_acct_fill_info(skb2, NETLINK_CB(skb).pid,
+		ret = nfnl_acct_fill_info(skb2, NETLINK_CB(skb).portid,
 					 nlh->nlmsg_seq,
 					 NFNL_MSG_TYPE(nlh->nlmsg_type),
 					 NFNL_MSG_ACCT_NEW, cur);
@@ -203,7 +203,7 @@ nfnl_acct_get(struct sock *nfnl, struct sk_buff *skb,
 			kfree_skb(skb2);
 			break;
 		}
-		ret = netlink_unicast(nfnl, skb2, NETLINK_CB(skb).pid,
+		ret = netlink_unicast(nfnl, skb2, NETLINK_CB(skb).portid,
 					MSG_DONTWAIT);
 		if (ret > 0)
 			ret = 0;
diff --git a/net/netfilter/nfnetlink_cthelper.c b/net/netfilter/nfnetlink_cthelper.c
index 32a1ba3..3678073 100644
--- a/net/netfilter/nfnetlink_cthelper.c
+++ b/net/netfilter/nfnetlink_cthelper.c
@@ -395,16 +395,16 @@ nla_put_failure:
 }
 
 static int
-nfnl_cthelper_fill_info(struct sk_buff *skb, u32 pid, u32 seq, u32 type,
+nfnl_cthelper_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 			int event, struct nf_conntrack_helper *helper)
 {
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
-	unsigned int flags = pid ? NLM_F_MULTI : 0;
+	unsigned int flags = portid ? NLM_F_MULTI : 0;
 	int status;
 
 	event |= NFNL_SUBSYS_CTHELPER << 8;
-	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*nfmsg), flags);
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
 
@@ -468,7 +468,7 @@ restart:
 				cb->args[1] = 0;
 			}
 			if (nfnl_cthelper_fill_info(skb,
-					    NETLINK_CB(cb->skb).pid,
+					    NETLINK_CB(cb->skb).portid,
 					    cb->nlh->nlmsg_seq,
 					    NFNL_MSG_TYPE(cb->nlh->nlmsg_type),
 					    NFNL_MSG_CTHELPER_NEW, cur) < 0) {
@@ -538,7 +538,7 @@ nfnl_cthelper_get(struct sock *nfnl, struct sk_buff *skb,
 				break;
 			}
 
-			ret = nfnl_cthelper_fill_info(skb2, NETLINK_CB(skb).pid,
+			ret = nfnl_cthelper_fill_info(skb2, NETLINK_CB(skb).portid,
 						nlh->nlmsg_seq,
 						NFNL_MSG_TYPE(nlh->nlmsg_type),
 						NFNL_MSG_CTHELPER_NEW, cur);
@@ -547,7 +547,7 @@ nfnl_cthelper_get(struct sock *nfnl, struct sk_buff *skb,
 				break;
 			}
 
-			ret = netlink_unicast(nfnl, skb2, NETLINK_CB(skb).pid,
+			ret = netlink_unicast(nfnl, skb2, NETLINK_CB(skb).portid,
 						MSG_DONTWAIT);
 			if (ret > 0)
 				ret = 0;
diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index cdecbc8..8847b4d 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -155,16 +155,16 @@ err_proto_put:
 }
 
 static int
-ctnl_timeout_fill_info(struct sk_buff *skb, u32 pid, u32 seq, u32 type,
+ctnl_timeout_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 		       int event, struct ctnl_timeout *timeout)
 {
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
-	unsigned int flags = pid ? NLM_F_MULTI : 0;
+	unsigned int flags = portid ? NLM_F_MULTI : 0;
 	struct nf_conntrack_l4proto *l4proto = timeout->l4proto;
 
 	event |= NFNL_SUBSYS_CTNETLINK_TIMEOUT << 8;
-	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*nfmsg), flags);
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
 
@@ -222,7 +222,7 @@ ctnl_timeout_dump(struct sk_buff *skb, struct netlink_callback *cb)
 		if (last && cur != last)
 			continue;
 
-		if (ctnl_timeout_fill_info(skb, NETLINK_CB(cb->skb).pid,
+		if (ctnl_timeout_fill_info(skb, NETLINK_CB(cb->skb).portid,
 					   cb->nlh->nlmsg_seq,
 					   NFNL_MSG_TYPE(cb->nlh->nlmsg_type),
 					   IPCTNL_MSG_TIMEOUT_NEW, cur) < 0) {
@@ -268,7 +268,7 @@ cttimeout_get_timeout(struct sock *ctnl, struct sk_buff *skb,
 			break;
 		}
 
-		ret = ctnl_timeout_fill_info(skb2, NETLINK_CB(skb).pid,
+		ret = ctnl_timeout_fill_info(skb2, NETLINK_CB(skb).portid,
 					     nlh->nlmsg_seq,
 					     NFNL_MSG_TYPE(nlh->nlmsg_type),
 					     IPCTNL_MSG_TIMEOUT_NEW, cur);
@@ -276,7 +276,7 @@ cttimeout_get_timeout(struct sock *ctnl, struct sk_buff *skb,
 			kfree_skb(skb2);
 			break;
 		}
-		ret = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).pid,
+		ret = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).portid,
 					MSG_DONTWAIT);
 		if (ret > 0)
 			ret = 0;
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index be194b1..8cb67c4 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -56,7 +56,7 @@ struct nfulnl_instance {
 	struct sk_buff *skb;		/* pre-allocatd skb */
 	struct timer_list timer;
 	struct user_namespace *peer_user_ns;	/* User namespace of the peer process */
-	int peer_pid;			/* PID of the peer process */
+	int peer_portid;			/* PORTID of the peer process */
 
 	/* configurable parameters */
 	unsigned int flushtimeout;	/* timeout until queue flush */
@@ -133,7 +133,7 @@ instance_put(struct nfulnl_instance *inst)
 static void nfulnl_timer(unsigned long data);
 
 static struct nfulnl_instance *
-instance_create(u_int16_t group_num, int pid, struct user_namespace *user_ns)
+instance_create(u_int16_t group_num, int portid, struct user_namespace *user_ns)
 {
 	struct nfulnl_instance *inst;
 	int err;
@@ -164,7 +164,7 @@ instance_create(u_int16_t group_num, int pid, struct user_namespace *user_ns)
 	setup_timer(&inst->timer, nfulnl_timer, (unsigned long)inst);
 
 	inst->peer_user_ns = user_ns;
-	inst->peer_pid = pid;
+	inst->peer_portid = portid;
 	inst->group_num = group_num;
 
 	inst->qthreshold 	= NFULNL_QTHRESH_DEFAULT;
@@ -336,7 +336,7 @@ __nfulnl_send(struct nfulnl_instance *inst)
 		if (!nlh)
 			goto out;
 	}
-	status = nfnetlink_unicast(inst->skb, &init_net, inst->peer_pid,
+	status = nfnetlink_unicast(inst->skb, &init_net, inst->peer_portid,
 				   MSG_DONTWAIT);
 
 	inst->qlen = 0;
@@ -703,7 +703,7 @@ nfulnl_rcv_nl_event(struct notifier_block *this,
 	if (event == NETLINK_URELEASE && n->protocol == NETLINK_NETFILTER) {
 		int i;
 
-		/* destroy all instances for this pid */
+		/* destroy all instances for this portid */
 		spin_lock_bh(&instances_lock);
 		for  (i = 0; i < INSTANCE_BUCKETS; i++) {
 			struct hlist_node *tmp, *t2;
@@ -712,7 +712,7 @@ nfulnl_rcv_nl_event(struct notifier_block *this,
 
 			hlist_for_each_entry_safe(inst, tmp, t2, head, hlist) {
 				if ((net_eq(n->net, &init_net)) &&
-				    (n->pid == inst->peer_pid))
+				    (n->portid == inst->peer_portid))
 					__instance_destroy(inst);
 			}
 		}
@@ -774,7 +774,7 @@ nfulnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 	}
 
 	inst = instance_lookup_get(group_num);
-	if (inst && inst->peer_pid != NETLINK_CB(skb).pid) {
+	if (inst && inst->peer_portid != NETLINK_CB(skb).portid) {
 		ret = -EPERM;
 		goto out_put;
 	}
@@ -788,7 +788,7 @@ nfulnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 			}
 
 			inst = instance_create(group_num,
-					       NETLINK_CB(skb).pid,
+					       NETLINK_CB(skb).portid,
 					       sk_user_ns(NETLINK_CB(skb).ssk));
 			if (IS_ERR(inst)) {
 				ret = PTR_ERR(inst);
@@ -947,7 +947,7 @@ static int seq_show(struct seq_file *s, void *v)
 
 	return seq_printf(s, "%5d %6d %5d %1d %5d %6d %2d\n",
 			  inst->group_num,
-			  inst->peer_pid, inst->qlen,
+			  inst->peer_portid, inst->qlen,
 			  inst->copy_mode, inst->copy_range,
 			  inst->flushtimeout, atomic_read(&inst->use));
 }
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index c0496a5..b8d9995 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -44,7 +44,7 @@ struct nfqnl_instance {
 	struct hlist_node hlist;		/* global list of queues */
 	struct rcu_head rcu;
 
-	int peer_pid;
+	int peer_portid;
 	unsigned int queue_maxlen;
 	unsigned int copy_range;
 	unsigned int queue_dropped;
@@ -92,7 +92,7 @@ instance_lookup(u_int16_t queue_num)
 }
 
 static struct nfqnl_instance *
-instance_create(u_int16_t queue_num, int pid)
+instance_create(u_int16_t queue_num, int portid)
 {
 	struct nfqnl_instance *inst;
 	unsigned int h;
@@ -111,7 +111,7 @@ instance_create(u_int16_t queue_num, int pid)
 	}
 
 	inst->queue_num = queue_num;
-	inst->peer_pid = pid;
+	inst->peer_portid = portid;
 	inst->queue_maxlen = NFQNL_QMAX_DEFAULT;
 	inst->copy_range = 0xfffff;
 	inst->copy_mode = NFQNL_COPY_NONE;
@@ -440,7 +440,7 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
 	}
 	spin_lock_bh(&queue->lock);
 
-	if (!queue->peer_pid) {
+	if (!queue->peer_portid) {
 		err = -EINVAL;
 		goto err_out_free_nskb;
 	}
@@ -459,7 +459,7 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
 	*packet_id_ptr = htonl(entry->id);
 
 	/* nfnetlink_unicast will either free the nskb or add it to a socket */
-	err = nfnetlink_unicast(nskb, &init_net, queue->peer_pid, MSG_DONTWAIT);
+	err = nfnetlink_unicast(nskb, &init_net, queue->peer_portid, MSG_DONTWAIT);
 	if (err < 0) {
 		queue->queue_user_dropped++;
 		goto err_out_unlock;
@@ -616,7 +616,7 @@ nfqnl_rcv_nl_event(struct notifier_block *this,
 	if (event == NETLINK_URELEASE && n->protocol == NETLINK_NETFILTER) {
 		int i;
 
-		/* destroy all instances for this pid */
+		/* destroy all instances for this portid */
 		spin_lock(&instances_lock);
 		for (i = 0; i < INSTANCE_BUCKETS; i++) {
 			struct hlist_node *tmp, *t2;
@@ -625,7 +625,7 @@ nfqnl_rcv_nl_event(struct notifier_block *this,
 
 			hlist_for_each_entry_safe(inst, tmp, t2, head, hlist) {
 				if ((n->net == &init_net) &&
-				    (n->pid == inst->peer_pid))
+				    (n->portid == inst->peer_portid))
 					__instance_destroy(inst);
 			}
 		}
@@ -650,7 +650,7 @@ static const struct nla_policy nfqa_verdict_batch_policy[NFQA_MAX+1] = {
 	[NFQA_MARK]		= { .type = NLA_U32 },
 };
 
-static struct nfqnl_instance *verdict_instance_lookup(u16 queue_num, int nlpid)
+static struct nfqnl_instance *verdict_instance_lookup(u16 queue_num, int nlportid)
 {
 	struct nfqnl_instance *queue;
 
@@ -658,7 +658,7 @@ static struct nfqnl_instance *verdict_instance_lookup(u16 queue_num, int nlpid)
 	if (!queue)
 		return ERR_PTR(-ENODEV);
 
-	if (queue->peer_pid != nlpid)
+	if (queue->peer_portid != nlportid)
 		return ERR_PTR(-EPERM);
 
 	return queue;
@@ -698,7 +698,7 @@ nfqnl_recv_verdict_batch(struct sock *ctnl, struct sk_buff *skb,
 	LIST_HEAD(batch_list);
 	u16 queue_num = ntohs(nfmsg->res_id);
 
-	queue = verdict_instance_lookup(queue_num, NETLINK_CB(skb).pid);
+	queue = verdict_instance_lookup(queue_num, NETLINK_CB(skb).portid);
 	if (IS_ERR(queue))
 		return PTR_ERR(queue);
 
@@ -749,7 +749,7 @@ nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
 	queue = instance_lookup(queue_num);
 	if (!queue)
 
-	queue = verdict_instance_lookup(queue_num, NETLINK_CB(skb).pid);
+	queue = verdict_instance_lookup(queue_num, NETLINK_CB(skb).portid);
 	if (IS_ERR(queue))
 		return PTR_ERR(queue);
 
@@ -832,7 +832,7 @@ nfqnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 
 	rcu_read_lock();
 	queue = instance_lookup(queue_num);
-	if (queue && queue->peer_pid != NETLINK_CB(skb).pid) {
+	if (queue && queue->peer_portid != NETLINK_CB(skb).portid) {
 		ret = -EPERM;
 		goto err_out_unlock;
 	}
@@ -844,7 +844,7 @@ nfqnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 				ret = -EBUSY;
 				goto err_out_unlock;
 			}
-			queue = instance_create(queue_num, NETLINK_CB(skb).pid);
+			queue = instance_create(queue_num, NETLINK_CB(skb).portid);
 			if (IS_ERR(queue)) {
 				ret = PTR_ERR(queue);
 				goto err_out_unlock;
@@ -1016,7 +1016,7 @@ static int seq_show(struct seq_file *s, void *v)
 
 	return seq_printf(s, "%5d %6d %5d %1d %5d %5d %5d %8d %2d\n",
 			  inst->queue_num,
-			  inst->peer_pid, inst->queue_total,
+			  inst->peer_portid, inst->queue_total,
 			  inst->copy_mode, inst->copy_range,
 			  inst->queue_dropped, inst->queue_user_dropped,
 			  inst->id_sequence, 1);
diff --git a/net/netlabel/netlabel_cipso_v4.c b/net/netlabel/netlabel_cipso_v4.c
index 6bf8783..c15042f 100644
--- a/net/netlabel/netlabel_cipso_v4.c
+++ b/net/netlabel/netlabel_cipso_v4.c
@@ -627,7 +627,7 @@ static int netlbl_cipsov4_listall_cb(struct cipso_v4_doi *doi_def, void *arg)
 	struct netlbl_cipsov4_doiwalk_arg *cb_arg = arg;
 	void *data;
 
-	data = genlmsg_put(cb_arg->skb, NETLINK_CB(cb_arg->nl_cb->skb).pid,
+	data = genlmsg_put(cb_arg->skb, NETLINK_CB(cb_arg->nl_cb->skb).portid,
 			   cb_arg->seq, &netlbl_cipsov4_gnl_family,
 			   NLM_F_MULTI, NLBL_CIPSOV4_C_LISTALL);
 	if (data == NULL)
diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
index 4809e2e..c5384ff 100644
--- a/net/netlabel/netlabel_mgmt.c
+++ b/net/netlabel/netlabel_mgmt.c
@@ -448,7 +448,7 @@ static int netlbl_mgmt_listall_cb(struct netlbl_dom_map *entry, void *arg)
 	struct netlbl_domhsh_walk_arg *cb_arg = arg;
 	void *data;
 
-	data = genlmsg_put(cb_arg->skb, NETLINK_CB(cb_arg->nl_cb->skb).pid,
+	data = genlmsg_put(cb_arg->skb, NETLINK_CB(cb_arg->nl_cb->skb).portid,
 			   cb_arg->seq, &netlbl_mgmt_gnl_family,
 			   NLM_F_MULTI, NLBL_MGMT_C_LISTALL);
 	if (data == NULL)
@@ -613,7 +613,7 @@ static int netlbl_mgmt_protocols_cb(struct sk_buff *skb,
 	int ret_val = -ENOMEM;
 	void *data;
 
-	data = genlmsg_put(skb, NETLINK_CB(cb->skb).pid, cb->nlh->nlmsg_seq,
+	data = genlmsg_put(skb, NETLINK_CB(cb->skb).portid, cb->nlh->nlmsg_seq,
 			   &netlbl_mgmt_gnl_family, NLM_F_MULTI,
 			   NLBL_MGMT_C_PROTOCOLS);
 	if (data == NULL)
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index e7ff694..b794441 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -1096,7 +1096,7 @@ static int netlbl_unlabel_staticlist_gen(u32 cmd,
 	char *secctx;
 	u32 secctx_len;
 
-	data = genlmsg_put(cb_arg->skb, NETLINK_CB(cb_arg->nl_cb->skb).pid,
+	data = genlmsg_put(cb_arg->skb, NETLINK_CB(cb_arg->nl_cb->skb).portid,
 			   cb_arg->seq, &netlbl_unlabel_gnl_family,
 			   NLM_F_MULTI, cmd);
 	if (data == NULL)
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 3821199..d229e0f 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -67,8 +67,8 @@
 struct netlink_sock {
 	/* struct sock has to be the first member of netlink_sock */
 	struct sock		sk;
-	u32			pid;
-	u32			dst_pid;
+	u32			portid;
+	u32			dst_portid;
 	u32			dst_group;
 	u32			flags;
 	u32			subscriptions;
@@ -104,7 +104,7 @@ static inline int netlink_is_kernel(struct sock *sk)
 	return nlk_sk(sk)->flags & NETLINK_KERNEL_SOCKET;
 }
 
-struct nl_pid_hash {
+struct nl_portid_hash {
 	struct hlist_head	*table;
 	unsigned long		rehash_time;
 
@@ -118,7 +118,7 @@ struct nl_pid_hash {
 };
 
 struct netlink_table {
-	struct nl_pid_hash	hash;
+	struct nl_portid_hash	hash;
 	struct hlist_head	mc_list;
 	struct listeners __rcu	*listeners;
 	unsigned int		nl_nonroot;
@@ -145,9 +145,9 @@ static inline u32 netlink_group_mask(u32 group)
 	return group ? 1 << (group - 1) : 0;
 }
 
-static inline struct hlist_head *nl_pid_hashfn(struct nl_pid_hash *hash, u32 pid)
+static inline struct hlist_head *nl_portid_hashfn(struct nl_portid_hash *hash, u32 portid)
 {
-	return &hash->table[jhash_1word(pid, hash->rnd) & hash->mask];
+	return &hash->table[jhash_1word(portid, hash->rnd) & hash->mask];
 }
 
 static void netlink_destroy_callback(struct netlink_callback *cb)
@@ -239,17 +239,17 @@ netlink_unlock_table(void)
 		wake_up(&nl_table_wait);
 }
 
-static struct sock *netlink_lookup(struct net *net, int protocol, u32 pid)
+static struct sock *netlink_lookup(struct net *net, int protocol, u32 portid)
 {
-	struct nl_pid_hash *hash = &nl_table[protocol].hash;
+	struct nl_portid_hash *hash = &nl_table[protocol].hash;
 	struct hlist_head *head;
 	struct sock *sk;
 	struct hlist_node *node;
 
 	read_lock(&nl_table_lock);
-	head = nl_pid_hashfn(hash, pid);
+	head = nl_portid_hashfn(hash, portid);
 	sk_for_each(sk, node, head) {
-		if (net_eq(sock_net(sk), net) && (nlk_sk(sk)->pid == pid)) {
+		if (net_eq(sock_net(sk), net) && (nlk_sk(sk)->portid == portid)) {
 			sock_hold(sk);
 			goto found;
 		}
@@ -260,7 +260,7 @@ found:
 	return sk;
 }
 
-static struct hlist_head *nl_pid_hash_zalloc(size_t size)
+static struct hlist_head *nl_portid_hash_zalloc(size_t size)
 {
 	if (size <= PAGE_SIZE)
 		return kzalloc(size, GFP_ATOMIC);
@@ -270,7 +270,7 @@ static struct hlist_head *nl_pid_hash_zalloc(size_t size)
 					 get_order(size));
 }
 
-static void nl_pid_hash_free(struct hlist_head *table, size_t size)
+static void nl_portid_hash_free(struct hlist_head *table, size_t size)
 {
 	if (size <= PAGE_SIZE)
 		kfree(table);
@@ -278,7 +278,7 @@ static void nl_pid_hash_free(struct hlist_head *table, size_t size)
 		free_pages((unsigned long)table, get_order(size));
 }
 
-static int nl_pid_hash_rehash(struct nl_pid_hash *hash, int grow)
+static int nl_portid_hash_rehash(struct nl_portid_hash *hash, int grow)
 {
 	unsigned int omask, mask, shift;
 	size_t osize, size;
@@ -296,7 +296,7 @@ static int nl_pid_hash_rehash(struct nl_pid_hash *hash, int grow)
 		size *= 2;
 	}
 
-	table = nl_pid_hash_zalloc(size);
+	table = nl_portid_hash_zalloc(size);
 	if (!table)
 		return 0;
 
@@ -311,23 +311,23 @@ static int nl_pid_hash_rehash(struct nl_pid_hash *hash, int grow)
 		struct hlist_node *node, *tmp;
 
 		sk_for_each_safe(sk, node, tmp, &otable[i])
-			__sk_add_node(sk, nl_pid_hashfn(hash, nlk_sk(sk)->pid));
+			__sk_add_node(sk, nl_portid_hashfn(hash, nlk_sk(sk)->portid));
 	}
 
-	nl_pid_hash_free(otable, osize);
+	nl_portid_hash_free(otable, osize);
 	hash->rehash_time = jiffies + 10 * 60 * HZ;
 	return 1;
 }
 
-static inline int nl_pid_hash_dilute(struct nl_pid_hash *hash, int len)
+static inline int nl_portid_hash_dilute(struct nl_portid_hash *hash, int len)
 {
 	int avg = hash->entries >> hash->shift;
 
-	if (unlikely(avg > 1) && nl_pid_hash_rehash(hash, 1))
+	if (unlikely(avg > 1) && nl_portid_hash_rehash(hash, 1))
 		return 1;
 
 	if (unlikely(len > avg) && time_after(jiffies, hash->rehash_time)) {
-		nl_pid_hash_rehash(hash, 0);
+		nl_portid_hash_rehash(hash, 0);
 		return 1;
 	}
 
@@ -356,9 +356,9 @@ netlink_update_listeners(struct sock *sk)
 	 * makes sure updates are visible before bind or setsockopt return. */
 }
 
-static int netlink_insert(struct sock *sk, struct net *net, u32 pid)
+static int netlink_insert(struct sock *sk, struct net *net, u32 portid)
 {
-	struct nl_pid_hash *hash = &nl_table[sk->sk_protocol].hash;
+	struct nl_portid_hash *hash = &nl_table[sk->sk_protocol].hash;
 	struct hlist_head *head;
 	int err = -EADDRINUSE;
 	struct sock *osk;
@@ -366,10 +366,10 @@ static int netlink_insert(struct sock *sk, struct net *net, u32 pid)
 	int len;
 
 	netlink_table_grab();
-	head = nl_pid_hashfn(hash, pid);
+	head = nl_portid_hashfn(hash, portid);
 	len = 0;
 	sk_for_each(osk, node, head) {
-		if (net_eq(sock_net(osk), net) && (nlk_sk(osk)->pid == pid))
+		if (net_eq(sock_net(osk), net) && (nlk_sk(osk)->portid == portid))
 			break;
 		len++;
 	}
@@ -377,17 +377,17 @@ static int netlink_insert(struct sock *sk, struct net *net, u32 pid)
 		goto err;
 
 	err = -EBUSY;
-	if (nlk_sk(sk)->pid)
+	if (nlk_sk(sk)->portid)
 		goto err;
 
 	err = -ENOMEM;
 	if (BITS_PER_LONG > 32 && unlikely(hash->entries >= UINT_MAX))
 		goto err;
 
-	if (len && nl_pid_hash_dilute(hash, len))
-		head = nl_pid_hashfn(hash, pid);
+	if (len && nl_portid_hash_dilute(hash, len))
+		head = nl_portid_hashfn(hash, portid);
 	hash->entries++;
-	nlk_sk(sk)->pid = pid;
+	nlk_sk(sk)->portid = portid;
 	sk_add_node(sk, head);
 	err = 0;
 
@@ -518,11 +518,11 @@ static int netlink_release(struct socket *sock)
 
 	skb_queue_purge(&sk->sk_write_queue);
 
-	if (nlk->pid) {
+	if (nlk->portid) {
 		struct netlink_notify n = {
 						.net = sock_net(sk),
 						.protocol = sk->sk_protocol,
-						.pid = nlk->pid,
+						.portid = nlk->portid,
 					  };
 		atomic_notifier_call_chain(&netlink_chain,
 				NETLINK_URELEASE, &n);
@@ -557,24 +557,24 @@ static int netlink_autobind(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 	struct net *net = sock_net(sk);
-	struct nl_pid_hash *hash = &nl_table[sk->sk_protocol].hash;
+	struct nl_portid_hash *hash = &nl_table[sk->sk_protocol].hash;
 	struct hlist_head *head;
 	struct sock *osk;
 	struct hlist_node *node;
-	s32 pid = task_tgid_vnr(current);
+	s32 portid = task_tgid_vnr(current);
 	int err;
 	static s32 rover = -4097;
 
 retry:
 	cond_resched();
 	netlink_table_grab();
-	head = nl_pid_hashfn(hash, pid);
+	head = nl_portid_hashfn(hash, portid);
 	sk_for_each(osk, node, head) {
 		if (!net_eq(sock_net(osk), net))
 			continue;
-		if (nlk_sk(osk)->pid == pid) {
-			/* Bind collision, search negative pid values. */
-			pid = rover--;
+		if (nlk_sk(osk)->portid == portid) {
+			/* Bind collision, search negative portid values. */
+			portid = rover--;
 			if (rover > -4097)
 				rover = -4097;
 			netlink_table_ungrab();
@@ -583,7 +583,7 @@ retry:
 	}
 	netlink_table_ungrab();
 
-	err = netlink_insert(sk, net, pid);
+	err = netlink_insert(sk, net, portid);
 	if (err == -EADDRINUSE)
 		goto retry;
 
@@ -666,8 +666,8 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 			return err;
 	}
 
-	if (nlk->pid) {
-		if (nladdr->nl_pid != nlk->pid)
+	if (nlk->portid) {
+		if (nladdr->nl_pid != nlk->portid)
 			return -EINVAL;
 	} else {
 		err = nladdr->nl_pid ?
@@ -713,7 +713,7 @@ static int netlink_connect(struct socket *sock, struct sockaddr *addr,
 
 	if (addr->sa_family == AF_UNSPEC) {
 		sk->sk_state	= NETLINK_UNCONNECTED;
-		nlk->dst_pid	= 0;
+		nlk->dst_portid	= 0;
 		nlk->dst_group  = 0;
 		return 0;
 	}
@@ -724,12 +724,12 @@ static int netlink_connect(struct socket *sock, struct sockaddr *addr,
 	if (nladdr->nl_groups && !netlink_capable(sock, NL_NONROOT_SEND))
 		return -EPERM;
 
-	if (!nlk->pid)
+	if (!nlk->portid)
 		err = netlink_autobind(sock);
 
 	if (err == 0) {
 		sk->sk_state	= NETLINK_CONNECTED;
-		nlk->dst_pid 	= nladdr->nl_pid;
+		nlk->dst_portid = nladdr->nl_pid;
 		nlk->dst_group  = ffs(nladdr->nl_groups);
 	}
 
@@ -748,10 +748,10 @@ static int netlink_getname(struct socket *sock, struct sockaddr *addr,
 	*addr_len = sizeof(*nladdr);
 
 	if (peer) {
-		nladdr->nl_pid = nlk->dst_pid;
+		nladdr->nl_pid = nlk->dst_portid;
 		nladdr->nl_groups = netlink_group_mask(nlk->dst_group);
 	} else {
-		nladdr->nl_pid = nlk->pid;
+		nladdr->nl_pid = nlk->portid;
 		nladdr->nl_groups = nlk->groups ? nlk->groups[0] : 0;
 	}
 	return 0;
@@ -770,19 +770,19 @@ static void netlink_overrun(struct sock *sk)
 	atomic_inc(&sk->sk_drops);
 }
 
-static struct sock *netlink_getsockbypid(struct sock *ssk, u32 pid)
+static struct sock *netlink_getsockbyportid(struct sock *ssk, u32 portid)
 {
 	struct sock *sock;
 	struct netlink_sock *nlk;
 
-	sock = netlink_lookup(sock_net(ssk), ssk->sk_protocol, pid);
+	sock = netlink_lookup(sock_net(ssk), ssk->sk_protocol, portid);
 	if (!sock)
 		return ERR_PTR(-ECONNREFUSED);
 
 	/* Don't bother queuing skb if kernel socket has no input function */
 	nlk = nlk_sk(sock);
 	if (sock->sk_state == NETLINK_CONNECTED &&
-	    nlk->dst_pid != nlk_sk(ssk)->pid) {
+	    nlk->dst_portid != nlk_sk(ssk)->portid) {
 		sock_put(sock);
 		return ERR_PTR(-ECONNREFUSED);
 	}
@@ -933,7 +933,7 @@ static int netlink_unicast_kernel(struct sock *sk, struct sk_buff *skb,
 }
 
 int netlink_unicast(struct sock *ssk, struct sk_buff *skb,
-		    u32 pid, int nonblock)
+		    u32 portid, int nonblock)
 {
 	struct sock *sk;
 	int err;
@@ -943,7 +943,7 @@ int netlink_unicast(struct sock *ssk, struct sk_buff *skb,
 
 	timeo = sock_sndtimeo(ssk, nonblock);
 retry:
-	sk = netlink_getsockbypid(ssk, pid);
+	sk = netlink_getsockbyportid(ssk, portid);
 	if (IS_ERR(sk)) {
 		kfree_skb(skb);
 		return PTR_ERR(sk);
@@ -1003,7 +1003,7 @@ static int netlink_broadcast_deliver(struct sock *sk, struct sk_buff *skb)
 struct netlink_broadcast_data {
 	struct sock *exclude_sk;
 	struct net *net;
-	u32 pid;
+	u32 portid;
 	u32 group;
 	int failure;
 	int delivery_failure;
@@ -1024,7 +1024,7 @@ static int do_one_broadcast(struct sock *sk,
 	if (p->exclude_sk == sk)
 		goto out;
 
-	if (nlk->pid == p->pid || p->group - 1 >= nlk->ngroups ||
+	if (nlk->portid == p->portid || p->group - 1 >= nlk->ngroups ||
 	    !test_bit(p->group - 1, nlk->groups))
 		goto out;
 
@@ -1076,7 +1076,7 @@ out:
 	return 0;
 }
 
-int netlink_broadcast_filtered(struct sock *ssk, struct sk_buff *skb, u32 pid,
+int netlink_broadcast_filtered(struct sock *ssk, struct sk_buff *skb, u32 portid,
 	u32 group, gfp_t allocation,
 	int (*filter)(struct sock *dsk, struct sk_buff *skb, void *data),
 	void *filter_data)
@@ -1090,7 +1090,7 @@ int netlink_broadcast_filtered(struct sock *ssk, struct sk_buff *skb, u32 pid,
 
 	info.exclude_sk = ssk;
 	info.net = net;
-	info.pid = pid;
+	info.portid = portid;
 	info.group = group;
 	info.failure = 0;
 	info.delivery_failure = 0;
@@ -1128,17 +1128,17 @@ int netlink_broadcast_filtered(struct sock *ssk, struct sk_buff *skb, u32 pid,
 }
 EXPORT_SYMBOL(netlink_broadcast_filtered);
 
-int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, u32 pid,
+int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, u32 portid,
 		      u32 group, gfp_t allocation)
 {
-	return netlink_broadcast_filtered(ssk, skb, pid, group, allocation,
+	return netlink_broadcast_filtered(ssk, skb, portid, group, allocation,
 		NULL, NULL);
 }
 EXPORT_SYMBOL(netlink_broadcast);
 
 struct netlink_set_err_data {
 	struct sock *exclude_sk;
-	u32 pid;
+	u32 portid;
 	u32 group;
 	int code;
 };
@@ -1154,7 +1154,7 @@ static int do_one_set_err(struct sock *sk, struct netlink_set_err_data *p)
 	if (!net_eq(sock_net(sk), sock_net(p->exclude_sk)))
 		goto out;
 
-	if (nlk->pid == p->pid || p->group - 1 >= nlk->ngroups ||
+	if (nlk->portid == p->portid || p->group - 1 >= nlk->ngroups ||
 	    !test_bit(p->group - 1, nlk->groups))
 		goto out;
 
@@ -1172,14 +1172,14 @@ out:
 /**
  * netlink_set_err - report error to broadcast listeners
  * @ssk: the kernel netlink socket, as returned by netlink_kernel_create()
- * @pid: the PID of a process that we want to skip (if any)
+ * @portid: the PORTID of a process that we want to skip (if any)
  * @groups: the broadcast group that will notice the error
  * @code: error code, must be negative (as usual in kernelspace)
  *
  * This function returns the number of broadcast listeners that have set the
  * NETLINK_RECV_NO_ENOBUFS socket option.
  */
-int netlink_set_err(struct sock *ssk, u32 pid, u32 group, int code)
+int netlink_set_err(struct sock *ssk, u32 portid, u32 group, int code)
 {
 	struct netlink_set_err_data info;
 	struct hlist_node *node;
@@ -1187,7 +1187,7 @@ int netlink_set_err(struct sock *ssk, u32 pid, u32 group, int code)
 	int ret = 0;
 
 	info.exclude_sk = ssk;
-	info.pid = pid;
+	info.portid = portid;
 	info.group = group;
 	/* sk->sk_err wants a positive error value */
 	info.code = -code;
@@ -1352,7 +1352,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	struct sock *sk = sock->sk;
 	struct netlink_sock *nlk = nlk_sk(sk);
 	struct sockaddr_nl *addr = msg->msg_name;
-	u32 dst_pid;
+	u32 dst_portid;
 	u32 dst_group;
 	struct sk_buff *skb;
 	int err;
@@ -1372,18 +1372,18 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		err = -EINVAL;
 		if (addr->nl_family != AF_NETLINK)
 			goto out;
-		dst_pid = addr->nl_pid;
+		dst_portid = addr->nl_pid;
 		dst_group = ffs(addr->nl_groups);
 		err =  -EPERM;
-		if ((dst_group || dst_pid) &&
+		if ((dst_group || dst_portid) &&
 		    !netlink_capable(sock, NL_NONROOT_SEND))
 			goto out;
 	} else {
-		dst_pid = nlk->dst_pid;
+		dst_portid = nlk->dst_portid;
 		dst_group = nlk->dst_group;
 	}
 
-	if (!nlk->pid) {
+	if (!nlk->portid) {
 		err = netlink_autobind(sock);
 		if (err)
 			goto out;
@@ -1397,7 +1397,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	if (skb == NULL)
 		goto out;
 
-	NETLINK_CB(skb).pid	= nlk->pid;
+	NETLINK_CB(skb).portid	= nlk->portid;
 	NETLINK_CB(skb).dst_group = dst_group;
 	memcpy(NETLINK_CREDS(skb), &siocb->scm->creds, sizeof(struct ucred));
 
@@ -1415,9 +1415,9 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 
 	if (dst_group) {
 		atomic_inc(&skb->users);
-		netlink_broadcast(sk, skb, dst_pid, dst_group, GFP_KERNEL);
+		netlink_broadcast(sk, skb, dst_portid, dst_group, GFP_KERNEL);
 	}
-	err = netlink_unicast(sk, skb, dst_pid, msg->msg_flags&MSG_DONTWAIT);
+	err = netlink_unicast(sk, skb, dst_portid, msg->msg_flags&MSG_DONTWAIT);
 
 out:
 	scm_destroy(siocb->scm);
@@ -1480,7 +1480,7 @@ static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
 		struct sockaddr_nl *addr = (struct sockaddr_nl *)msg->msg_name;
 		addr->nl_family = AF_NETLINK;
 		addr->nl_pad    = 0;
-		addr->nl_pid	= NETLINK_CB(skb).pid;
+		addr->nl_pid	= NETLINK_CB(skb).portid;
 		addr->nl_groups	= netlink_group_mask(NETLINK_CB(skb).dst_group);
 		msg->msg_namelen = sizeof(*addr);
 	}
@@ -1687,7 +1687,7 @@ void netlink_set_nonroot(int protocol, unsigned int flags)
 EXPORT_SYMBOL(netlink_set_nonroot);
 
 struct nlmsghdr *
-__nlmsg_put(struct sk_buff *skb, u32 pid, u32 seq, int type, int len, int flags)
+__nlmsg_put(struct sk_buff *skb, u32 portid, u32 seq, int type, int len, int flags)
 {
 	struct nlmsghdr *nlh;
 	int size = NLMSG_LENGTH(len);
@@ -1696,7 +1696,7 @@ __nlmsg_put(struct sk_buff *skb, u32 pid, u32 seq, int type, int len, int flags)
 	nlh->nlmsg_type = type;
 	nlh->nlmsg_len = size;
 	nlh->nlmsg_flags = flags;
-	nlh->nlmsg_pid = pid;
+	nlh->nlmsg_pid = portid;
 	nlh->nlmsg_seq = seq;
 	if (!__builtin_constant_p(size) || NLMSG_ALIGN(size) - size != 0)
 		memset(NLMSG_DATA(nlh) + len, 0, NLMSG_ALIGN(size) - size);
@@ -1792,7 +1792,7 @@ int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 	atomic_inc(&skb->users);
 	cb->skb = skb;
 
-	sk = netlink_lookup(sock_net(ssk), ssk->sk_protocol, NETLINK_CB(skb).pid);
+	sk = netlink_lookup(sock_net(ssk), ssk->sk_protocol, NETLINK_CB(skb).portid);
 	if (sk == NULL) {
 		netlink_destroy_callback(cb);
 		return -ECONNREFUSED;
@@ -1840,7 +1840,7 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
 
 		sk = netlink_lookup(sock_net(in_skb->sk),
 				    in_skb->sk->sk_protocol,
-				    NETLINK_CB(in_skb).pid);
+				    NETLINK_CB(in_skb).portid);
 		if (sk) {
 			sk->sk_err = ENOBUFS;
 			sk->sk_error_report(sk);
@@ -1849,12 +1849,12 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
 		return;
 	}
 
-	rep = __nlmsg_put(skb, NETLINK_CB(in_skb).pid, nlh->nlmsg_seq,
+	rep = __nlmsg_put(skb, NETLINK_CB(in_skb).portid, nlh->nlmsg_seq,
 			  NLMSG_ERROR, payload, 0);
 	errmsg = nlmsg_data(rep);
 	errmsg->error = err;
 	memcpy(&errmsg->msg, nlh, err ? nlh->nlmsg_len : sizeof(*nlh));
-	netlink_unicast(in_skb->sk, skb, NETLINK_CB(in_skb).pid, MSG_DONTWAIT);
+	netlink_unicast(in_skb->sk, skb, NETLINK_CB(in_skb).portid, MSG_DONTWAIT);
 }
 EXPORT_SYMBOL(netlink_ack);
 
@@ -1904,33 +1904,33 @@ EXPORT_SYMBOL(netlink_rcv_skb);
  * nlmsg_notify - send a notification netlink message
  * @sk: netlink socket to use
  * @skb: notification message
- * @pid: destination netlink pid for reports or 0
+ * @portid: destination netlink portid for reports or 0
  * @group: destination multicast group or 0
  * @report: 1 to report back, 0 to disable
  * @flags: allocation flags
  */
-int nlmsg_notify(struct sock *sk, struct sk_buff *skb, u32 pid,
+int nlmsg_notify(struct sock *sk, struct sk_buff *skb, u32 portid,
 		 unsigned int group, int report, gfp_t flags)
 {
 	int err = 0;
 
 	if (group) {
-		int exclude_pid = 0;
+		int exclude_portid = 0;
 
 		if (report) {
 			atomic_inc(&skb->users);
-			exclude_pid = pid;
+			exclude_portid = portid;
 		}
 
 		/* errors reported via destination sk->sk_err, but propagate
 		 * delivery errors if NETLINK_BROADCAST_ERROR flag is set */
-		err = nlmsg_multicast(sk, skb, exclude_pid, group, flags);
+		err = nlmsg_multicast(sk, skb, exclude_portid, group, flags);
 	}
 
 	if (report) {
 		int err2;
 
-		err2 = nlmsg_unicast(sk, skb, pid);
+		err2 = nlmsg_unicast(sk, skb, portid);
 		if (!err || err == -ESRCH)
 			err = err2;
 	}
@@ -1955,7 +1955,7 @@ static struct sock *netlink_seq_socket_idx(struct seq_file *seq, loff_t pos)
 	loff_t off = 0;
 
 	for (i = 0; i < MAX_LINKS; i++) {
-		struct nl_pid_hash *hash = &nl_table[i].hash;
+		struct nl_portid_hash *hash = &nl_table[i].hash;
 
 		for (j = 0; j <= hash->mask; j++) {
 			sk_for_each(s, node, &hash->table[j]) {
@@ -2003,7 +2003,7 @@ static void *netlink_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	j = iter->hash_idx + 1;
 
 	do {
-		struct nl_pid_hash *hash = &nl_table[i].hash;
+		struct nl_portid_hash *hash = &nl_table[i].hash;
 
 		for (; j <= hash->mask; j++) {
 			s = sk_head(&hash->table[j]);
@@ -2042,7 +2042,7 @@ static int netlink_seq_show(struct seq_file *seq, void *v)
 		seq_printf(seq, "%pK %-3d %-6d %08x %-8d %-8d %pK %-8d %-8d %-8lu\n",
 			   s,
 			   s->sk_protocol,
-			   nlk->pid,
+			   nlk->portid,
 			   nlk->groups ? (u32)nlk->groups[0] : 0,
 			   sk_rmem_alloc_get(s),
 			   sk_wmem_alloc_get(s),
@@ -2187,12 +2187,12 @@ static int __init netlink_proto_init(void)
 	order = get_bitmask_order(min(limit, (unsigned long)UINT_MAX)) - 1;
 
 	for (i = 0; i < MAX_LINKS; i++) {
-		struct nl_pid_hash *hash = &nl_table[i].hash;
+		struct nl_portid_hash *hash = &nl_table[i].hash;
 
-		hash->table = nl_pid_hash_zalloc(1 * sizeof(*hash->table));
+		hash->table = nl_portid_hash_zalloc(1 * sizeof(*hash->table));
 		if (!hash->table) {
 			while (i-- > 0)
-				nl_pid_hash_free(nl_table[i].hash.table,
+				nl_portid_hash_free(nl_table[i].hash.table,
 						 1 * sizeof(*hash->table));
 			kfree(nl_table);
 			goto panic;
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index fda4974..6a04da1 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -501,7 +501,7 @@ EXPORT_SYMBOL(genl_unregister_family);
 /**
  * genlmsg_put - Add generic netlink header to netlink message
  * @skb: socket buffer holding the message
- * @pid: netlink pid the message is addressed to
+ * @portid: netlink portid the message is addressed to
  * @seq: sequence number (usually the one of the sender)
  * @family: generic netlink family
  * @flags: netlink message flags
@@ -509,13 +509,13 @@ EXPORT_SYMBOL(genl_unregister_family);
  *
  * Returns pointer to user specific header
  */
-void *genlmsg_put(struct sk_buff *skb, u32 pid, u32 seq,
+void *genlmsg_put(struct sk_buff *skb, u32 portid, u32 seq,
 				struct genl_family *family, int flags, u8 cmd)
 {
 	struct nlmsghdr *nlh;
 	struct genlmsghdr *hdr;
 
-	nlh = nlmsg_put(skb, pid, seq, family->id, GENL_HDRLEN +
+	nlh = nlmsg_put(skb, portid, seq, family->id, GENL_HDRLEN +
 			family->hdrsize, flags);
 	if (nlh == NULL)
 		return NULL;
@@ -585,7 +585,7 @@ static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	}
 
 	info.snd_seq = nlh->nlmsg_seq;
-	info.snd_pid = NETLINK_CB(skb).pid;
+	info.snd_portid = NETLINK_CB(skb).portid;
 	info.nlhdr = nlh;
 	info.genlhdr = nlmsg_data(nlh);
 	info.userhdr = nlmsg_data(nlh) + GENL_HDRLEN;
@@ -626,12 +626,12 @@ static struct genl_family genl_ctrl = {
 	.netnsok = true,
 };
 
-static int ctrl_fill_info(struct genl_family *family, u32 pid, u32 seq,
+static int ctrl_fill_info(struct genl_family *family, u32 portid, u32 seq,
 			  u32 flags, struct sk_buff *skb, u8 cmd)
 {
 	void *hdr;
 
-	hdr = genlmsg_put(skb, pid, seq, &genl_ctrl, flags, cmd);
+	hdr = genlmsg_put(skb, portid, seq, &genl_ctrl, flags, cmd);
 	if (hdr == NULL)
 		return -1;
 
@@ -701,7 +701,7 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
-static int ctrl_fill_mcgrp_info(struct genl_multicast_group *grp, u32 pid,
+static int ctrl_fill_mcgrp_info(struct genl_multicast_group *grp, u32 portid,
 				u32 seq, u32 flags, struct sk_buff *skb,
 				u8 cmd)
 {
@@ -709,7 +709,7 @@ static int ctrl_fill_mcgrp_info(struct genl_multicast_group *grp, u32 pid,
 	struct nlattr *nla_grps;
 	struct nlattr *nest;
 
-	hdr = genlmsg_put(skb, pid, seq, &genl_ctrl, flags, cmd);
+	hdr = genlmsg_put(skb, portid, seq, &genl_ctrl, flags, cmd);
 	if (hdr == NULL)
 		return -1;
 
@@ -756,7 +756,7 @@ static int ctrl_dumpfamily(struct sk_buff *skb, struct netlink_callback *cb)
 				continue;
 			if (++n < fams_to_skip)
 				continue;
-			if (ctrl_fill_info(rt, NETLINK_CB(cb->skb).pid,
+			if (ctrl_fill_info(rt, NETLINK_CB(cb->skb).portid,
 					   cb->nlh->nlmsg_seq, NLM_F_MULTI,
 					   skb, CTRL_CMD_NEWFAMILY) < 0)
 				goto errout;
@@ -773,7 +773,7 @@ errout:
 }
 
 static struct sk_buff *ctrl_build_family_msg(struct genl_family *family,
-					     u32 pid, int seq, u8 cmd)
+					     u32 portid, int seq, u8 cmd)
 {
 	struct sk_buff *skb;
 	int err;
@@ -782,7 +782,7 @@ static struct sk_buff *ctrl_build_family_msg(struct genl_family *family,
 	if (skb == NULL)
 		return ERR_PTR(-ENOBUFS);
 
-	err = ctrl_fill_info(family, pid, seq, 0, skb, cmd);
+	err = ctrl_fill_info(family, portid, seq, 0, skb, cmd);
 	if (err < 0) {
 		nlmsg_free(skb);
 		return ERR_PTR(err);
@@ -792,7 +792,7 @@ static struct sk_buff *ctrl_build_family_msg(struct genl_family *family,
 }
 
 static struct sk_buff *ctrl_build_mcgrp_msg(struct genl_multicast_group *grp,
-					    u32 pid, int seq, u8 cmd)
+					    u32 portid, int seq, u8 cmd)
 {
 	struct sk_buff *skb;
 	int err;
@@ -801,7 +801,7 @@ static struct sk_buff *ctrl_build_mcgrp_msg(struct genl_multicast_group *grp,
 	if (skb == NULL)
 		return ERR_PTR(-ENOBUFS);
 
-	err = ctrl_fill_mcgrp_info(grp, pid, seq, 0, skb, cmd);
+	err = ctrl_fill_mcgrp_info(grp, portid, seq, 0, skb, cmd);
 	if (err < 0) {
 		nlmsg_free(skb);
 		return ERR_PTR(err);
@@ -853,7 +853,7 @@ static int ctrl_getfamily(struct sk_buff *skb, struct genl_info *info)
 		return -ENOENT;
 	}
 
-	msg = ctrl_build_family_msg(res, info->snd_pid, info->snd_seq,
+	msg = ctrl_build_family_msg(res, info->snd_portid, info->snd_seq,
 				    CTRL_CMD_NEWFAMILY);
 	if (IS_ERR(msg))
 		return PTR_ERR(msg);
@@ -973,7 +973,7 @@ problem:
 
 subsys_initcall(genl_init);
 
-static int genlmsg_mcast(struct sk_buff *skb, u32 pid, unsigned long group,
+static int genlmsg_mcast(struct sk_buff *skb, u32 portid, unsigned long group,
 			 gfp_t flags)
 {
 	struct sk_buff *tmp;
@@ -988,7 +988,7 @@ static int genlmsg_mcast(struct sk_buff *skb, u32 pid, unsigned long group,
 				goto error;
 			}
 			err = nlmsg_multicast(prev->genl_sock, tmp,
-					      pid, group, flags);
+					      portid, group, flags);
 			if (err)
 				goto error;
 		}
@@ -996,20 +996,20 @@ static int genlmsg_mcast(struct sk_buff *skb, u32 pid, unsigned long group,
 		prev = net;
 	}
 
-	return nlmsg_multicast(prev->genl_sock, skb, pid, group, flags);
+	return nlmsg_multicast(prev->genl_sock, skb, portid, group, flags);
  error:
 	kfree_skb(skb);
 	return err;
 }
 
-int genlmsg_multicast_allns(struct sk_buff *skb, u32 pid, unsigned int group,
+int genlmsg_multicast_allns(struct sk_buff *skb, u32 portid, unsigned int group,
 			    gfp_t flags)
 {
-	return genlmsg_mcast(skb, pid, group, flags);
+	return genlmsg_mcast(skb, portid, group, flags);
 }
 EXPORT_SYMBOL(genlmsg_multicast_allns);
 
-void genl_notify(struct sk_buff *skb, struct net *net, u32 pid, u32 group,
+void genl_notify(struct sk_buff *skb, struct net *net, u32 portid, u32 group,
 		 struct nlmsghdr *nlh, gfp_t flags)
 {
 	struct sock *sk = net->genl_sock;
@@ -1018,6 +1018,6 @@ void genl_notify(struct sk_buff *skb, struct net *net, u32 pid, u32 group,
 	if (nlh)
 		report = nlmsg_report(nlh);
 
-	nlmsg_notify(sk, skb, pid, group, report, flags);
+	nlmsg_notify(sk, skb, portid, group, report, flags);
 }
 EXPORT_SYMBOL(genl_notify);
diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
index 4c51714..4bbb70e 100644
--- a/net/nfc/netlink.c
+++ b/net/nfc/netlink.c
@@ -58,7 +58,7 @@ static int nfc_genl_send_target(struct sk_buff *msg, struct nfc_target *target,
 {
 	void *hdr;
 
-	hdr = genlmsg_put(msg, NETLINK_CB(cb->skb).pid, cb->nlh->nlmsg_seq,
+	hdr = genlmsg_put(msg, NETLINK_CB(cb->skb).portid, cb->nlh->nlmsg_seq,
 			  &nfc_genl_family, flags, NFC_CMD_GET_TARGET);
 	if (!hdr)
 		return -EMSGSIZE;
@@ -165,7 +165,7 @@ int nfc_genl_targets_found(struct nfc_dev *dev)
 	struct sk_buff *msg;
 	void *hdr;
 
-	dev->genl_data.poll_req_pid = 0;
+	dev->genl_data.poll_req_portid = 0;
 
 	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
 	if (!msg)
@@ -347,13 +347,13 @@ free_msg:
 }
 
 static int nfc_genl_send_device(struct sk_buff *msg, struct nfc_dev *dev,
-				u32 pid, u32 seq,
+				u32 portid, u32 seq,
 				struct netlink_callback *cb,
 				int flags)
 {
 	void *hdr;
 
-	hdr = genlmsg_put(msg, pid, seq, &nfc_genl_family, flags,
+	hdr = genlmsg_put(msg, portid, seq, &nfc_genl_family, flags,
 			  NFC_CMD_GET_DEVICE);
 	if (!hdr)
 		return -EMSGSIZE;
@@ -401,7 +401,7 @@ static int nfc_genl_dump_devices(struct sk_buff *skb,
 	while (dev) {
 		int rc;
 
-		rc = nfc_genl_send_device(skb, dev, NETLINK_CB(cb->skb).pid,
+		rc = nfc_genl_send_device(skb, dev, NETLINK_CB(cb->skb).portid,
 					  cb->nlh->nlmsg_seq, cb, NLM_F_MULTI);
 		if (rc < 0)
 			break;
@@ -520,7 +520,7 @@ static int nfc_genl_get_device(struct sk_buff *skb, struct genl_info *info)
 		goto out_putdev;
 	}
 
-	rc = nfc_genl_send_device(msg, dev, info->snd_pid, info->snd_seq,
+	rc = nfc_genl_send_device(msg, dev, info->snd_portid, info->snd_seq,
 				  NULL, 0);
 	if (rc < 0)
 		goto out_free;
@@ -611,7 +611,7 @@ static int nfc_genl_start_poll(struct sk_buff *skb, struct genl_info *info)
 
 	rc = nfc_start_poll(dev, im_protocols, tm_protocols);
 	if (!rc)
-		dev->genl_data.poll_req_pid = info->snd_pid;
+		dev->genl_data.poll_req_portid = info->snd_portid;
 
 	mutex_unlock(&dev->genl_data.genl_data_mutex);
 
@@ -645,13 +645,13 @@ static int nfc_genl_stop_poll(struct sk_buff *skb, struct genl_info *info)
 
 	mutex_lock(&dev->genl_data.genl_data_mutex);
 
-	if (dev->genl_data.poll_req_pid != info->snd_pid) {
+	if (dev->genl_data.poll_req_portid != info->snd_portid) {
 		rc = -EBUSY;
 		goto out;
 	}
 
 	rc = nfc_stop_poll(dev);
-	dev->genl_data.poll_req_pid = 0;
+	dev->genl_data.poll_req_portid = 0;
 
 out:
 	mutex_unlock(&dev->genl_data.genl_data_mutex);
@@ -771,15 +771,15 @@ static int nfc_genl_rcv_nl_event(struct notifier_block *this,
 	if (event != NETLINK_URELEASE || n->protocol != NETLINK_GENERIC)
 		goto out;
 
-	pr_debug("NETLINK_URELEASE event from id %d\n", n->pid);
+	pr_debug("NETLINK_URELEASE event from id %d\n", n->portid);
 
 	nfc_device_iter_init(&iter);
 	dev = nfc_device_iter_next(&iter);
 
 	while (dev) {
-		if (dev->genl_data.poll_req_pid == n->pid) {
+		if (dev->genl_data.poll_req_portid == n->portid) {
 			nfc_stop_poll(dev);
-			dev->genl_data.poll_req_pid = 0;
+			dev->genl_data.poll_req_portid = 0;
 		}
 		dev = nfc_device_iter_next(&iter);
 	}
@@ -792,7 +792,7 @@ out:
 
 void nfc_genl_data_init(struct nfc_genl_data *genl_data)
 {
-	genl_data->poll_req_pid = 0;
+	genl_data->poll_req_portid = 0;
 	mutex_init(&genl_data->genl_data_mutex);
 }
 
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 0da6877..c7425f3 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -286,7 +286,7 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 	upcall.cmd = OVS_PACKET_CMD_ACTION;
 	upcall.key = &OVS_CB(skb)->flow->key;
 	upcall.userdata = NULL;
-	upcall.pid = 0;
+	upcall.portid = 0;
 
 	for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
 		 a = nla_next(a, &rem)) {
@@ -296,7 +296,7 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 			break;
 
 		case OVS_USERSPACE_ATTR_PID:
-			upcall.pid = nla_get_u32(a);
+			upcall.portid = nla_get_u32(a);
 			break;
 		}
 	}
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 105a0b5..56327e8 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -225,7 +225,7 @@ void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
 		upcall.cmd = OVS_PACKET_CMD_MISS;
 		upcall.key = &key;
 		upcall.userdata = NULL;
-		upcall.pid = p->upcall_pid;
+		upcall.portid = p->upcall_portid;
 		ovs_dp_upcall(dp, skb, &upcall);
 		consume_skb(skb);
 		stats_counter = &stats->n_missed;
@@ -261,7 +261,7 @@ int ovs_dp_upcall(struct datapath *dp, struct sk_buff *skb,
 	int dp_ifindex;
 	int err;
 
-	if (upcall_info->pid == 0) {
+	if (upcall_info->portid == 0) {
 		err = -ENOTCONN;
 		goto err;
 	}
@@ -395,7 +395,7 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
 
 	skb_copy_and_csum_dev(skb, nla_data(nla));
 
-	err = genlmsg_unicast(net, user_skb, upcall_info->pid);
+	err = genlmsg_unicast(net, user_skb, upcall_info->portid);
 
 out:
 	kfree_skb(nskb);
@@ -780,7 +780,7 @@ static struct genl_multicast_group ovs_dp_flow_multicast_group = {
 
 /* Called with genl_lock. */
 static int ovs_flow_cmd_fill_info(struct sw_flow *flow, struct datapath *dp,
-				  struct sk_buff *skb, u32 pid,
+				  struct sk_buff *skb, u32 portid,
 				  u32 seq, u32 flags, u8 cmd)
 {
 	const int skb_orig_len = skb->len;
@@ -795,7 +795,7 @@ static int ovs_flow_cmd_fill_info(struct sw_flow *flow, struct datapath *dp,
 	sf_acts = rcu_dereference_protected(flow->sf_acts,
 					    lockdep_genl_is_held());
 
-	ovs_header = genlmsg_put(skb, pid, seq, &dp_flow_genl_family, flags, cmd);
+	ovs_header = genlmsg_put(skb, portid, seq, &dp_flow_genl_family, flags, cmd);
 	if (!ovs_header)
 		return -EMSGSIZE;
 
@@ -879,7 +879,7 @@ static struct sk_buff *ovs_flow_cmd_alloc_info(struct sw_flow *flow)
 
 static struct sk_buff *ovs_flow_cmd_build_info(struct sw_flow *flow,
 					       struct datapath *dp,
-					       u32 pid, u32 seq, u8 cmd)
+					       u32 portid, u32 seq, u8 cmd)
 {
 	struct sk_buff *skb;
 	int retval;
@@ -888,7 +888,7 @@ static struct sk_buff *ovs_flow_cmd_build_info(struct sw_flow *flow,
 	if (!skb)
 		return ERR_PTR(-ENOMEM);
 
-	retval = ovs_flow_cmd_fill_info(flow, dp, skb, pid, seq, 0, cmd);
+	retval = ovs_flow_cmd_fill_info(flow, dp, skb, portid, seq, 0, cmd);
 	BUG_ON(retval < 0);
 	return skb;
 }
@@ -970,7 +970,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 		flow->hash = ovs_flow_hash(&key, key_len);
 		ovs_flow_tbl_insert(table, flow);
 
-		reply = ovs_flow_cmd_build_info(flow, dp, info->snd_pid,
+		reply = ovs_flow_cmd_build_info(flow, dp, info->snd_portid,
 						info->snd_seq,
 						OVS_FLOW_CMD_NEW);
 	} else {
@@ -1008,7 +1008,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 			ovs_flow_deferred_free_acts(old_acts);
 		}
 
-		reply = ovs_flow_cmd_build_info(flow, dp, info->snd_pid,
+		reply = ovs_flow_cmd_build_info(flow, dp, info->snd_portid,
 					       info->snd_seq, OVS_FLOW_CMD_NEW);
 
 		/* Clear stats. */
@@ -1020,7 +1020,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	if (!IS_ERR(reply))
-		genl_notify(reply, genl_info_net(info), info->snd_pid,
+		genl_notify(reply, genl_info_net(info), info->snd_portid,
 			   ovs_dp_flow_multicast_group.id, info->nlhdr,
 			   GFP_KERNEL);
 	else
@@ -1061,7 +1061,7 @@ static int ovs_flow_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	if (!flow)
 		return -ENOENT;
 
-	reply = ovs_flow_cmd_build_info(flow, dp, info->snd_pid,
+	reply = ovs_flow_cmd_build_info(flow, dp, info->snd_portid,
 					info->snd_seq, OVS_FLOW_CMD_NEW);
 	if (IS_ERR(reply))
 		return PTR_ERR(reply);
@@ -1103,13 +1103,13 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 
 	ovs_flow_tbl_remove(table, flow);
 
-	err = ovs_flow_cmd_fill_info(flow, dp, reply, info->snd_pid,
+	err = ovs_flow_cmd_fill_info(flow, dp, reply, info->snd_portid,
 				     info->snd_seq, 0, OVS_FLOW_CMD_DEL);
 	BUG_ON(err < 0);
 
 	ovs_flow_deferred_free(flow);
 
-	genl_notify(reply, genl_info_net(info), info->snd_pid,
+	genl_notify(reply, genl_info_net(info), info->snd_portid,
 		    ovs_dp_flow_multicast_group.id, info->nlhdr, GFP_KERNEL);
 	return 0;
 }
@@ -1137,7 +1137,7 @@ static int ovs_flow_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 			break;
 
 		if (ovs_flow_cmd_fill_info(flow, dp, skb,
-					   NETLINK_CB(cb->skb).pid,
+					   NETLINK_CB(cb->skb).portid,
 					   cb->nlh->nlmsg_seq, NLM_F_MULTI,
 					   OVS_FLOW_CMD_NEW) < 0)
 			break;
@@ -1191,13 +1191,13 @@ static struct genl_multicast_group ovs_dp_datapath_multicast_group = {
 };
 
 static int ovs_dp_cmd_fill_info(struct datapath *dp, struct sk_buff *skb,
-				u32 pid, u32 seq, u32 flags, u8 cmd)
+				u32 portid, u32 seq, u32 flags, u8 cmd)
 {
 	struct ovs_header *ovs_header;
 	struct ovs_dp_stats dp_stats;
 	int err;
 
-	ovs_header = genlmsg_put(skb, pid, seq, &dp_datapath_genl_family,
+	ovs_header = genlmsg_put(skb, portid, seq, &dp_datapath_genl_family,
 				   flags, cmd);
 	if (!ovs_header)
 		goto error;
@@ -1222,7 +1222,7 @@ error:
 	return -EMSGSIZE;
 }
 
-static struct sk_buff *ovs_dp_cmd_build_info(struct datapath *dp, u32 pid,
+static struct sk_buff *ovs_dp_cmd_build_info(struct datapath *dp, u32 portid,
 					     u32 seq, u8 cmd)
 {
 	struct sk_buff *skb;
@@ -1232,7 +1232,7 @@ static struct sk_buff *ovs_dp_cmd_build_info(struct datapath *dp, u32 pid,
 	if (!skb)
 		return ERR_PTR(-ENOMEM);
 
-	retval = ovs_dp_cmd_fill_info(dp, skb, pid, seq, 0, cmd);
+	retval = ovs_dp_cmd_fill_info(dp, skb, portid, seq, 0, cmd);
 	if (retval < 0) {
 		kfree_skb(skb);
 		return ERR_PTR(retval);
@@ -1311,7 +1311,7 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	parms.options = NULL;
 	parms.dp = dp;
 	parms.port_no = OVSP_LOCAL;
-	parms.upcall_pid = nla_get_u32(a[OVS_DP_ATTR_UPCALL_PID]);
+	parms.upcall_portid = nla_get_u32(a[OVS_DP_ATTR_UPCALL_PID]);
 
 	vport = new_vport(&parms);
 	if (IS_ERR(vport)) {
@@ -1322,7 +1322,7 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		goto err_destroy_ports_array;
 	}
 
-	reply = ovs_dp_cmd_build_info(dp, info->snd_pid,
+	reply = ovs_dp_cmd_build_info(dp, info->snd_portid,
 				      info->snd_seq, OVS_DP_CMD_NEW);
 	err = PTR_ERR(reply);
 	if (IS_ERR(reply))
@@ -1332,7 +1332,7 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	list_add_tail(&dp->list_node, &ovs_net->dps);
 	rtnl_unlock();
 
-	genl_notify(reply, genl_info_net(info), info->snd_pid,
+	genl_notify(reply, genl_info_net(info), info->snd_portid,
 		    ovs_dp_datapath_multicast_group.id, info->nlhdr,
 		    GFP_KERNEL);
 	return 0;
@@ -1394,7 +1394,7 @@ static int ovs_dp_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	if (IS_ERR(dp))
 		return err;
 
-	reply = ovs_dp_cmd_build_info(dp, info->snd_pid,
+	reply = ovs_dp_cmd_build_info(dp, info->snd_portid,
 				      info->snd_seq, OVS_DP_CMD_DEL);
 	err = PTR_ERR(reply);
 	if (IS_ERR(reply))
@@ -1402,7 +1402,7 @@ static int ovs_dp_cmd_del(struct sk_buff *skb, struct genl_info *info)
 
 	__dp_destroy(dp);
 
-	genl_notify(reply, genl_info_net(info), info->snd_pid,
+	genl_notify(reply, genl_info_net(info), info->snd_portid,
 		    ovs_dp_datapath_multicast_group.id, info->nlhdr,
 		    GFP_KERNEL);
 
@@ -1419,7 +1419,7 @@ static int ovs_dp_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	if (IS_ERR(dp))
 		return PTR_ERR(dp);
 
-	reply = ovs_dp_cmd_build_info(dp, info->snd_pid,
+	reply = ovs_dp_cmd_build_info(dp, info->snd_portid,
 				      info->snd_seq, OVS_DP_CMD_NEW);
 	if (IS_ERR(reply)) {
 		err = PTR_ERR(reply);
@@ -1428,7 +1428,7 @@ static int ovs_dp_cmd_set(struct sk_buff *skb, struct genl_info *info)
 		return 0;
 	}
 
-	genl_notify(reply, genl_info_net(info), info->snd_pid,
+	genl_notify(reply, genl_info_net(info), info->snd_portid,
 		    ovs_dp_datapath_multicast_group.id, info->nlhdr,
 		    GFP_KERNEL);
 
@@ -1444,7 +1444,7 @@ static int ovs_dp_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	if (IS_ERR(dp))
 		return PTR_ERR(dp);
 
-	reply = ovs_dp_cmd_build_info(dp, info->snd_pid,
+	reply = ovs_dp_cmd_build_info(dp, info->snd_portid,
 				      info->snd_seq, OVS_DP_CMD_NEW);
 	if (IS_ERR(reply))
 		return PTR_ERR(reply);
@@ -1461,7 +1461,7 @@ static int ovs_dp_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 
 	list_for_each_entry(dp, &ovs_net->dps, list_node) {
 		if (i >= skip &&
-		    ovs_dp_cmd_fill_info(dp, skb, NETLINK_CB(cb->skb).pid,
+		    ovs_dp_cmd_fill_info(dp, skb, NETLINK_CB(cb->skb).portid,
 					 cb->nlh->nlmsg_seq, NLM_F_MULTI,
 					 OVS_DP_CMD_NEW) < 0)
 			break;
@@ -1521,13 +1521,13 @@ struct genl_multicast_group ovs_dp_vport_multicast_group = {
 
 /* Called with RTNL lock or RCU read lock. */
 static int ovs_vport_cmd_fill_info(struct vport *vport, struct sk_buff *skb,
-				   u32 pid, u32 seq, u32 flags, u8 cmd)
+				   u32 portid, u32 seq, u32 flags, u8 cmd)
 {
 	struct ovs_header *ovs_header;
 	struct ovs_vport_stats vport_stats;
 	int err;
 
-	ovs_header = genlmsg_put(skb, pid, seq, &dp_vport_genl_family,
+	ovs_header = genlmsg_put(skb, portid, seq, &dp_vport_genl_family,
 				 flags, cmd);
 	if (!ovs_header)
 		return -EMSGSIZE;
@@ -1537,7 +1537,7 @@ static int ovs_vport_cmd_fill_info(struct vport *vport, struct sk_buff *skb,
 	if (nla_put_u32(skb, OVS_VPORT_ATTR_PORT_NO, vport->port_no) ||
 	    nla_put_u32(skb, OVS_VPORT_ATTR_TYPE, vport->ops->type) ||
 	    nla_put_string(skb, OVS_VPORT_ATTR_NAME, vport->ops->get_name(vport)) ||
-	    nla_put_u32(skb, OVS_VPORT_ATTR_UPCALL_PID, vport->upcall_pid))
+	    nla_put_u32(skb, OVS_VPORT_ATTR_UPCALL_PID, vport->upcall_portid))
 		goto nla_put_failure;
 
 	ovs_vport_get_stats(vport, &vport_stats);
@@ -1559,7 +1559,7 @@ error:
 }
 
 /* Called with RTNL lock or RCU read lock. */
-struct sk_buff *ovs_vport_cmd_build_info(struct vport *vport, u32 pid,
+struct sk_buff *ovs_vport_cmd_build_info(struct vport *vport, u32 portid,
 					 u32 seq, u8 cmd)
 {
 	struct sk_buff *skb;
@@ -1569,7 +1569,7 @@ struct sk_buff *ovs_vport_cmd_build_info(struct vport *vport, u32 pid,
 	if (!skb)
 		return ERR_PTR(-ENOMEM);
 
-	retval = ovs_vport_cmd_fill_info(vport, skb, pid, seq, 0, cmd);
+	retval = ovs_vport_cmd_fill_info(vport, skb, portid, seq, 0, cmd);
 	if (retval < 0) {
 		kfree_skb(skb);
 		return ERR_PTR(retval);
@@ -1661,21 +1661,21 @@ static int ovs_vport_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	parms.options = a[OVS_VPORT_ATTR_OPTIONS];
 	parms.dp = dp;
 	parms.port_no = port_no;
-	parms.upcall_pid = nla_get_u32(a[OVS_VPORT_ATTR_UPCALL_PID]);
+	parms.upcall_portid = nla_get_u32(a[OVS_VPORT_ATTR_UPCALL_PID]);
 
 	vport = new_vport(&parms);
 	err = PTR_ERR(vport);
 	if (IS_ERR(vport))
 		goto exit_unlock;
 
-	reply = ovs_vport_cmd_build_info(vport, info->snd_pid, info->snd_seq,
+	reply = ovs_vport_cmd_build_info(vport, info->snd_portid, info->snd_seq,
 					 OVS_VPORT_CMD_NEW);
 	if (IS_ERR(reply)) {
 		err = PTR_ERR(reply);
 		ovs_dp_detach_port(vport);
 		goto exit_unlock;
 	}
-	genl_notify(reply, genl_info_net(info), info->snd_pid,
+	genl_notify(reply, genl_info_net(info), info->snd_portid,
 		    ovs_dp_vport_multicast_group.id, info->nlhdr, GFP_KERNEL);
 
 exit_unlock:
@@ -1707,9 +1707,9 @@ static int ovs_vport_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	if (err)
 		goto exit_unlock;
 	if (a[OVS_VPORT_ATTR_UPCALL_PID])
-		vport->upcall_pid = nla_get_u32(a[OVS_VPORT_ATTR_UPCALL_PID]);
+		vport->upcall_portid = nla_get_u32(a[OVS_VPORT_ATTR_UPCALL_PID]);
 
-	reply = ovs_vport_cmd_build_info(vport, info->snd_pid, info->snd_seq,
+	reply = ovs_vport_cmd_build_info(vport, info->snd_portid, info->snd_seq,
 					 OVS_VPORT_CMD_NEW);
 	if (IS_ERR(reply)) {
 		netlink_set_err(sock_net(skb->sk)->genl_sock, 0,
@@ -1717,7 +1717,7 @@ static int ovs_vport_cmd_set(struct sk_buff *skb, struct genl_info *info)
 		goto exit_unlock;
 	}
 
-	genl_notify(reply, genl_info_net(info), info->snd_pid,
+	genl_notify(reply, genl_info_net(info), info->snd_portid,
 		    ovs_dp_vport_multicast_group.id, info->nlhdr, GFP_KERNEL);
 
 exit_unlock:
@@ -1743,7 +1743,7 @@ static int ovs_vport_cmd_del(struct sk_buff *skb, struct genl_info *info)
 		goto exit_unlock;
 	}
 
-	reply = ovs_vport_cmd_build_info(vport, info->snd_pid, info->snd_seq,
+	reply = ovs_vport_cmd_build_info(vport, info->snd_portid, info->snd_seq,
 					 OVS_VPORT_CMD_DEL);
 	err = PTR_ERR(reply);
 	if (IS_ERR(reply))
@@ -1751,7 +1751,7 @@ static int ovs_vport_cmd_del(struct sk_buff *skb, struct genl_info *info)
 
 	ovs_dp_detach_port(vport);
 
-	genl_notify(reply, genl_info_net(info), info->snd_pid,
+	genl_notify(reply, genl_info_net(info), info->snd_portid,
 		    ovs_dp_vport_multicast_group.id, info->nlhdr, GFP_KERNEL);
 
 exit_unlock:
@@ -1773,7 +1773,7 @@ static int ovs_vport_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	if (IS_ERR(vport))
 		goto exit_unlock;
 
-	reply = ovs_vport_cmd_build_info(vport, info->snd_pid, info->snd_seq,
+	reply = ovs_vport_cmd_build_info(vport, info->snd_portid, info->snd_seq,
 					 OVS_VPORT_CMD_NEW);
 	err = PTR_ERR(reply);
 	if (IS_ERR(reply))
@@ -1808,7 +1808,7 @@ static int ovs_vport_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 		hlist_for_each_entry_rcu(vport, n, &dp->ports[i], dp_hash_node) {
 			if (j >= skip &&
 			    ovs_vport_cmd_fill_info(vport, skb,
-						    NETLINK_CB(cb->skb).pid,
+						    NETLINK_CB(cb->skb).portid,
 						    cb->nlh->nlmsg_seq,
 						    NLM_F_MULTI,
 						    OVS_VPORT_CMD_NEW) < 0)
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 129ec54..031dfbf 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -129,7 +129,7 @@ struct dp_upcall_info {
 	u8 cmd;
 	const struct sw_flow_key *key;
 	const struct nlattr *userdata;
-	u32 pid;
+	u32 portid;
 };
 
 static inline struct net *ovs_dp_get_net(struct datapath *dp)
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 1abd960..9055dd6 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -125,7 +125,7 @@ struct vport *ovs_vport_alloc(int priv_size, const struct vport_ops *ops,
 
 	vport->dp = parms->dp;
 	vport->port_no = parms->port_no;
-	vport->upcall_pid = parms->upcall_pid;
+	vport->upcall_portid = parms->upcall_portid;
 	vport->ops = ops;
 	INIT_HLIST_NODE(&vport->dp_hash_node);
 
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index c56e483..3f7961e 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -70,7 +70,7 @@ struct vport_err_stats {
  * @rcu: RCU callback head for deferred destruction.
  * @port_no: Index into @dp's @ports array.
  * @dp: Datapath to which this port belongs.
- * @upcall_pid: The Netlink port to use for packets received on this port that
+ * @upcall_portid: The Netlink port to use for packets received on this port that
  * miss the flow table.
  * @hash_node: Element in @dev_table hash table in vport.c.
  * @dp_hash_node: Element in @datapath->ports hash table in datapath.c.
@@ -83,7 +83,7 @@ struct vport {
 	struct rcu_head rcu;
 	u16 port_no;
 	struct datapath	*dp;
-	u32 upcall_pid;
+	u32 upcall_portid;
 
 	struct hlist_node hash_node;
 	struct hlist_node dp_hash_node;
@@ -113,7 +113,7 @@ struct vport_parms {
 	/* For ovs_vport_alloc(). */
 	struct datapath *dp;
 	u16 port_no;
-	u32 upcall_pid;
+	u32 upcall_portid;
 };
 
 /**
diff --git a/net/packet/diag.c b/net/packet/diag.c
index 39bce0d..8db6e21 100644
--- a/net/packet/diag.c
+++ b/net/packet/diag.c
@@ -126,13 +126,13 @@ static int pdiag_put_fanout(struct packet_sock *po, struct sk_buff *nlskb)
 }
 
 static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct packet_diag_req *req,
-		u32 pid, u32 seq, u32 flags, int sk_ino)
+		u32 portid, u32 seq, u32 flags, int sk_ino)
 {
 	struct nlmsghdr *nlh;
 	struct packet_diag_msg *rp;
 	struct packet_sock *po = pkt_sk(sk);
 
-	nlh = nlmsg_put(skb, pid, seq, SOCK_DIAG_BY_FAMILY, sizeof(*rp), flags);
+	nlh = nlmsg_put(skb, portid, seq, SOCK_DIAG_BY_FAMILY, sizeof(*rp), flags);
 	if (!nlh)
 		return -EMSGSIZE;
 
@@ -184,7 +184,7 @@ static int packet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 		if (num < s_num)
 			goto next;
 
-		if (sk_diag_fill(sk, skb, req, NETLINK_CB(cb->skb).pid,
+		if (sk_diag_fill(sk, skb, req, NETLINK_CB(cb->skb).portid,
 					cb->nlh->nlmsg_seq, NLM_F_MULTI,
 					sock_i_ino(sk)) < 0)
 			goto done;
diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
index 7dd762a..83a8389 100644
--- a/net/phonet/pn_netlink.c
+++ b/net/phonet/pn_netlink.c
@@ -33,7 +33,7 @@
 /* Device address handling */
 
 static int fill_addr(struct sk_buff *skb, struct net_device *dev, u8 addr,
-		     u32 pid, u32 seq, int event);
+		     u32 portid, u32 seq, int event);
 
 void phonet_address_notify(int event, struct net_device *dev, u8 addr)
 {
@@ -101,12 +101,12 @@ static int addr_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *attr)
 }
 
 static int fill_addr(struct sk_buff *skb, struct net_device *dev, u8 addr,
-			u32 pid, u32 seq, int event)
+			u32 portid, u32 seq, int event)
 {
 	struct ifaddrmsg *ifm;
 	struct nlmsghdr *nlh;
 
-	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*ifm), 0);
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*ifm), 0);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
@@ -148,7 +148,7 @@ static int getaddr_dumpit(struct sk_buff *skb, struct netlink_callback *cb)
 				continue;
 
 			if (fill_addr(skb, pnd->netdev, addr << 2,
-					 NETLINK_CB(cb->skb).pid,
+					 NETLINK_CB(cb->skb).portid,
 					cb->nlh->nlmsg_seq, RTM_NEWADDR) < 0)
 				goto out;
 		}
@@ -165,12 +165,12 @@ out:
 /* Routes handling */
 
 static int fill_route(struct sk_buff *skb, struct net_device *dev, u8 dst,
-			u32 pid, u32 seq, int event)
+			u32 portid, u32 seq, int event)
 {
 	struct rtmsg *rtm;
 	struct nlmsghdr *nlh;
 
-	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*rtm), 0);
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*rtm), 0);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
@@ -276,7 +276,7 @@ static int route_dumpit(struct sk_buff *skb, struct netlink_callback *cb)
 
 		if (addr_idx++ < addr_start_idx)
 			continue;
-		if (fill_route(skb, dev, addr << 2, NETLINK_CB(cb->skb).pid,
+		if (fill_route(skb, dev, addr << 2, NETLINK_CB(cb->skb).portid,
 				cb->nlh->nlmsg_seq, RTM_NEWROUTE))
 			goto out;
 	}
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index e3d2c78..102761d 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -644,7 +644,7 @@ errout:
 }
 
 static int
-tca_get_fill(struct sk_buff *skb, struct tc_action *a, u32 pid, u32 seq,
+tca_get_fill(struct sk_buff *skb, struct tc_action *a, u32 portid, u32 seq,
 	     u16 flags, int event, int bind, int ref)
 {
 	struct tcamsg *t;
@@ -652,7 +652,7 @@ tca_get_fill(struct sk_buff *skb, struct tc_action *a, u32 pid, u32 seq,
 	unsigned char *b = skb_tail_pointer(skb);
 	struct nlattr *nest;
 
-	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*t), flags);
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*t), flags);
 	if (!nlh)
 		goto out_nlmsg_trim;
 	t = nlmsg_data(nlh);
@@ -678,7 +678,7 @@ out_nlmsg_trim:
 }
 
 static int
-act_get_notify(struct net *net, u32 pid, struct nlmsghdr *n,
+act_get_notify(struct net *net, u32 portid, struct nlmsghdr *n,
 	       struct tc_action *a, int event)
 {
 	struct sk_buff *skb;
@@ -686,16 +686,16 @@ act_get_notify(struct net *net, u32 pid, struct nlmsghdr *n,
 	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (!skb)
 		return -ENOBUFS;
-	if (tca_get_fill(skb, a, pid, n->nlmsg_seq, 0, event, 0, 0) <= 0) {
+	if (tca_get_fill(skb, a, portid, n->nlmsg_seq, 0, event, 0, 0) <= 0) {
 		kfree_skb(skb);
 		return -EINVAL;
 	}
 
-	return rtnl_unicast(skb, net, pid);
+	return rtnl_unicast(skb, net, portid);
 }
 
 static struct tc_action *
-tcf_action_get_1(struct nlattr *nla, struct nlmsghdr *n, u32 pid)
+tcf_action_get_1(struct nlattr *nla, struct nlmsghdr *n, u32 portid)
 {
 	struct nlattr *tb[TCA_ACT_MAX + 1];
 	struct tc_action *a;
@@ -762,7 +762,7 @@ static struct tc_action *create_a(int i)
 }
 
 static int tca_action_flush(struct net *net, struct nlattr *nla,
-			    struct nlmsghdr *n, u32 pid)
+			    struct nlmsghdr *n, u32 portid)
 {
 	struct sk_buff *skb;
 	unsigned char *b;
@@ -799,7 +799,7 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 	if (a->ops == NULL)
 		goto err_out;
 
-	nlh = nlmsg_put(skb, pid, n->nlmsg_seq, RTM_DELACTION, sizeof(*t), 0);
+	nlh = nlmsg_put(skb, portid, n->nlmsg_seq, RTM_DELACTION, sizeof(*t), 0);
 	if (!nlh)
 		goto out_module_put;
 	t = nlmsg_data(nlh);
@@ -823,7 +823,7 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 	nlh->nlmsg_flags |= NLM_F_ROOT;
 	module_put(a->ops->owner);
 	kfree(a);
-	err = rtnetlink_send(skb, net, pid, RTNLGRP_TC,
+	err = rtnetlink_send(skb, net, portid, RTNLGRP_TC,
 			     n->nlmsg_flags & NLM_F_ECHO);
 	if (err > 0)
 		return 0;
@@ -841,7 +841,7 @@ noflush_out:
 
 static int
 tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
-	      u32 pid, int event)
+	      u32 portid, int event)
 {
 	int i, ret;
 	struct nlattr *tb[TCA_ACT_MAX_PRIO + 1];
@@ -853,13 +853,13 @@ tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
 
 	if (event == RTM_DELACTION && n->nlmsg_flags & NLM_F_ROOT) {
 		if (tb[1] != NULL)
-			return tca_action_flush(net, tb[1], n, pid);
+			return tca_action_flush(net, tb[1], n, portid);
 		else
 			return -EINVAL;
 	}
 
 	for (i = 1; i <= TCA_ACT_MAX_PRIO && tb[i]; i++) {
-		act = tcf_action_get_1(tb[i], n, pid);
+		act = tcf_action_get_1(tb[i], n, portid);
 		if (IS_ERR(act)) {
 			ret = PTR_ERR(act);
 			goto err;
@@ -874,7 +874,7 @@ tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
 	}
 
 	if (event == RTM_GETACTION)
-		ret = act_get_notify(net, pid, n, head, event);
+		ret = act_get_notify(net, portid, n, head, event);
 	else { /* delete */
 		struct sk_buff *skb;
 
@@ -884,7 +884,7 @@ tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
 			goto err;
 		}
 
-		if (tca_get_fill(skb, head, pid, n->nlmsg_seq, 0, event,
+		if (tca_get_fill(skb, head, portid, n->nlmsg_seq, 0, event,
 				 0, 1) <= 0) {
 			kfree_skb(skb);
 			ret = -EINVAL;
@@ -893,7 +893,7 @@ tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
 
 		/* now do the delete */
 		tcf_action_destroy(head, 0);
-		ret = rtnetlink_send(skb, net, pid, RTNLGRP_TC,
+		ret = rtnetlink_send(skb, net, portid, RTNLGRP_TC,
 				     n->nlmsg_flags & NLM_F_ECHO);
 		if (ret > 0)
 			return 0;
@@ -905,7 +905,7 @@ err:
 }
 
 static int tcf_add_notify(struct net *net, struct tc_action *a,
-			  u32 pid, u32 seq, int event, u16 flags)
+			  u32 portid, u32 seq, int event, u16 flags)
 {
 	struct tcamsg *t;
 	struct nlmsghdr *nlh;
@@ -920,7 +920,7 @@ static int tcf_add_notify(struct net *net, struct tc_action *a,
 
 	b = skb_tail_pointer(skb);
 
-	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*t), flags);
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*t), flags);
 	if (!nlh)
 		goto out_kfree_skb;
 	t = nlmsg_data(nlh);
@@ -940,7 +940,7 @@ static int tcf_add_notify(struct net *net, struct tc_action *a,
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	NETLINK_CB(skb).dst_group = RTNLGRP_TC;
 
-	err = rtnetlink_send(skb, net, pid, RTNLGRP_TC, flags & NLM_F_ECHO);
+	err = rtnetlink_send(skb, net, portid, RTNLGRP_TC, flags & NLM_F_ECHO);
 	if (err > 0)
 		err = 0;
 	return err;
@@ -953,7 +953,7 @@ out_kfree_skb:
 
 static int
 tcf_action_add(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
-	       u32 pid, int ovr)
+	       u32 portid, int ovr)
 {
 	int ret = 0;
 	struct tc_action *act;
@@ -971,7 +971,7 @@ tcf_action_add(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
 	/* dump then free all the actions after update; inserted policy
 	 * stays intact
 	 */
-	ret = tcf_add_notify(net, act, pid, seq, RTM_NEWACTION, n->nlmsg_flags);
+	ret = tcf_add_notify(net, act, portid, seq, RTM_NEWACTION, n->nlmsg_flags);
 	for (a = act; a; a = act) {
 		act = a->next;
 		kfree(a);
@@ -984,7 +984,7 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *tca[TCA_ACT_MAX + 1];
-	u32 pid = skb ? NETLINK_CB(skb).pid : 0;
+	u32 portid = skb ? NETLINK_CB(skb).portid : 0;
 	int ret = 0, ovr = 0;
 
 	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCA_ACT_MAX, NULL);
@@ -1008,17 +1008,17 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 		if (n->nlmsg_flags & NLM_F_REPLACE)
 			ovr = 1;
 replay:
-		ret = tcf_action_add(net, tca[TCA_ACT_TAB], n, pid, ovr);
+		ret = tcf_action_add(net, tca[TCA_ACT_TAB], n, portid, ovr);
 		if (ret == -EAGAIN)
 			goto replay;
 		break;
 	case RTM_DELACTION:
 		ret = tca_action_gd(net, tca[TCA_ACT_TAB], n,
-				    pid, RTM_DELACTION);
+				    portid, RTM_DELACTION);
 		break;
 	case RTM_GETACTION:
 		ret = tca_action_gd(net, tca[TCA_ACT_TAB], n,
-				    pid, RTM_GETACTION);
+				    portid, RTM_GETACTION);
 		break;
 	default:
 		BUG();
@@ -1085,7 +1085,7 @@ tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 		goto out_module_put;
 	}
 
-	nlh = nlmsg_put(skb, NETLINK_CB(cb->skb).pid, cb->nlh->nlmsg_seq,
+	nlh = nlmsg_put(skb, NETLINK_CB(cb->skb).portid, cb->nlh->nlmsg_seq,
 			cb->nlh->nlmsg_type, sizeof(*t), 0);
 	if (!nlh)
 		goto out_module_put;
@@ -1109,7 +1109,7 @@ tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 		nla_nest_cancel(skb, nest);
 
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
-	if (NETLINK_CB(cb->skb).pid && ret)
+	if (NETLINK_CB(cb->skb).portid && ret)
 		nlh->nlmsg_flags |= NLM_F_MULTI;
 	module_put(a_o->owner);
 	return skb->len;
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index dc3ef5a..7ae0289 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -343,13 +343,13 @@ errout:
 }
 
 static int tcf_fill_node(struct sk_buff *skb, struct tcf_proto *tp,
-			 unsigned long fh, u32 pid, u32 seq, u16 flags, int event)
+			 unsigned long fh, u32 portid, u32 seq, u16 flags, int event)
 {
 	struct tcmsg *tcm;
 	struct nlmsghdr  *nlh;
 	unsigned char *b = skb_tail_pointer(skb);
 
-	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*tcm), flags);
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*tcm), flags);
 	if (!nlh)
 		goto out_nlmsg_trim;
 	tcm = nlmsg_data(nlh);
@@ -381,18 +381,18 @@ static int tfilter_notify(struct net *net, struct sk_buff *oskb,
 			  unsigned long fh, int event)
 {
 	struct sk_buff *skb;
-	u32 pid = oskb ? NETLINK_CB(oskb).pid : 0;
+	u32 portid = oskb ? NETLINK_CB(oskb).portid : 0;
 
 	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (!skb)
 		return -ENOBUFS;
 
-	if (tcf_fill_node(skb, tp, fh, pid, n->nlmsg_seq, 0, event) <= 0) {
+	if (tcf_fill_node(skb, tp, fh, portid, n->nlmsg_seq, 0, event) <= 0) {
 		kfree_skb(skb);
 		return -EINVAL;
 	}
 
-	return rtnetlink_send(skb, net, pid, RTNLGRP_TC,
+	return rtnetlink_send(skb, net, portid, RTNLGRP_TC,
 			      n->nlmsg_flags & NLM_F_ECHO);
 }
 
@@ -407,7 +407,7 @@ static int tcf_node_dump(struct tcf_proto *tp, unsigned long n,
 {
 	struct tcf_dump_args *a = (void *)arg;
 
-	return tcf_fill_node(a->skb, tp, n, NETLINK_CB(a->cb->skb).pid,
+	return tcf_fill_node(a->skb, tp, n, NETLINK_CB(a->cb->skb).portid,
 			     a->cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWTFILTER);
 }
 
@@ -465,7 +465,7 @@ static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
 		if (t > s_t)
 			memset(&cb->args[1], 0, sizeof(cb->args)-sizeof(cb->args[0]));
 		if (cb->args[1] == 0) {
-			if (tcf_fill_node(skb, tp, 0, NETLINK_CB(cb->skb).pid,
+			if (tcf_fill_node(skb, tp, 0, NETLINK_CB(cb->skb).portid,
 					  cb->nlh->nlmsg_seq, NLM_F_MULTI,
 					  RTM_NEWTFILTER) <= 0)
 				break;
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index a08b4ab..a18d975 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1185,7 +1185,7 @@ graft:
 }
 
 static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
-			 u32 pid, u32 seq, u16 flags, int event)
+			 u32 portid, u32 seq, u16 flags, int event)
 {
 	struct tcmsg *tcm;
 	struct nlmsghdr  *nlh;
@@ -1193,7 +1193,7 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 	struct gnet_dump d;
 	struct qdisc_size_table *stab;
 
-	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*tcm), flags);
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*tcm), flags);
 	if (!nlh)
 		goto out_nlmsg_trim;
 	tcm = nlmsg_data(nlh);
@@ -1248,25 +1248,25 @@ static int qdisc_notify(struct net *net, struct sk_buff *oskb,
 			struct Qdisc *old, struct Qdisc *new)
 {
 	struct sk_buff *skb;
-	u32 pid = oskb ? NETLINK_CB(oskb).pid : 0;
+	u32 portid = oskb ? NETLINK_CB(oskb).portid : 0;
 
 	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (!skb)
 		return -ENOBUFS;
 
 	if (old && !tc_qdisc_dump_ignore(old)) {
-		if (tc_fill_qdisc(skb, old, clid, pid, n->nlmsg_seq,
+		if (tc_fill_qdisc(skb, old, clid, portid, n->nlmsg_seq,
 				  0, RTM_DELQDISC) < 0)
 			goto err_out;
 	}
 	if (new && !tc_qdisc_dump_ignore(new)) {
-		if (tc_fill_qdisc(skb, new, clid, pid, n->nlmsg_seq,
+		if (tc_fill_qdisc(skb, new, clid, portid, n->nlmsg_seq,
 				  old ? NLM_F_REPLACE : 0, RTM_NEWQDISC) < 0)
 			goto err_out;
 	}
 
 	if (skb->len)
-		return rtnetlink_send(skb, net, pid, RTNLGRP_TC,
+		return rtnetlink_send(skb, net, portid, RTNLGRP_TC,
 				      n->nlmsg_flags & NLM_F_ECHO);
 
 err_out:
@@ -1289,7 +1289,7 @@ static int tc_dump_qdisc_root(struct Qdisc *root, struct sk_buff *skb,
 		q_idx++;
 	} else {
 		if (!tc_qdisc_dump_ignore(q) &&
-		    tc_fill_qdisc(skb, q, q->parent, NETLINK_CB(cb->skb).pid,
+		    tc_fill_qdisc(skb, q, q->parent, NETLINK_CB(cb->skb).portid,
 				  cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWQDISC) <= 0)
 			goto done;
 		q_idx++;
@@ -1300,7 +1300,7 @@ static int tc_dump_qdisc_root(struct Qdisc *root, struct sk_buff *skb,
 			continue;
 		}
 		if (!tc_qdisc_dump_ignore(q) &&
-		    tc_fill_qdisc(skb, q, q->parent, NETLINK_CB(cb->skb).pid,
+		    tc_fill_qdisc(skb, q, q->parent, NETLINK_CB(cb->skb).portid,
 				  cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWQDISC) <= 0)
 			goto done;
 		q_idx++;
@@ -1375,7 +1375,7 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	const struct Qdisc_class_ops *cops;
 	unsigned long cl = 0;
 	unsigned long new_cl;
-	u32 pid = tcm->tcm_parent;
+	u32 portid = tcm->tcm_parent;
 	u32 clid = tcm->tcm_handle;
 	u32 qid = TC_H_MAJ(clid);
 	int err;
@@ -1403,8 +1403,8 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 
 	/* Step 1. Determine qdisc handle X:0 */
 
-	if (pid != TC_H_ROOT) {
-		u32 qid1 = TC_H_MAJ(pid);
+	if (portid != TC_H_ROOT) {
+		u32 qid1 = TC_H_MAJ(portid);
 
 		if (qid && qid1) {
 			/* If both majors are known, they must be identical. */
@@ -1418,10 +1418,10 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 		/* Now qid is genuine qdisc handle consistent
 		 * both with parent and child.
 		 *
-		 * TC_H_MAJ(pid) still may be unspecified, complete it now.
+		 * TC_H_MAJ(portid) still may be unspecified, complete it now.
 		 */
-		if (pid)
-			pid = TC_H_MAKE(qid, pid);
+		if (portid)
+			portid = TC_H_MAKE(qid, portid);
 	} else {
 		if (qid == 0)
 			qid = dev->qdisc->handle;
@@ -1439,7 +1439,7 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 
 	/* Now try to get class */
 	if (clid == 0) {
-		if (pid == TC_H_ROOT)
+		if (portid == TC_H_ROOT)
 			clid = qid;
 	} else
 		clid = TC_H_MAKE(qid, clid);
@@ -1478,7 +1478,7 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	new_cl = cl;
 	err = -EOPNOTSUPP;
 	if (cops->change)
-		err = cops->change(q, clid, pid, tca, &new_cl);
+		err = cops->change(q, clid, portid, tca, &new_cl);
 	if (err == 0)
 		tclass_notify(net, skb, n, q, new_cl, RTM_NEWTCLASS);
 
@@ -1492,7 +1492,7 @@ out:
 
 static int tc_fill_tclass(struct sk_buff *skb, struct Qdisc *q,
 			  unsigned long cl,
-			  u32 pid, u32 seq, u16 flags, int event)
+			  u32 portid, u32 seq, u16 flags, int event)
 {
 	struct tcmsg *tcm;
 	struct nlmsghdr  *nlh;
@@ -1500,7 +1500,7 @@ static int tc_fill_tclass(struct sk_buff *skb, struct Qdisc *q,
 	struct gnet_dump d;
 	const struct Qdisc_class_ops *cl_ops = q->ops->cl_ops;
 
-	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*tcm), flags);
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(*tcm), flags);
 	if (!nlh)
 		goto out_nlmsg_trim;
 	tcm = nlmsg_data(nlh);
@@ -1540,18 +1540,18 @@ static int tclass_notify(struct net *net, struct sk_buff *oskb,
 			 unsigned long cl, int event)
 {
 	struct sk_buff *skb;
-	u32 pid = oskb ? NETLINK_CB(oskb).pid : 0;
+	u32 portid = oskb ? NETLINK_CB(oskb).portid : 0;
 
 	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (!skb)
 		return -ENOBUFS;
 
-	if (tc_fill_tclass(skb, q, cl, pid, n->nlmsg_seq, 0, event) < 0) {
+	if (tc_fill_tclass(skb, q, cl, portid, n->nlmsg_seq, 0, event) < 0) {
 		kfree_skb(skb);
 		return -EINVAL;
 	}
 
-	return rtnetlink_send(skb, net, pid, RTNLGRP_TC,
+	return rtnetlink_send(skb, net, portid, RTNLGRP_TC,
 			      n->nlmsg_flags & NLM_F_ECHO);
 }
 
@@ -1565,7 +1565,7 @@ static int qdisc_class_dump(struct Qdisc *q, unsigned long cl, struct qdisc_walk
 {
 	struct qdisc_dump_args *a = (struct qdisc_dump_args *)arg;
 
-	return tc_fill_tclass(a->skb, q, cl, NETLINK_CB(a->cb->skb).pid,
+	return tc_fill_tclass(a->skb, q, cl, NETLINK_CB(a->cb->skb).portid,
 			      a->cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWTCLASS);
 }
 
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index 47a839d..6675914 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -62,7 +62,7 @@ static int handle_cmd(struct sk_buff *skb, struct genl_info *info)
 		rep_nlh = nlmsg_hdr(rep_buf);
 		memcpy(rep_nlh, req_nlh, hdr_space);
 		rep_nlh->nlmsg_len = rep_buf->len;
-		genlmsg_unicast(&init_net, rep_buf, NETLINK_CB(skb).pid);
+		genlmsg_unicast(&init_net, rep_buf, NETLINK_CB(skb).portid);
 	}
 
 	return 0;
diff --git a/net/unix/diag.c b/net/unix/diag.c
index 750b134..06748f1 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -110,12 +110,12 @@ static int sk_diag_show_rqlen(struct sock *sk, struct sk_buff *nlskb)
 }
 
 static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct unix_diag_req *req,
-		u32 pid, u32 seq, u32 flags, int sk_ino)
+		u32 portid, u32 seq, u32 flags, int sk_ino)
 {
 	struct nlmsghdr *nlh;
 	struct unix_diag_msg *rep;
 
-	nlh = nlmsg_put(skb, pid, seq, SOCK_DIAG_BY_FAMILY, sizeof(*rep),
+	nlh = nlmsg_put(skb, portid, seq, SOCK_DIAG_BY_FAMILY, sizeof(*rep),
 			flags);
 	if (!nlh)
 		return -EMSGSIZE;
@@ -159,7 +159,7 @@ out_nlmsg_trim:
 }
 
 static int sk_diag_dump(struct sock *sk, struct sk_buff *skb, struct unix_diag_req *req,
-		u32 pid, u32 seq, u32 flags)
+		u32 portid, u32 seq, u32 flags)
 {
 	int sk_ino;
 
@@ -170,7 +170,7 @@ static int sk_diag_dump(struct sock *sk, struct sk_buff *skb, struct unix_diag_r
 	if (!sk_ino)
 		return 0;
 
-	return sk_diag_fill(sk, skb, req, pid, seq, flags, sk_ino);
+	return sk_diag_fill(sk, skb, req, portid, seq, flags, sk_ino);
 }
 
 static int unix_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
@@ -200,7 +200,7 @@ static int unix_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 			if (!(req->udiag_states & (1 << sk->sk_state)))
 				goto next;
 			if (sk_diag_dump(sk, skb, req,
-					 NETLINK_CB(cb->skb).pid,
+					 NETLINK_CB(cb->skb).portid,
 					 cb->nlh->nlmsg_seq,
 					 NLM_F_MULTI) < 0)
 				goto done;
@@ -267,7 +267,7 @@ again:
 	if (!rep)
 		goto out;
 
-	err = sk_diag_fill(sk, rep, req, NETLINK_CB(in_skb).pid,
+	err = sk_diag_fill(sk, rep, req, NETLINK_CB(in_skb).portid,
 			   nlh->nlmsg_seq, 0, req->udiag_ino);
 	if (err < 0) {
 		nlmsg_free(rep);
@@ -277,7 +277,7 @@ again:
 
 		goto again;
 	}
-	err = netlink_unicast(net->diag_nlsk, rep, NETLINK_CB(in_skb).pid,
+	err = netlink_unicast(net->diag_nlsk, rep, NETLINK_CB(in_skb).portid,
 			      MSG_DONTWAIT);
 	if (err > 0)
 		err = 0;
diff --git a/net/wireless/core.h b/net/wireless/core.h
index bc7430b..a343be4 100644
--- a/net/wireless/core.h
+++ b/net/wireless/core.h
@@ -55,7 +55,7 @@ struct cfg80211_registered_device {
 	int opencount; /* also protected by devlist_mtx */
 	wait_queue_head_t dev_wait;
 
-	u32 ap_beacons_nlpid;
+	u32 ap_beacons_nlportid;
 
 	/* protected by RTNL only */
 	int num_running_ifaces;
diff --git a/net/wireless/mlme.c b/net/wireless/mlme.c
index 8fd0242..ec7fcee 100644
--- a/net/wireless/mlme.c
+++ b/net/wireless/mlme.c
@@ -615,7 +615,7 @@ EXPORT_SYMBOL(cfg80211_del_sta);
 struct cfg80211_mgmt_registration {
 	struct list_head list;
 
-	u32 nlpid;
+	u32 nlportid;
 
 	int match_len;
 
@@ -624,7 +624,7 @@ struct cfg80211_mgmt_registration {
 	u8 match[];
 };
 
-int cfg80211_mlme_register_mgmt(struct wireless_dev *wdev, u32 snd_pid,
+int cfg80211_mlme_register_mgmt(struct wireless_dev *wdev, u32 snd_portid,
 				u16 frame_type, const u8 *match_data,
 				int match_len)
 {
@@ -672,7 +672,7 @@ int cfg80211_mlme_register_mgmt(struct wireless_dev *wdev, u32 snd_pid,
 
 	memcpy(nreg->match, match_data, match_len);
 	nreg->match_len = match_len;
-	nreg->nlpid = snd_pid;
+	nreg->nlportid = snd_portid;
 	nreg->frame_type = cpu_to_le16(frame_type);
 	list_add(&nreg->list, &wdev->mgmt_registrations);
 
@@ -685,7 +685,7 @@ int cfg80211_mlme_register_mgmt(struct wireless_dev *wdev, u32 snd_pid,
 	return err;
 }
 
-void cfg80211_mlme_unregister_socket(struct wireless_dev *wdev, u32 nlpid)
+void cfg80211_mlme_unregister_socket(struct wireless_dev *wdev, u32 nlportid)
 {
 	struct wiphy *wiphy = wdev->wiphy;
 	struct cfg80211_registered_device *rdev = wiphy_to_dev(wiphy);
@@ -694,7 +694,7 @@ void cfg80211_mlme_unregister_socket(struct wireless_dev *wdev, u32 nlpid)
 	spin_lock_bh(&wdev->mgmt_registrations_lock);
 
 	list_for_each_entry_safe(reg, tmp, &wdev->mgmt_registrations, list) {
-		if (reg->nlpid != nlpid)
+		if (reg->nlportid != nlportid)
 			continue;
 
 		if (rdev->ops->mgmt_frame_register) {
@@ -710,8 +710,8 @@ void cfg80211_mlme_unregister_socket(struct wireless_dev *wdev, u32 nlpid)
 
 	spin_unlock_bh(&wdev->mgmt_registrations_lock);
 
-	if (nlpid == wdev->ap_unexpected_nlpid)
-		wdev->ap_unexpected_nlpid = 0;
+	if (nlportid == wdev->ap_unexpected_nlportid)
+		wdev->ap_unexpected_nlportid = 0;
 }
 
 void cfg80211_mlme_purge_registrations(struct wireless_dev *wdev)
@@ -872,7 +872,7 @@ bool cfg80211_rx_mgmt(struct wireless_dev *wdev, int freq, int sig_mbm,
 		/* found match! */
 
 		/* Indicate the received Action frame to user space */
-		if (nl80211_send_mgmt(rdev, wdev, reg->nlpid,
+		if (nl80211_send_mgmt(rdev, wdev, reg->nlportid,
 				      freq, sig_mbm,
 				      buf, len, gfp))
 			continue;
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 787aeaa..34eb5c0 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -496,11 +496,11 @@ static bool is_valid_ie_attr(const struct nlattr *attr)
 }
 
 /* message building helper */
-static inline void *nl80211hdr_put(struct sk_buff *skb, u32 pid, u32 seq,
+static inline void *nl80211hdr_put(struct sk_buff *skb, u32 portid, u32 seq,
 				   int flags, u8 cmd)
 {
 	/* since there is no private header just add the generic one */
-	return genlmsg_put(skb, pid, seq, &nl80211_fam, flags, cmd);
+	return genlmsg_put(skb, portid, seq, &nl80211_fam, flags, cmd);
 }
 
 static int nl80211_msg_put_channel(struct sk_buff *msg,
@@ -851,7 +851,7 @@ nla_put_failure:
 	return -ENOBUFS;
 }
 
-static int nl80211_send_wiphy(struct sk_buff *msg, u32 pid, u32 seq, int flags,
+static int nl80211_send_wiphy(struct sk_buff *msg, u32 portid, u32 seq, int flags,
 			      struct cfg80211_registered_device *dev)
 {
 	void *hdr;
@@ -866,7 +866,7 @@ static int nl80211_send_wiphy(struct sk_buff *msg, u32 pid, u32 seq, int flags,
 	const struct ieee80211_txrx_stypes *mgmt_stypes =
 				dev->wiphy.mgmt_stypes;
 
-	hdr = nl80211hdr_put(msg, pid, seq, flags, NL80211_CMD_NEW_WIPHY);
+	hdr = nl80211hdr_put(msg, portid, seq, flags, NL80211_CMD_NEW_WIPHY);
 	if (!hdr)
 		return -1;
 
@@ -1267,7 +1267,7 @@ static int nl80211_dump_wiphy(struct sk_buff *skb, struct netlink_callback *cb)
 			continue;
 		if (++idx <= start)
 			continue;
-		if (nl80211_send_wiphy(skb, NETLINK_CB(cb->skb).pid,
+		if (nl80211_send_wiphy(skb, NETLINK_CB(cb->skb).portid,
 				       cb->nlh->nlmsg_seq, NLM_F_MULTI,
 				       dev) < 0) {
 			idx--;
@@ -1290,7 +1290,7 @@ static int nl80211_get_wiphy(struct sk_buff *skb, struct genl_info *info)
 	if (!msg)
 		return -ENOMEM;
 
-	if (nl80211_send_wiphy(msg, info->snd_pid, info->snd_seq, 0, dev) < 0) {
+	if (nl80211_send_wiphy(msg, info->snd_portid, info->snd_seq, 0, dev) < 0) {
 		nlmsg_free(msg);
 		return -ENOBUFS;
 	}
@@ -1736,14 +1736,14 @@ static inline u64 wdev_id(struct wireless_dev *wdev)
 	       ((u64)wiphy_to_dev(wdev->wiphy)->wiphy_idx << 32);
 }
 
-static int nl80211_send_iface(struct sk_buff *msg, u32 pid, u32 seq, int flags,
+static int nl80211_send_iface(struct sk_buff *msg, u32 portid, u32 seq, int flags,
 			      struct cfg80211_registered_device *rdev,
 			      struct wireless_dev *wdev)
 {
 	struct net_device *dev = wdev->netdev;
 	void *hdr;
 
-	hdr = nl80211hdr_put(msg, pid, seq, flags, NL80211_CMD_NEW_INTERFACE);
+	hdr = nl80211hdr_put(msg, portid, seq, flags, NL80211_CMD_NEW_INTERFACE);
 	if (!hdr)
 		return -1;
 
@@ -1807,7 +1807,7 @@ static int nl80211_dump_interface(struct sk_buff *skb, struct netlink_callback *
 				if_idx++;
 				continue;
 			}
-			if (nl80211_send_iface(skb, NETLINK_CB(cb->skb).pid,
+			if (nl80211_send_iface(skb, NETLINK_CB(cb->skb).portid,
 					       cb->nlh->nlmsg_seq, NLM_F_MULTI,
 					       rdev, wdev) < 0) {
 				mutex_unlock(&rdev->devlist_mtx);
@@ -1838,7 +1838,7 @@ static int nl80211_get_interface(struct sk_buff *skb, struct genl_info *info)
 	if (!msg)
 		return -ENOMEM;
 
-	if (nl80211_send_iface(msg, info->snd_pid, info->snd_seq, 0,
+	if (nl80211_send_iface(msg, info->snd_portid, info->snd_seq, 0,
 			       dev, wdev) < 0) {
 		nlmsg_free(msg);
 		return -ENOBUFS;
@@ -2056,7 +2056,7 @@ static int nl80211_new_interface(struct sk_buff *skb, struct genl_info *info)
 		break;
 	}
 
-	if (nl80211_send_iface(msg, info->snd_pid, info->snd_seq, 0,
+	if (nl80211_send_iface(msg, info->snd_portid, info->snd_seq, 0,
 			       rdev, wdev) < 0) {
 		nlmsg_free(msg);
 		return -ENOBUFS;
@@ -2191,7 +2191,7 @@ static int nl80211_get_key(struct sk_buff *skb, struct genl_info *info)
 	if (!msg)
 		return -ENOMEM;
 
-	hdr = nl80211hdr_put(msg, info->snd_pid, info->snd_seq, 0,
+	hdr = nl80211hdr_put(msg, info->snd_portid, info->snd_seq, 0,
 			     NL80211_CMD_NEW_KEY);
 	if (IS_ERR(hdr))
 		return PTR_ERR(hdr);
@@ -2769,7 +2769,7 @@ nla_put_failure:
 	return false;
 }
 
-static int nl80211_send_station(struct sk_buff *msg, u32 pid, u32 seq,
+static int nl80211_send_station(struct sk_buff *msg, u32 portid, u32 seq,
 				int flags,
 				struct cfg80211_registered_device *rdev,
 				struct net_device *dev,
@@ -2778,7 +2778,7 @@ static int nl80211_send_station(struct sk_buff *msg, u32 pid, u32 seq,
 	void *hdr;
 	struct nlattr *sinfoattr, *bss_param;
 
-	hdr = nl80211hdr_put(msg, pid, seq, flags, NL80211_CMD_NEW_STATION);
+	hdr = nl80211hdr_put(msg, portid, seq, flags, NL80211_CMD_NEW_STATION);
 	if (!hdr)
 		return -1;
 
@@ -2931,7 +2931,7 @@ static int nl80211_dump_station(struct sk_buff *skb,
 			goto out_err;
 
 		if (nl80211_send_station(skb,
-				NETLINK_CB(cb->skb).pid,
+				NETLINK_CB(cb->skb).portid,
 				cb->nlh->nlmsg_seq, NLM_F_MULTI,
 				dev, netdev, mac_addr,
 				&sinfo) < 0)
@@ -2977,7 +2977,7 @@ static int nl80211_get_station(struct sk_buff *skb, struct genl_info *info)
 	if (!msg)
 		return -ENOMEM;
 
-	if (nl80211_send_station(msg, info->snd_pid, info->snd_seq, 0,
+	if (nl80211_send_station(msg, info->snd_portid, info->snd_seq, 0,
 				 rdev, dev, mac_addr, &sinfo) < 0) {
 		nlmsg_free(msg);
 		return -ENOBUFS;
@@ -3303,7 +3303,7 @@ static int nl80211_del_station(struct sk_buff *skb, struct genl_info *info)
 	return rdev->ops->del_station(&rdev->wiphy, dev, mac_addr);
 }
 
-static int nl80211_send_mpath(struct sk_buff *msg, u32 pid, u32 seq,
+static int nl80211_send_mpath(struct sk_buff *msg, u32 portid, u32 seq,
 				int flags, struct net_device *dev,
 				u8 *dst, u8 *next_hop,
 				struct mpath_info *pinfo)
@@ -3311,7 +3311,7 @@ static int nl80211_send_mpath(struct sk_buff *msg, u32 pid, u32 seq,
 	void *hdr;
 	struct nlattr *pinfoattr;
 
-	hdr = nl80211hdr_put(msg, pid, seq, flags, NL80211_CMD_NEW_STATION);
+	hdr = nl80211hdr_put(msg, portid, seq, flags, NL80211_CMD_NEW_STATION);
 	if (!hdr)
 		return -1;
 
@@ -3389,7 +3389,7 @@ static int nl80211_dump_mpath(struct sk_buff *skb,
 		if (err)
 			goto out_err;
 
-		if (nl80211_send_mpath(skb, NETLINK_CB(cb->skb).pid,
+		if (nl80211_send_mpath(skb, NETLINK_CB(cb->skb).portid,
 				       cb->nlh->nlmsg_seq, NLM_F_MULTI,
 				       netdev, dst, next_hop,
 				       &pinfo) < 0)
@@ -3438,7 +3438,7 @@ static int nl80211_get_mpath(struct sk_buff *skb, struct genl_info *info)
 	if (!msg)
 		return -ENOMEM;
 
-	if (nl80211_send_mpath(msg, info->snd_pid, info->snd_seq, 0,
+	if (nl80211_send_mpath(msg, info->snd_portid, info->snd_seq, 0,
 				 dev, dst, next_hop, &pinfo) < 0) {
 		nlmsg_free(msg);
 		return -ENOBUFS;
@@ -3679,7 +3679,7 @@ static int nl80211_get_mesh_config(struct sk_buff *skb,
 	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (!msg)
 		return -ENOMEM;
-	hdr = nl80211hdr_put(msg, info->snd_pid, info->snd_seq, 0,
+	hdr = nl80211hdr_put(msg, info->snd_portid, info->snd_seq, 0,
 			     NL80211_CMD_GET_MESH_CONFIG);
 	if (!hdr)
 		goto out;
@@ -3998,7 +3998,7 @@ static int nl80211_get_reg(struct sk_buff *skb, struct genl_info *info)
 		goto out;
 	}
 
-	hdr = nl80211hdr_put(msg, info->snd_pid, info->snd_seq, 0,
+	hdr = nl80211hdr_put(msg, info->snd_portid, info->snd_seq, 0,
 			     NL80211_CMD_GET_REG);
 	if (!hdr)
 		goto put_failure;
@@ -4616,7 +4616,7 @@ static int nl80211_send_bss(struct sk_buff *msg, struct netlink_callback *cb,
 
 	ASSERT_WDEV_LOCK(wdev);
 
-	hdr = nl80211hdr_put(msg, NETLINK_CB(cb->skb).pid, seq, flags,
+	hdr = nl80211hdr_put(msg, NETLINK_CB(cb->skb).portid, seq, flags,
 			     NL80211_CMD_NEW_SCAN_RESULTS);
 	if (!hdr)
 		return -1;
@@ -4735,14 +4735,14 @@ static int nl80211_dump_scan(struct sk_buff *skb,
 	return skb->len;
 }
 
-static int nl80211_send_survey(struct sk_buff *msg, u32 pid, u32 seq,
+static int nl80211_send_survey(struct sk_buff *msg, u32 portid, u32 seq,
 				int flags, struct net_device *dev,
 				struct survey_info *survey)
 {
 	void *hdr;
 	struct nlattr *infoattr;
 
-	hdr = nl80211hdr_put(msg, pid, seq, flags,
+	hdr = nl80211hdr_put(msg, portid, seq, flags,
 			     NL80211_CMD_NEW_SURVEY_RESULTS);
 	if (!hdr)
 		return -ENOMEM;
@@ -4836,7 +4836,7 @@ static int nl80211_dump_survey(struct sk_buff *skb,
 		}
 
 		if (nl80211_send_survey(skb,
-				NETLINK_CB(cb->skb).pid,
+				NETLINK_CB(cb->skb).portid,
 				cb->nlh->nlmsg_seq, NLM_F_MULTI,
 				netdev,
 				&survey) < 0)
@@ -5451,7 +5451,7 @@ static int nl80211_testmode_dump(struct sk_buff *skb,
 	}
 
 	while (1) {
-		void *hdr = nl80211hdr_put(skb, NETLINK_CB(cb->skb).pid,
+		void *hdr = nl80211hdr_put(skb, NETLINK_CB(cb->skb).portid,
 					   cb->nlh->nlmsg_seq, NLM_F_MULTI,
 					   NL80211_CMD_TESTMODE);
 		struct nlattr *tmdata;
@@ -5491,7 +5491,7 @@ static int nl80211_testmode_dump(struct sk_buff *skb,
 
 static struct sk_buff *
 __cfg80211_testmode_alloc_skb(struct cfg80211_registered_device *rdev,
-			      int approxlen, u32 pid, u32 seq, gfp_t gfp)
+			      int approxlen, u32 portid, u32 seq, gfp_t gfp)
 {
 	struct sk_buff *skb;
 	void *hdr;
@@ -5501,7 +5501,7 @@ __cfg80211_testmode_alloc_skb(struct cfg80211_registered_device *rdev,
 	if (!skb)
 		return NULL;
 
-	hdr = nl80211hdr_put(skb, pid, seq, 0, NL80211_CMD_TESTMODE);
+	hdr = nl80211hdr_put(skb, portid, seq, 0, NL80211_CMD_TESTMODE);
 	if (!hdr) {
 		kfree_skb(skb);
 		return NULL;
@@ -5531,7 +5531,7 @@ struct sk_buff *cfg80211_testmode_alloc_reply_skb(struct wiphy *wiphy,
 		return NULL;
 
 	return __cfg80211_testmode_alloc_skb(rdev, approxlen,
-				rdev->testmode_info->snd_pid,
+				rdev->testmode_info->snd_portid,
 				rdev->testmode_info->snd_seq,
 				GFP_KERNEL);
 }
@@ -5867,7 +5867,7 @@ static int nl80211_remain_on_channel(struct sk_buff *skb,
 	if (!msg)
 		return -ENOMEM;
 
-	hdr = nl80211hdr_put(msg, info->snd_pid, info->snd_seq, 0,
+	hdr = nl80211hdr_put(msg, info->snd_portid, info->snd_seq, 0,
 			     NL80211_CMD_REMAIN_ON_CHANNEL);
 
 	if (IS_ERR(hdr)) {
@@ -6086,7 +6086,7 @@ static int nl80211_register_mgmt(struct sk_buff *skb, struct genl_info *info)
 	if (!rdev->ops->mgmt_tx)
 		return -EOPNOTSUPP;
 
-	return cfg80211_mlme_register_mgmt(wdev, info->snd_pid, frame_type,
+	return cfg80211_mlme_register_mgmt(wdev, info->snd_portid, frame_type,
 			nla_data(info->attrs[NL80211_ATTR_FRAME_MATCH]),
 			nla_len(info->attrs[NL80211_ATTR_FRAME_MATCH]));
 }
@@ -6167,7 +6167,7 @@ static int nl80211_tx_mgmt(struct sk_buff *skb, struct genl_info *info)
 		if (!msg)
 			return -ENOMEM;
 
-		hdr = nl80211hdr_put(msg, info->snd_pid, info->snd_seq, 0,
+		hdr = nl80211hdr_put(msg, info->snd_portid, info->snd_seq, 0,
 				     NL80211_CMD_FRAME);
 
 		if (IS_ERR(hdr)) {
@@ -6284,7 +6284,7 @@ static int nl80211_get_power_save(struct sk_buff *skb, struct genl_info *info)
 	if (!msg)
 		return -ENOMEM;
 
-	hdr = nl80211hdr_put(msg, info->snd_pid, info->snd_seq, 0,
+	hdr = nl80211hdr_put(msg, info->snd_portid, info->snd_seq, 0,
 			     NL80211_CMD_GET_POWER_SAVE);
 	if (!hdr) {
 		err = -ENOBUFS;
@@ -6486,7 +6486,7 @@ static int nl80211_get_wowlan(struct sk_buff *skb, struct genl_info *info)
 	if (!msg)
 		return -ENOMEM;
 
-	hdr = nl80211hdr_put(msg, info->snd_pid, info->snd_seq, 0,
+	hdr = nl80211hdr_put(msg, info->snd_portid, info->snd_seq, 0,
 			     NL80211_CMD_GET_WOWLAN);
 	if (!hdr)
 		goto nla_put_failure;
@@ -6760,10 +6760,10 @@ static int nl80211_register_unexpected_frame(struct sk_buff *skb,
 	    wdev->iftype != NL80211_IFTYPE_P2P_GO)
 		return -EINVAL;
 
-	if (wdev->ap_unexpected_nlpid)
+	if (wdev->ap_unexpected_nlportid)
 		return -EBUSY;
 
-	wdev->ap_unexpected_nlpid = info->snd_pid;
+	wdev->ap_unexpected_nlportid = info->snd_portid;
 	return 0;
 }
 
@@ -6793,7 +6793,7 @@ static int nl80211_probe_client(struct sk_buff *skb,
 	if (!msg)
 		return -ENOMEM;
 
-	hdr = nl80211hdr_put(msg, info->snd_pid, info->snd_seq, 0,
+	hdr = nl80211hdr_put(msg, info->snd_portid, info->snd_seq, 0,
 			     NL80211_CMD_PROBE_CLIENT);
 
 	if (IS_ERR(hdr)) {
@@ -6828,10 +6828,10 @@ static int nl80211_register_beacons(struct sk_buff *skb, struct genl_info *info)
 	if (!(rdev->wiphy.flags & WIPHY_FLAG_REPORTS_OBSS))
 		return -EOPNOTSUPP;
 
-	if (rdev->ap_beacons_nlpid)
+	if (rdev->ap_beacons_nlportid)
 		return -EBUSY;
 
-	rdev->ap_beacons_nlpid = info->snd_pid;
+	rdev->ap_beacons_nlportid = info->snd_portid;
 
 	return 0;
 }
@@ -7628,12 +7628,12 @@ static int nl80211_add_scan_req(struct sk_buff *msg,
 static int nl80211_send_scan_msg(struct sk_buff *msg,
 				 struct cfg80211_registered_device *rdev,
 				 struct wireless_dev *wdev,
-				 u32 pid, u32 seq, int flags,
+				 u32 portid, u32 seq, int flags,
 				 u32 cmd)
 {
 	void *hdr;
 
-	hdr = nl80211hdr_put(msg, pid, seq, flags, cmd);
+	hdr = nl80211hdr_put(msg, portid, seq, flags, cmd);
 	if (!hdr)
 		return -1;
 
@@ -7657,11 +7657,11 @@ static int
 nl80211_send_sched_scan_msg(struct sk_buff *msg,
 			    struct cfg80211_registered_device *rdev,
 			    struct net_device *netdev,
-			    u32 pid, u32 seq, int flags, u32 cmd)
+			    u32 portid, u32 seq, int flags, u32 cmd)
 {
 	void *hdr;
 
-	hdr = nl80211hdr_put(msg, pid, seq, flags, cmd);
+	hdr = nl80211hdr_put(msg, portid, seq, flags, cmd);
 	if (!hdr)
 		return -1;
 
@@ -8370,9 +8370,9 @@ static bool __nl80211_unexpected_frame(struct net_device *dev, u8 cmd,
 	struct sk_buff *msg;
 	void *hdr;
 	int err;
-	u32 nlpid = ACCESS_ONCE(wdev->ap_unexpected_nlpid);
+	u32 nlportid = ACCESS_ONCE(wdev->ap_unexpected_nlportid);
 
-	if (!nlpid)
+	if (!nlportid)
 		return false;
 
 	msg = nlmsg_new(100, gfp);
@@ -8396,7 +8396,7 @@ static bool __nl80211_unexpected_frame(struct net_device *dev, u8 cmd,
 		return true;
 	}
 
-	genlmsg_unicast(wiphy_net(&rdev->wiphy), msg, nlpid);
+	genlmsg_unicast(wiphy_net(&rdev->wiphy), msg, nlportid);
 	return true;
 
  nla_put_failure:
@@ -8420,7 +8420,7 @@ bool nl80211_unexpected_4addr_frame(struct net_device *dev,
 }
 
 int nl80211_send_mgmt(struct cfg80211_registered_device *rdev,
-		      struct wireless_dev *wdev, u32 nlpid,
+		      struct wireless_dev *wdev, u32 nlportid,
 		      int freq, int sig_dbm,
 		      const u8 *buf, size_t len, gfp_t gfp)
 {
@@ -8449,7 +8449,7 @@ int nl80211_send_mgmt(struct cfg80211_registered_device *rdev,
 
 	genlmsg_end(msg, hdr);
 
-	return genlmsg_unicast(wiphy_net(&rdev->wiphy), msg, nlpid);
+	return genlmsg_unicast(wiphy_net(&rdev->wiphy), msg, nlportid);
 
  nla_put_failure:
 	genlmsg_cancel(msg, hdr);
@@ -8804,9 +8804,9 @@ void cfg80211_report_obss_beacon(struct wiphy *wiphy,
 	struct cfg80211_registered_device *rdev = wiphy_to_dev(wiphy);
 	struct sk_buff *msg;
 	void *hdr;
-	u32 nlpid = ACCESS_ONCE(rdev->ap_beacons_nlpid);
+	u32 nlportid = ACCESS_ONCE(rdev->ap_beacons_nlportid);
 
-	if (!nlpid)
+	if (!nlportid)
 		return;
 
 	msg = nlmsg_new(len + 100, gfp);
@@ -8829,7 +8829,7 @@ void cfg80211_report_obss_beacon(struct wiphy *wiphy,
 
 	genlmsg_end(msg, hdr);
 
-	genlmsg_unicast(wiphy_net(&rdev->wiphy), msg, nlpid);
+	genlmsg_unicast(wiphy_net(&rdev->wiphy), msg, nlportid);
 	return;
 
  nla_put_failure:
@@ -8853,9 +8853,9 @@ static int nl80211_netlink_notify(struct notifier_block * nb,
 
 	list_for_each_entry_rcu(rdev, &cfg80211_rdev_list, list) {
 		list_for_each_entry_rcu(wdev, &rdev->wdev_list, list)
-			cfg80211_mlme_unregister_socket(wdev, notify->pid);
-		if (rdev->ap_beacons_nlpid == notify->pid)
-			rdev->ap_beacons_nlpid = 0;
+			cfg80211_mlme_unregister_socket(wdev, notify->portid);
+		if (rdev->ap_beacons_nlportid == notify->portid)
+			rdev->ap_beacons_nlportid = 0;
 	}
 
 	rcu_read_unlock();
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 7856c33..30edad4 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -166,7 +166,7 @@ static DEFINE_SPINLOCK(xfrm_state_gc_lock);
 int __xfrm_state_delete(struct xfrm_state *x);
 
 int km_query(struct xfrm_state *x, struct xfrm_tmpl *t, struct xfrm_policy *pol);
-void km_state_expired(struct xfrm_state *x, int hard, u32 pid);
+void km_state_expired(struct xfrm_state *x, int hard, u32 portid);
 
 static struct xfrm_state_afinfo *xfrm_state_lock_afinfo(unsigned int family)
 {
@@ -1674,13 +1674,13 @@ void km_state_notify(struct xfrm_state *x, const struct km_event *c)
 EXPORT_SYMBOL(km_policy_notify);
 EXPORT_SYMBOL(km_state_notify);
 
-void km_state_expired(struct xfrm_state *x, int hard, u32 pid)
+void km_state_expired(struct xfrm_state *x, int hard, u32 portid)
 {
 	struct net *net = xs_net(x);
 	struct km_event c;
 
 	c.data.hard = hard;
-	c.pid = pid;
+	c.portid = portid;
 	c.event = XFRM_MSG_EXPIRE;
 	km_state_notify(x, &c);
 
@@ -1726,13 +1726,13 @@ int km_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr, __be16 sport)
 }
 EXPORT_SYMBOL(km_new_mapping);
 
-void km_policy_expired(struct xfrm_policy *pol, int dir, int hard, u32 pid)
+void km_policy_expired(struct xfrm_policy *pol, int dir, int hard, u32 portid)
 {
 	struct net *net = xp_net(pol);
 	struct km_event c;
 
 	c.data.hard = hard;
-	c.pid = pid;
+	c.portid = portid;
 	c.event = XFRM_MSG_POLEXPIRE;
 	km_policy_notify(pol, dir, &c);
 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index ab58034..4801c81 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -603,7 +603,7 @@ static int xfrm_add_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	}
 
 	c.seq = nlh->nlmsg_seq;
-	c.pid = nlh->nlmsg_pid;
+	c.portid = nlh->nlmsg_pid;
 	c.event = nlh->nlmsg_type;
 
 	km_state_notify(x, &c);
@@ -676,7 +676,7 @@ static int xfrm_del_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 		goto out;
 
 	c.seq = nlh->nlmsg_seq;
-	c.pid = nlh->nlmsg_pid;
+	c.portid = nlh->nlmsg_pid;
 	c.event = nlh->nlmsg_type;
 	km_state_notify(x, &c);
 
@@ -826,7 +826,7 @@ static int dump_one_state(struct xfrm_state *x, int count, void *ptr)
 	struct nlmsghdr *nlh;
 	int err;
 
-	nlh = nlmsg_put(skb, NETLINK_CB(in_skb).pid, sp->nlmsg_seq,
+	nlh = nlmsg_put(skb, NETLINK_CB(in_skb).portid, sp->nlmsg_seq,
 			XFRM_MSG_NEWSA, sizeof(*p), sp->nlmsg_flags);
 	if (nlh == NULL)
 		return -EMSGSIZE;
@@ -904,7 +904,7 @@ static inline size_t xfrm_spdinfo_msgsize(void)
 }
 
 static int build_spdinfo(struct sk_buff *skb, struct net *net,
-			 u32 pid, u32 seq, u32 flags)
+			 u32 portid, u32 seq, u32 flags)
 {
 	struct xfrmk_spdinfo si;
 	struct xfrmu_spdinfo spc;
@@ -913,7 +913,7 @@ static int build_spdinfo(struct sk_buff *skb, struct net *net,
 	int err;
 	u32 *f;
 
-	nlh = nlmsg_put(skb, pid, seq, XFRM_MSG_NEWSPDINFO, sizeof(u32), 0);
+	nlh = nlmsg_put(skb, portid, seq, XFRM_MSG_NEWSPDINFO, sizeof(u32), 0);
 	if (nlh == NULL) /* shouldn't really happen ... */
 		return -EMSGSIZE;
 
@@ -946,17 +946,17 @@ static int xfrm_get_spdinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct net *net = sock_net(skb->sk);
 	struct sk_buff *r_skb;
 	u32 *flags = nlmsg_data(nlh);
-	u32 spid = NETLINK_CB(skb).pid;
+	u32 sportid = NETLINK_CB(skb).portid;
 	u32 seq = nlh->nlmsg_seq;
 
 	r_skb = nlmsg_new(xfrm_spdinfo_msgsize(), GFP_ATOMIC);
 	if (r_skb == NULL)
 		return -ENOMEM;
 
-	if (build_spdinfo(r_skb, net, spid, seq, *flags) < 0)
+	if (build_spdinfo(r_skb, net, sportid, seq, *flags) < 0)
 		BUG();
 
-	return nlmsg_unicast(net->xfrm.nlsk, r_skb, spid);
+	return nlmsg_unicast(net->xfrm.nlsk, r_skb, sportid);
 }
 
 static inline size_t xfrm_sadinfo_msgsize(void)
@@ -967,7 +967,7 @@ static inline size_t xfrm_sadinfo_msgsize(void)
 }
 
 static int build_sadinfo(struct sk_buff *skb, struct net *net,
-			 u32 pid, u32 seq, u32 flags)
+			 u32 portid, u32 seq, u32 flags)
 {
 	struct xfrmk_sadinfo si;
 	struct xfrmu_sadhinfo sh;
@@ -975,7 +975,7 @@ static int build_sadinfo(struct sk_buff *skb, struct net *net,
 	int err;
 	u32 *f;
 
-	nlh = nlmsg_put(skb, pid, seq, XFRM_MSG_NEWSADINFO, sizeof(u32), 0);
+	nlh = nlmsg_put(skb, portid, seq, XFRM_MSG_NEWSADINFO, sizeof(u32), 0);
 	if (nlh == NULL) /* shouldn't really happen ... */
 		return -EMSGSIZE;
 
@@ -1003,17 +1003,17 @@ static int xfrm_get_sadinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct net *net = sock_net(skb->sk);
 	struct sk_buff *r_skb;
 	u32 *flags = nlmsg_data(nlh);
-	u32 spid = NETLINK_CB(skb).pid;
+	u32 sportid = NETLINK_CB(skb).portid;
 	u32 seq = nlh->nlmsg_seq;
 
 	r_skb = nlmsg_new(xfrm_sadinfo_msgsize(), GFP_ATOMIC);
 	if (r_skb == NULL)
 		return -ENOMEM;
 
-	if (build_sadinfo(r_skb, net, spid, seq, *flags) < 0)
+	if (build_sadinfo(r_skb, net, sportid, seq, *flags) < 0)
 		BUG();
 
-	return nlmsg_unicast(net->xfrm.nlsk, r_skb, spid);
+	return nlmsg_unicast(net->xfrm.nlsk, r_skb, sportid);
 }
 
 static int xfrm_get_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
@@ -1033,7 +1033,7 @@ static int xfrm_get_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (IS_ERR(resp_skb)) {
 		err = PTR_ERR(resp_skb);
 	} else {
-		err = nlmsg_unicast(net->xfrm.nlsk, resp_skb, NETLINK_CB(skb).pid);
+		err = nlmsg_unicast(net->xfrm.nlsk, resp_skb, NETLINK_CB(skb).portid);
 	}
 	xfrm_state_put(x);
 out_noput:
@@ -1114,7 +1114,7 @@ static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh,
 		goto out;
 	}
 
-	err = nlmsg_unicast(net->xfrm.nlsk, resp_skb, NETLINK_CB(skb).pid);
+	err = nlmsg_unicast(net->xfrm.nlsk, resp_skb, NETLINK_CB(skb).portid);
 
 out:
 	xfrm_state_put(x);
@@ -1401,7 +1401,7 @@ static int xfrm_add_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	c.event = nlh->nlmsg_type;
 	c.seq = nlh->nlmsg_seq;
-	c.pid = nlh->nlmsg_pid;
+	c.portid = nlh->nlmsg_pid;
 	km_policy_notify(xp, p->dir, &c);
 
 	xfrm_pol_put(xp);
@@ -1486,7 +1486,7 @@ static int dump_one_policy(struct xfrm_policy *xp, int dir, int count, void *ptr
 	struct nlmsghdr *nlh;
 	int err;
 
-	nlh = nlmsg_put(skb, NETLINK_CB(in_skb).pid, sp->nlmsg_seq,
+	nlh = nlmsg_put(skb, NETLINK_CB(in_skb).portid, sp->nlmsg_seq,
 			XFRM_MSG_NEWPOLICY, sizeof(*p), sp->nlmsg_flags);
 	if (nlh == NULL)
 		return -EMSGSIZE;
@@ -1621,7 +1621,7 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 			err = PTR_ERR(resp_skb);
 		} else {
 			err = nlmsg_unicast(net->xfrm.nlsk, resp_skb,
-					    NETLINK_CB(skb).pid);
+					    NETLINK_CB(skb).portid);
 		}
 	} else {
 		uid_t loginuid = audit_get_loginuid(current);
@@ -1638,7 +1638,7 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 		c.data.byid = p->index;
 		c.event = nlh->nlmsg_type;
 		c.seq = nlh->nlmsg_seq;
-		c.pid = nlh->nlmsg_pid;
+		c.portid = nlh->nlmsg_pid;
 		km_policy_notify(xp, p->dir, &c);
 	}
 
@@ -1668,7 +1668,7 @@ static int xfrm_flush_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	c.data.proto = p->proto;
 	c.event = nlh->nlmsg_type;
 	c.seq = nlh->nlmsg_seq;
-	c.pid = nlh->nlmsg_pid;
+	c.portid = nlh->nlmsg_pid;
 	c.net = net;
 	km_state_notify(NULL, &c);
 
@@ -1695,7 +1695,7 @@ static int build_aevent(struct sk_buff *skb, struct xfrm_state *x, const struct
 	struct nlmsghdr *nlh;
 	int err;
 
-	nlh = nlmsg_put(skb, c->pid, c->seq, XFRM_MSG_NEWAE, sizeof(*id), 0);
+	nlh = nlmsg_put(skb, c->portid, c->seq, XFRM_MSG_NEWAE, sizeof(*id), 0);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
@@ -1777,11 +1777,11 @@ static int xfrm_get_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 	spin_lock_bh(&x->lock);
 	c.data.aevent = p->flags;
 	c.seq = nlh->nlmsg_seq;
-	c.pid = nlh->nlmsg_pid;
+	c.portid = nlh->nlmsg_pid;
 
 	if (build_aevent(r_skb, x, &c) < 0)
 		BUG();
-	err = nlmsg_unicast(net->xfrm.nlsk, r_skb, NETLINK_CB(skb).pid);
+	err = nlmsg_unicast(net->xfrm.nlsk, r_skb, NETLINK_CB(skb).portid);
 	spin_unlock_bh(&x->lock);
 	xfrm_state_put(x);
 	return err;
@@ -1827,7 +1827,7 @@ static int xfrm_new_ae(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	c.event = nlh->nlmsg_type;
 	c.seq = nlh->nlmsg_seq;
-	c.pid = nlh->nlmsg_pid;
+	c.portid = nlh->nlmsg_pid;
 	c.data.aevent = XFRM_AE_CU;
 	km_state_notify(x, &c);
 	err = 0;
@@ -1862,7 +1862,7 @@ static int xfrm_flush_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 	c.data.type = type;
 	c.event = nlh->nlmsg_type;
 	c.seq = nlh->nlmsg_seq;
-	c.pid = nlh->nlmsg_pid;
+	c.portid = nlh->nlmsg_pid;
 	c.net = net;
 	km_policy_notify(NULL, 0, &c);
 	return 0;
@@ -2370,7 +2370,7 @@ static int build_expire(struct sk_buff *skb, struct xfrm_state *x, const struct
 	struct nlmsghdr *nlh;
 	int err;
 
-	nlh = nlmsg_put(skb, c->pid, 0, XFRM_MSG_EXPIRE, sizeof(*ue), 0);
+	nlh = nlmsg_put(skb, c->portid, 0, XFRM_MSG_EXPIRE, sizeof(*ue), 0);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
@@ -2429,7 +2429,7 @@ static int xfrm_notify_sa_flush(const struct km_event *c)
 	if (skb == NULL)
 		return -ENOMEM;
 
-	nlh = nlmsg_put(skb, c->pid, c->seq, XFRM_MSG_FLUSHSA, sizeof(*p), 0);
+	nlh = nlmsg_put(skb, c->portid, c->seq, XFRM_MSG_FLUSHSA, sizeof(*p), 0);
 	if (nlh == NULL) {
 		kfree_skb(skb);
 		return -EMSGSIZE;
@@ -2497,7 +2497,7 @@ static int xfrm_notify_sa(struct xfrm_state *x, const struct km_event *c)
 	if (skb == NULL)
 		return -ENOMEM;
 
-	nlh = nlmsg_put(skb, c->pid, c->seq, c->event, headlen, 0);
+	nlh = nlmsg_put(skb, c->portid, c->seq, c->event, headlen, 0);
 	err = -EMSGSIZE;
 	if (nlh == NULL)
 		goto out_free_skb;
@@ -2696,7 +2696,7 @@ static int build_polexpire(struct sk_buff *skb, struct xfrm_policy *xp,
 	struct nlmsghdr *nlh;
 	int err;
 
-	nlh = nlmsg_put(skb, c->pid, 0, XFRM_MSG_POLEXPIRE, sizeof(*upe), 0);
+	nlh = nlmsg_put(skb, c->portid, 0, XFRM_MSG_POLEXPIRE, sizeof(*upe), 0);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
@@ -2756,7 +2756,7 @@ static int xfrm_notify_policy(struct xfrm_policy *xp, int dir, const struct km_e
 	if (skb == NULL)
 		return -ENOMEM;
 
-	nlh = nlmsg_put(skb, c->pid, c->seq, c->event, headlen, 0);
+	nlh = nlmsg_put(skb, c->portid, c->seq, c->event, headlen, 0);
 	err = -EMSGSIZE;
 	if (nlh == NULL)
 		goto out_free_skb;
@@ -2810,7 +2810,7 @@ static int xfrm_notify_policy_flush(const struct km_event *c)
 	if (skb == NULL)
 		return -ENOMEM;
 
-	nlh = nlmsg_put(skb, c->pid, c->seq, XFRM_MSG_FLUSHPOLICY, 0, 0);
+	nlh = nlmsg_put(skb, c->portid, c->seq, XFRM_MSG_FLUSHPOLICY, 0, 0);
 	err = -EMSGSIZE;
 	if (nlh == NULL)
 		goto out_free_skb;
-- 
1.7.5.4
