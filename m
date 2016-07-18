From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v5 1/5] tc: m_action: Improve conversion to C99 style initializers
Date: Mon, 18 Jul 2016 16:48:41 +0200
Message-ID: <1468853325-9260-2-git-send-email-phil@nwl.cc>
References: <1468853325-9260-1-git-send-email-phil@nwl.cc>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>,
	David Laight <David.Laight@ACULAB.COM>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:47603 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751720AbcGROtK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2016 10:49:10 -0400
In-Reply-To: <1468853325-9260-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This improves my initial change in the following points:

- Flatten embedded struct's initializers.
- No need to initialize variables to zero as the key feature of C99
  initializers is to do this implicitly.
- By relocating the declaration of struct rtattr *tail, it can be
  initialized at the same time.

Fixes: a0a73b298a579 ("tc: m_action: Use C99 style initializers for struct req")
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
Changes since v2:
- Don't drop the "superfluous" comma.
- Flatten initializers.
Changes since v1:
- Created this patch.
---
 tc/m_action.c | 23 +++++++----------------
 1 file changed, 7 insertions(+), 16 deletions(-)

diff --git a/tc/m_action.c b/tc/m_action.c
index ea16817aefd4f..806fdd197965d 100644
--- a/tc/m_action.c
+++ b/tc/m_action.c
@@ -395,13 +395,10 @@ static int tc_action_gd(int cmd, unsigned int flags, int *argc_p, char ***argv_p
 		struct tcamsg           t;
 		char                    buf[MAX_MSG];
 	} req = {
-		.n = {
-			.nlmsg_len = NLMSG_LENGTH(sizeof(struct tcamsg)),
-			.nlmsg_flags = NLM_F_REQUEST | flags,
-			.nlmsg_type = cmd,
-		},
+		.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct tcamsg)),
+		.n.nlmsg_flags = NLM_F_REQUEST | flags,
+		.n.nlmsg_type = cmd,
 		.t.tca_family = AF_UNSPEC,
-		.buf = { 0 }
 	};
 
 	argc -= 1;
@@ -491,23 +488,18 @@ static int tc_action_modify(int cmd, unsigned int flags, int *argc_p, char ***ar
 	int argc = *argc_p;
 	char **argv = *argv_p;
 	int ret = 0;
-
-	struct rtattr *tail;
 	struct {
 		struct nlmsghdr         n;
 		struct tcamsg           t;
 		char                    buf[MAX_MSG];
 	} req = {
-		.n = {
-			.nlmsg_len = NLMSG_LENGTH(sizeof(struct tcamsg)),
-			.nlmsg_flags = NLM_F_REQUEST | flags,
-			.nlmsg_type = cmd,
-		},
+		.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct tcamsg)),
+		.n.nlmsg_flags = NLM_F_REQUEST | flags,
+		.n.nlmsg_type = cmd,
 		.t.tca_family = AF_UNSPEC,
-		.buf = { 0 }
 	};
+	struct rtattr *tail = NLMSG_TAIL(&req.n);
 
-	tail = NLMSG_TAIL(&req.n);
 	argc -= 1;
 	argv += 1;
 	if (parse_action(&argc, &argv, TCA_ACT_TAB, &req.n)) {
@@ -540,7 +532,6 @@ static int tc_act_list_or_flush(int argc, char **argv, int event)
 	} req = {
 		.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct tcamsg)),
 		.t.tca_family = AF_UNSPEC,
-		.buf = { 0 }
 	};
 
 	tail = NLMSG_TAIL(&req.n);
-- 
2.8.2
