From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 1/7] tc: m_action: Improve conversion to C99 style initializers
Date: Tue, 21 Jun 2016 18:18:35 +0200
Message-ID: <1466525921-15738-2-git-send-email-phil@nwl.cc>
References: <1466525921-15738-1-git-send-email-phil@nwl.cc>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:37745 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752413AbcFUQ1l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2016 12:27:41 -0400
In-Reply-To: <1466525921-15738-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This improves my initial change in the following points:

- Drop superfluous comma after last expression in block.
- No need to initialize variables to zero as the key feature of C99
  initializers is to do this implicitly.
- By relocating the declaration of struct rtattr *tail, it can be
  initialized at the same time.

Fixes: a0a73b298a579 ("tc: m_action: Use C99 style initializers for struct req")
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/m_action.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/tc/m_action.c b/tc/m_action.c
index ea16817aefd4f..ce399d2e43ccc 100644
--- a/tc/m_action.c
+++ b/tc/m_action.c
@@ -398,10 +398,9 @@ static int tc_action_gd(int cmd, unsigned int flags, int *argc_p, char ***argv_p
 		.n = {
 			.nlmsg_len = NLMSG_LENGTH(sizeof(struct tcamsg)),
 			.nlmsg_flags = NLM_F_REQUEST | flags,
-			.nlmsg_type = cmd,
+			.nlmsg_type = cmd
 		},
-		.t.tca_family = AF_UNSPEC,
-		.buf = { 0 }
+		.t.tca_family = AF_UNSPEC
 	};
 
 	argc -= 1;
@@ -491,8 +490,6 @@ static int tc_action_modify(int cmd, unsigned int flags, int *argc_p, char ***ar
 	int argc = *argc_p;
 	char **argv = *argv_p;
 	int ret = 0;
-
-	struct rtattr *tail;
 	struct {
 		struct nlmsghdr         n;
 		struct tcamsg           t;
@@ -501,13 +498,12 @@ static int tc_action_modify(int cmd, unsigned int flags, int *argc_p, char ***ar
 		.n = {
 			.nlmsg_len = NLMSG_LENGTH(sizeof(struct tcamsg)),
 			.nlmsg_flags = NLM_F_REQUEST | flags,
-			.nlmsg_type = cmd,
+			.nlmsg_type = cmd
 		},
-		.t.tca_family = AF_UNSPEC,
-		.buf = { 0 }
+		.t.tca_family = AF_UNSPEC
 	};
+	struct rtattr *tail = NLMSG_TAIL(&req.n);
 
-	tail = NLMSG_TAIL(&req.n);
 	argc -= 1;
 	argv += 1;
 	if (parse_action(&argc, &argv, TCA_ACT_TAB, &req.n)) {
@@ -539,8 +535,7 @@ static int tc_act_list_or_flush(int argc, char **argv, int event)
 		char                    buf[MAX_MSG];
 	} req = {
 		.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct tcamsg)),
-		.t.tca_family = AF_UNSPEC,
-		.buf = { 0 }
+		.t.tca_family = AF_UNSPEC
 	};
 
 	tail = NLMSG_TAIL(&req.n);
-- 
2.8.2
