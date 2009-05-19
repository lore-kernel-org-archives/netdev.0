From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH] net: use NLMSG_DEFAULT_SIZE in nlmsg_new() allocations
Date: Tue, 19 May 2009 17:58:20 +0200
Message-ID: <20090519155820.27716.47419.stgit@Decadence>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, samuel@sortiz.org, johannes@sipsolutions.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47625 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753726AbZESQjm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2009 12:39:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nlmsg_new() adds the size of the netlink header to the value
that has been passed as parameter. If NLMSG_GOODSIZE is selected,
we request an allocation of one memory page plus the size of the
header. Instead, NLMSG_DEFAULT_SIZE should be used since it
already substracts the size of the Netlink header.

I have the impression that the similar naming in both constant
is error prone when using it with nlmsg_new(). This is already
documented in include/net/netlink.h

Cc: Johannes Berg <johannes@sipsolutions.net>
Cc: Samuel Ortiz <samuel@sortiz.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---

 net/irda/irnetlink.c   |    2 +-
 net/wireless/nl80211.c |   32 ++++++++++++++++----------------
 2 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/net/irda/irnetlink.c b/net/irda/irnetlink.c
index 2f05ec1..82c6118 100644
--- a/net/irda/irnetlink.c
+++ b/net/irda/irnetlink.c
@@ -87,7 +87,7 @@ static int irda_nl_get_mode(struct sk_buff *skb, struct genl_info *info)
 	if (!dev)
 		return -ENODEV;
 
-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (!msg) {
 		dev_put(dev);
 		return -ENOMEM;
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index f0fec2f..ade40d5 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -388,7 +388,7 @@ static int nl80211_get_wiphy(struct sk_buff *skb, struct genl_info *info)
 	if (IS_ERR(dev))
 		return PTR_ERR(dev);
 
-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (!msg)
 		goto out_err;
 
@@ -716,7 +716,7 @@ static int nl80211_get_interface(struct sk_buff *skb, struct genl_info *info)
 	if (err)
 		return err;
 
-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (!msg)
 		goto out_err;
 
@@ -989,7 +989,7 @@ static int nl80211_get_key(struct sk_buff *skb, struct genl_info *info)
 		goto out;
 	}
 
-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (!msg) {
 		err = -ENOMEM;
 		goto out;
@@ -1600,7 +1600,7 @@ static int nl80211_get_station(struct sk_buff *skb, struct genl_info *info)
 	if (err)
 		goto out;
 
-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (!msg)
 		goto out;
 
@@ -1994,7 +1994,7 @@ static int nl80211_get_mpath(struct sk_buff *skb, struct genl_info *info)
 	if (err)
 		goto out;
 
-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (!msg)
 		goto out;
 
@@ -2310,7 +2310,7 @@ static int nl80211_get_mesh_params(struct sk_buff *skb,
 		goto out;
 
 	/* Draw up a netlink message to send back */
-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (!msg) {
 		err = -ENOBUFS;
 		goto out;
@@ -2488,7 +2488,7 @@ static int nl80211_get_reg(struct sk_buff *skb, struct genl_info *info)
 	if (!cfg80211_regdomain)
 		goto out;
 
-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (!msg) {
 		err = -ENOBUFS;
 		goto out;
@@ -3541,7 +3541,7 @@ void nl80211_notify_dev_rename(struct cfg80211_registered_device *rdev)
 {
 	struct sk_buff *msg;
 
-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (!msg)
 		return;
 
@@ -3582,7 +3582,7 @@ void nl80211_send_scan_done(struct cfg80211_registered_device *rdev,
 {
 	struct sk_buff *msg;
 
-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (!msg)
 		return;
 
@@ -3600,7 +3600,7 @@ void nl80211_send_scan_aborted(struct cfg80211_registered_device *rdev,
 {
 	struct sk_buff *msg;
 
-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (!msg)
 		return;
 
@@ -3622,7 +3622,7 @@ void nl80211_send_reg_change_event(struct regulatory_request *request)
 	struct sk_buff *msg;
 	void *hdr;
 
-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (!msg)
 		return;
 
@@ -3676,7 +3676,7 @@ static void nl80211_send_mlme_event(struct cfg80211_registered_device *rdev,
 	struct sk_buff *msg;
 	void *hdr;
 
-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
 	if (!msg)
 		return;
 
@@ -3739,7 +3739,7 @@ static void nl80211_send_mlme_timeout(struct cfg80211_registered_device *rdev,
 	struct sk_buff *msg;
 	void *hdr;
 
-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
 	if (!msg)
 		return;
 
@@ -3787,7 +3787,7 @@ void nl80211_send_ibss_bssid(struct cfg80211_registered_device *rdev,
 	struct sk_buff *msg;
 	void *hdr;
 
-	msg = nlmsg_new(NLMSG_GOODSIZE, gfp);
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, gfp);
 	if (!msg)
 		return;
 
@@ -3822,7 +3822,7 @@ void nl80211_michael_mic_failure(struct cfg80211_registered_device *rdev,
 	struct sk_buff *msg;
 	void *hdr;
 
-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (!msg)
 		return;
 
@@ -3862,7 +3862,7 @@ void nl80211_send_beacon_hint_event(struct wiphy *wiphy,
 	void *hdr;
 	struct nlattr *nl_freq;
 
-	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
 	if (!msg)
 		return;
 

