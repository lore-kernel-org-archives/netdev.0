From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] net: Use NLMSG_DEFAULT_SIZE in combination with
 nlmsg_new()
Date: Thu, 28 Jun 2012 16:04:17 +0200
Message-ID: <20120628140417.GD1520@minipsycho.orion>
References: <caecbaa2f181c17908fbd61264e1acb9c5cb1fe1.1340891841.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Sergey Lapin <slapin@ossfans.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14254 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750866Ab2F1OEl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jun 2012 10:04:41 -0400
Content-Disposition: inline
In-Reply-To: <caecbaa2f181c17908fbd61264e1acb9c5cb1fe1.1340891841.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was thinking about similar patch a week ago.

Reviewed-by: Jiri Pirko <jpirko@redhat.com>

Thu, Jun 28, 2012 at 03:57:45PM CEST, tgraf@suug.ch wrote:
>Using NLMSG_GOODSIZE results in multiple pages being used as
>nlmsg_new() will automatically add the size of the netlink
>header to the payload thus exceeding the page limit.
>
>NLMSG_DEFAULT_SIZE takes this into account.
>
>Signed-off-by: Thomas Graf <tgraf@suug.ch>
>Cc: Jiri Pirko <jpirko@redhat.com>
>Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
>Cc: Sergey Lapin <slapin@ossfans.org>
>Cc: Johannes Berg <johannes@sipsolutions.net>
>Cc: Lauro Ramos Venancio <lauro.venancio@openbossa.org>
>Cc: Aloisio Almeida Jr <aloisio.almeida@openbossa.org>
>Cc: Samuel Ortiz <sameo@linux.intel.com>
>---
> drivers/net/team/team.c               |    8 ++++----
> drivers/net/wireless/mac80211_hwsim.c |    2 +-
> include/net/genetlink.h               |    2 ++
> net/ieee802154/netlink.c              |    4 ++--
> net/ieee802154/nl-mac.c               |    2 +-
> net/ieee802154/nl-phy.c               |    2 +-
> net/l2tp/l2tp_netlink.c               |    6 +++---
> net/nfc/netlink.c                     |   18 +++++++++---------
> net/wireless/nl80211.c                |   26 +++++++++++++-------------
> 9 files changed, 36 insertions(+), 34 deletions(-)
>
>diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>index 5350eea..89853c3 100644
>--- a/drivers/net/team/team.c
>+++ b/drivers/net/team/team.c
>@@ -1476,7 +1476,7 @@ static int team_nl_cmd_noop(struct sk_buff *skb, struct genl_info *info)
> 	void *hdr;
> 	int err;
> 
>-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> 	if (!msg)
> 		return -ENOMEM;
> 
>@@ -1538,7 +1538,7 @@ static int team_nl_send_generic(struct genl_info *info, struct team *team,
> 	struct sk_buff *skb;
> 	int err;
> 
>-	skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
>+	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> 	if (!skb)
> 		return -ENOMEM;
> 
>@@ -1648,7 +1648,7 @@ static int __send_and_alloc_skb(struct sk_buff **pskb,
> 		if (err)
> 			return err;
> 	}
>-	*pskb = genlmsg_new(NLMSG_DEFAULT_SIZE - GENL_HDRLEN, GFP_KERNEL);
>+	*pskb = genlmsg_new(GENLMSG_DEFAULT_SIZE, GFP_KERNEL);
> 	if (!*pskb)
> 		return -ENOMEM;
> 	return 0;
>@@ -2016,7 +2016,7 @@ static int team_nl_send_event_port_list_get(struct team *team)
> 	int err;
> 	struct net *net = dev_net(team->dev);
> 
>-	skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
>+	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> 	if (!skb)
> 		return -ENOMEM;
> 
>diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
>index a0b7cfd..a9ba3f7 100644
>--- a/drivers/net/wireless/mac80211_hwsim.c
>+++ b/drivers/net/wireless/mac80211_hwsim.c
>@@ -571,7 +571,7 @@ static void mac80211_hwsim_tx_frame_nl(struct ieee80211_hw *hw,
> 			skb_dequeue(&data->pending);
> 	}
> 
>-	skb = genlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
>+	skb = genlmsg_new(GENLMSG_DEFAULT_SIZE, GFP_ATOMIC);
> 	if (skb == NULL)
> 		goto nla_put_failure;
> 
>diff --git a/include/net/genetlink.h b/include/net/genetlink.h
>index ccb6888..48905cd 100644
>--- a/include/net/genetlink.h
>+++ b/include/net/genetlink.h
>@@ -5,6 +5,8 @@
> #include <net/netlink.h>
> #include <net/net_namespace.h>
> 
>+#define GENLMSG_DEFAULT_SIZE (NLMSG_DEFAULT_SIZE - GENL_HDRLEN)
>+
> /**
>  * struct genl_multicast_group - generic netlink multicast group
>  * @name: name of the multicast group, names are per-family
>diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
>index c8097ae..97351e1 100644
>--- a/net/ieee802154/netlink.c
>+++ b/net/ieee802154/netlink.c
>@@ -44,7 +44,7 @@ struct genl_family nl802154_family = {
> struct sk_buff *ieee802154_nl_create(int flags, u8 req)
> {
> 	void *hdr;
>-	struct sk_buff *msg = nlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
>+	struct sk_buff *msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
> 	unsigned long f;
> 
> 	if (!msg)
>@@ -80,7 +80,7 @@ struct sk_buff *ieee802154_nl_new_reply(struct genl_info *info,
> 		int flags, u8 req)
> {
> 	void *hdr;
>-	struct sk_buff *msg = nlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
>+	struct sk_buff *msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
> 
> 	if (!msg)
> 		return NULL;
>diff --git a/net/ieee802154/nl-mac.c b/net/ieee802154/nl-mac.c
>index ca92587..1e99171 100644
>--- a/net/ieee802154/nl-mac.c
>+++ b/net/ieee802154/nl-mac.c
>@@ -530,7 +530,7 @@ static int ieee802154_list_iface(struct sk_buff *skb,
> 	if (!dev)
> 		return -ENODEV;
> 
>-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> 	if (!msg)
> 		goto out_dev;
> 
>diff --git a/net/ieee802154/nl-phy.c b/net/ieee802154/nl-phy.c
>index eed2916..d54be34 100644
>--- a/net/ieee802154/nl-phy.c
>+++ b/net/ieee802154/nl-phy.c
>@@ -101,7 +101,7 @@ static int ieee802154_list_phy(struct sk_buff *skb,
> 	if (!phy)
> 		return -ENODEV;
> 
>-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> 	if (!msg)
> 		goto out_dev;
> 
>diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
>index ddc553e..d71cd92 100644
>--- a/net/l2tp/l2tp_netlink.c
>+++ b/net/l2tp/l2tp_netlink.c
>@@ -72,7 +72,7 @@ static int l2tp_nl_cmd_noop(struct sk_buff *skb, struct genl_info *info)
> 	void *hdr;
> 	int ret = -ENOBUFS;
> 
>-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> 	if (!msg) {
> 		ret = -ENOMEM;
> 		goto out;
>@@ -353,7 +353,7 @@ static int l2tp_nl_cmd_tunnel_get(struct sk_buff *skb, struct genl_info *info)
> 		goto out;
> 	}
> 
>-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> 	if (!msg) {
> 		ret = -ENOMEM;
> 		goto out;
>@@ -699,7 +699,7 @@ static int l2tp_nl_cmd_session_get(struct sk_buff *skb, struct genl_info *info)
> 		goto out;
> 	}
> 
>-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> 	if (!msg) {
> 		ret = -ENOMEM;
> 		goto out;
>diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
>index 03c31db..f4f07f9 100644
>--- a/net/nfc/netlink.c
>+++ b/net/nfc/netlink.c
>@@ -167,7 +167,7 @@ int nfc_genl_targets_found(struct nfc_dev *dev)
> 
> 	dev->genl_data.poll_req_pid = 0;
> 
>-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
> 	if (!msg)
> 		return -ENOMEM;
> 
>@@ -195,7 +195,7 @@ int nfc_genl_target_lost(struct nfc_dev *dev, u32 target_idx)
> 	struct sk_buff *msg;
> 	void *hdr;
> 
>-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> 	if (!msg)
> 		return -ENOMEM;
> 
>@@ -226,7 +226,7 @@ int nfc_genl_tm_activated(struct nfc_dev *dev, u32 protocol)
> 	struct sk_buff *msg;
> 	void *hdr;
> 
>-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> 	if (!msg)
> 		return -ENOMEM;
> 
>@@ -258,7 +258,7 @@ int nfc_genl_tm_deactivated(struct nfc_dev *dev)
> 	struct sk_buff *msg;
> 	void *hdr;
> 
>-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> 	if (!msg)
> 		return -ENOMEM;
> 
>@@ -288,7 +288,7 @@ int nfc_genl_device_added(struct nfc_dev *dev)
> 	struct sk_buff *msg;
> 	void *hdr;
> 
>-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> 	if (!msg)
> 		return -ENOMEM;
> 
>@@ -321,7 +321,7 @@ int nfc_genl_device_removed(struct nfc_dev *dev)
> 	struct sk_buff *msg;
> 	void *hdr;
> 
>-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> 	if (!msg)
> 		return -ENOMEM;
> 
>@@ -434,7 +434,7 @@ int nfc_genl_dep_link_up_event(struct nfc_dev *dev, u32 target_idx,
> 
> 	pr_debug("DEP link is up\n");
> 
>-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
> 	if (!msg)
> 		return -ENOMEM;
> 
>@@ -473,7 +473,7 @@ int nfc_genl_dep_link_down_event(struct nfc_dev *dev)
> 
> 	pr_debug("DEP link is down\n");
> 
>-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
> 	if (!msg)
> 		return -ENOMEM;
> 
>@@ -514,7 +514,7 @@ static int nfc_genl_get_device(struct sk_buff *skb, struct genl_info *info)
> 	if (!dev)
> 		return -ENODEV;
> 
>-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> 	if (!msg) {
> 		rc = -ENOMEM;
> 		goto out_putdev;
>diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
>index 7ae54b8..cbdc0fd 100644
>--- a/net/wireless/nl80211.c
>+++ b/net/wireless/nl80211.c
>@@ -7210,7 +7210,7 @@ void nl80211_send_scan_start(struct cfg80211_registered_device *rdev,
> {
> 	struct sk_buff *msg;
> 
>-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> 	if (!msg)
> 		return;
> 
>@@ -7286,7 +7286,7 @@ void nl80211_send_sched_scan(struct cfg80211_registered_device *rdev,
> {
> 	struct sk_buff *msg;
> 
>-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> 	if (!msg)
> 		return;
> 
>@@ -7502,7 +7502,7 @@ void nl80211_send_connect_result(struct cfg80211_registered_device *rdev,
> 	struct sk_buff *msg;
> 	void *hdr;
> 
>-	msg = nlmsg_new(NLMSG_GOODSIZE, gfp);
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, gfp);
> 	if (!msg)
> 		return;
> 
>@@ -7542,7 +7542,7 @@ void nl80211_send_roamed(struct cfg80211_registered_device *rdev,
> 	struct sk_buff *msg;
> 	void *hdr;
> 
>-	msg = nlmsg_new(NLMSG_GOODSIZE, gfp);
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, gfp);
> 	if (!msg)
> 		return;
> 
>@@ -7580,7 +7580,7 @@ void nl80211_send_disconnected(struct cfg80211_registered_device *rdev,
> 	struct sk_buff *msg;
> 	void *hdr;
> 
>-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> 	if (!msg)
> 		return;
> 
>@@ -7842,7 +7842,7 @@ void nl80211_send_sta_event(struct cfg80211_registered_device *rdev,
> {
> 	struct sk_buff *msg;
> 
>-	msg = nlmsg_new(NLMSG_GOODSIZE, gfp);
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, gfp);
> 	if (!msg)
> 		return;
> 
>@@ -7863,7 +7863,7 @@ void nl80211_send_sta_del_event(struct cfg80211_registered_device *rdev,
> 	struct sk_buff *msg;
> 	void *hdr;
> 
>-	msg = nlmsg_new(NLMSG_GOODSIZE, gfp);
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, gfp);
> 	if (!msg)
> 		return;
> 
>@@ -8026,7 +8026,7 @@ nl80211_send_cqm_rssi_notify(struct cfg80211_registered_device *rdev,
> 	struct nlattr *pinfoattr;
> 	void *hdr;
> 
>-	msg = nlmsg_new(NLMSG_GOODSIZE, gfp);
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, gfp);
> 	if (!msg)
> 		return;
> 
>@@ -8069,7 +8069,7 @@ void nl80211_gtk_rekey_notify(struct cfg80211_registered_device *rdev,
> 	struct nlattr *rekey_attr;
> 	void *hdr;
> 
>-	msg = nlmsg_new(NLMSG_GOODSIZE, gfp);
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, gfp);
> 	if (!msg)
> 		return;
> 
>@@ -8113,7 +8113,7 @@ void nl80211_pmksa_candidate_notify(struct cfg80211_registered_device *rdev,
> 	struct nlattr *attr;
> 	void *hdr;
> 
>-	msg = nlmsg_new(NLMSG_GOODSIZE, gfp);
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, gfp);
> 	if (!msg)
> 		return;
> 
>@@ -8157,7 +8157,7 @@ void nl80211_ch_switch_notify(struct cfg80211_registered_device *rdev,
> 	struct sk_buff *msg;
> 	void *hdr;
> 
>-	msg = nlmsg_new(NLMSG_GOODSIZE, gfp);
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, gfp);
> 	if (!msg)
> 		return;
> 
>@@ -8192,7 +8192,7 @@ nl80211_send_cqm_pktloss_notify(struct cfg80211_registered_device *rdev,
> 	struct nlattr *pinfoattr;
> 	void *hdr;
> 
>-	msg = nlmsg_new(NLMSG_GOODSIZE, gfp);
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, gfp);
> 	if (!msg)
> 		return;
> 
>@@ -8236,7 +8236,7 @@ void cfg80211_probe_status(struct net_device *dev, const u8 *addr,
> 	void *hdr;
> 	int err;
> 
>-	msg = nlmsg_new(NLMSG_GOODSIZE, gfp);
>+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, gfp);
> 	if (!msg)
> 		return;
> 
>-- 
>1.7.7.6
>
