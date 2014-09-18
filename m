From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC repost 5/8] datapath: Move last_action() helper to datapath.h
Date: Thu, 18 Sep 2014 10:55:08 +0900
Message-ID: <1411005311-11752-6-git-send-email-simon.horman@netronome.com>
References: <1411005311-11752-1-git-send-email-simon.horman@netronome.com>
Cc: Pravin Shelar <pshelar@nicira.com>, Jesse Gross <jesse@nicira.com>,
	Thomas Graf <tgraf@suug.ch>,
	Simon Horman <simon.horman@netronome.com>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:35839 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757052AbaIRB5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 21:57:51 -0400
Received: by mail-pd0-f180.google.com with SMTP id ft15so316843pdb.25
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 18:57:50 -0700 (PDT)
In-Reply-To: <1411005311-11752-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is in preparation for using last_action() from
more than one C file as part of supporting an odp select group action.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 datapath/actions.c  | 6 ------
 datapath/datapath.h | 5 +++++
 2 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/datapath/actions.c b/datapath/actions.c
index 51ca40b..9d27234 100644
--- a/datapath/actions.c
+++ b/datapath/actions.c
@@ -752,11 +752,6 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 	return ovs_dp_upcall(dp, skb, &upcall);
 }
 
-static bool last_action(const struct nlattr *a, int rem)
-{
-	return a->nla_len == rem;
-}
-
 static int sample(struct datapath *dp, struct sk_buff *skb,
 		  const struct nlattr *attr)
 {
@@ -841,7 +836,6 @@ static int select_group(struct datapath *dp, struct sk_buff *skb,
 	const struct nlattr *best_bucket = NULL;
 	const struct nlattr *acts_list;
 	const struct nlattr *bucket;
-	struct sk_buff *sample_skb;
 	u32 best_score = 0;
 	u32 basis;
 	u32 i = 0;
diff --git a/datapath/datapath.h b/datapath/datapath.h
index c5d3c86..74a15e6 100644
--- a/datapath/datapath.h
+++ b/datapath/datapath.h
@@ -209,4 +209,9 @@ do {								\
 	if (net_ratelimit())					\
 		pr_info("netlink: " fmt, ##__VA_ARGS__);	\
 } while (0)
+
+static inline bool last_action(const struct nlattr *a, int rem)
+{
+	return a->nla_len == rem;
+}
 #endif /* datapath.h */
-- 
2.0.1
