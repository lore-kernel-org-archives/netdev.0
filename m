From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] ovs: fix dp check in ovs_dp_reset_user_features
Date: Fri, 14 Feb 2014 11:42:36 +0100
Message-ID: <1392374556-8375-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jesse@nicira.com, dev@openvswitch.org,
	tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:62254 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374AbaBNKmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 05:42:40 -0500
Received: by mail-ee0-f52.google.com with SMTP id e53so5602204eek.39
        for <netdev@vger.kernel.org>; Fri, 14 Feb 2014 02:42:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes crash when userspace does "ovs-dpctl add-dp dev" where dev is
existing non-dp netdevice.

Introduced by:
commit 44da5ae5fbea4686f667dc854e5ea16814e44c59
"openvswitch: Drop user features if old user space attempted to create datapath"

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/openvswitch/datapath.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index e9a48ba..e42340d 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1174,7 +1174,7 @@ static void ovs_dp_reset_user_features(struct sk_buff *skb, struct genl_info *in
 	struct datapath *dp;
 
 	dp = lookup_datapath(sock_net(skb->sk), info->userhdr, info->attrs);
-	if (!dp)
+	if (IS_ERR(dp))
 		return;
 
 	WARN(dp->user_features, "Dropping previously announced user features\n");
-- 
1.8.5.3
