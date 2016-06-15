From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 1/2] tc: m_action: Use C99 style initializers for struct req
Date: Thu, 16 Jun 2016 00:50:38 +0200
Message-ID: <1466031039-18411-2-git-send-email-phil@nwl.cc>
References: <1466031039-18411-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:49487 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932235AbcFOWvF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2016 18:51:05 -0400
In-Reply-To: <1466031039-18411-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of initializing fields after (or sometimes even before) zeroing
the whole struct via memset(), initialize the whole thing at declaration
time.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/m_action.c | 46 +++++++++++++++++++++++-----------------------
 1 file changed, 23 insertions(+), 23 deletions(-)

diff --git a/tc/m_action.c b/tc/m_action.c
index c416d98a775a6..f97ed2e775012 100644
--- a/tc/m_action.c
+++ b/tc/m_action.c
@@ -395,18 +395,19 @@ static int tc_action_gd(int cmd, unsigned int flags, int *argc_p, char ***argv_p
 		struct nlmsghdr         n;
 		struct tcamsg           t;
 		char                    buf[MAX_MSG];
-	} req;
-
-	req.t.tca_family = AF_UNSPEC;
-
-	memset(&req, 0, sizeof(req));
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(struct tcamsg)),
+			.nlmsg_flags = NLM_F_REQUEST | flags,
+			.nlmsg_type = cmd,
+		},
+		.t.tca_family = AF_UNSPEC,
+		.buf = { 0 }
+	};
 
 	memset(&nladdr, 0, sizeof(nladdr));
 	nladdr.nl_family = AF_NETLINK;
 
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct tcamsg));
-	req.n.nlmsg_flags = NLM_F_REQUEST|flags;
-	req.n.nlmsg_type = cmd;
 	argc -= 1;
 	argv += 1;
 
@@ -500,15 +501,16 @@ static int tc_action_modify(int cmd, unsigned int flags, int *argc_p, char ***ar
 		struct nlmsghdr         n;
 		struct tcamsg           t;
 		char                    buf[MAX_MSG];
-	} req;
-
-	req.t.tca_family = AF_UNSPEC;
-
-	memset(&req, 0, sizeof(req));
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(struct tcamsg)),
+			.nlmsg_flags = NLM_F_REQUEST | flags,
+			.nlmsg_type = cmd,
+		},
+		.t.tca_family = AF_UNSPEC,
+		.buf = { 0 }
+	};
 
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct tcamsg));
-	req.n.nlmsg_flags = NLM_F_REQUEST|flags;
-	req.n.nlmsg_type = cmd;
 	tail = NLMSG_TAIL(&req.n);
 	argc -= 1;
 	argv += 1;
@@ -539,13 +541,11 @@ static int tc_act_list_or_flush(int argc, char **argv, int event)
 		struct nlmsghdr         n;
 		struct tcamsg           t;
 		char                    buf[MAX_MSG];
-	} req;
-
-	req.t.tca_family = AF_UNSPEC;
-
-	memset(&req, 0, sizeof(req));
-
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct tcamsg));
+	} req = {
+		.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct tcamsg)),
+		.t.tca_family = AF_UNSPEC,
+		.buf = { 0 }
+	};
 
 	tail = NLMSG_TAIL(&req.n);
 	addattr_l(&req.n, MAX_MSG, TCA_ACT_TAB, NULL, 0);
-- 
2.8.2
