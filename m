From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 1/2] tc: m_action: Fix for field init before memset
Date: Wed, 15 Jun 2016 00:26:08 +0200
Message-ID: <1465943169-4101-2-git-send-email-phil@nwl.cc>
References: <1465943169-4101-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org, Phil Sutter <psutter@redhat.com>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:39894 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751943AbcFNW0f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 18:26:35 -0400
In-Reply-To: <1465943169-4101-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <psutter@redhat.com>

Initializing req.t.tca_family before setting the whole req object to
zero using memset does not make sense. Instead initialize the field
after calling memset.

Note that this change has no functional effect since AF_UNSPEC is
defined to 0 anyway, so this fix is a purely cosmetic one.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/m_action.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/tc/m_action.c b/tc/m_action.c
index c416d98a775a6..1b34370f4ec09 100644
--- a/tc/m_action.c
+++ b/tc/m_action.c
@@ -397,9 +397,8 @@ static int tc_action_gd(int cmd, unsigned int flags, int *argc_p, char ***argv_p
 		char                    buf[MAX_MSG];
 	} req;
 
-	req.t.tca_family = AF_UNSPEC;
-
 	memset(&req, 0, sizeof(req));
+	req.t.tca_family = AF_UNSPEC;
 
 	memset(&nladdr, 0, sizeof(nladdr));
 	nladdr.nl_family = AF_NETLINK;
@@ -502,10 +501,8 @@ static int tc_action_modify(int cmd, unsigned int flags, int *argc_p, char ***ar
 		char                    buf[MAX_MSG];
 	} req;
 
-	req.t.tca_family = AF_UNSPEC;
-
 	memset(&req, 0, sizeof(req));
-
+	req.t.tca_family = AF_UNSPEC;
 	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct tcamsg));
 	req.n.nlmsg_flags = NLM_F_REQUEST|flags;
 	req.n.nlmsg_type = cmd;
@@ -541,10 +538,8 @@ static int tc_act_list_or_flush(int argc, char **argv, int event)
 		char                    buf[MAX_MSG];
 	} req;
 
-	req.t.tca_family = AF_UNSPEC;
-
 	memset(&req, 0, sizeof(req));
-
+	req.t.tca_family = AF_UNSPEC;
 	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct tcamsg));
 
 	tail = NLMSG_TAIL(&req.n);
-- 
2.8.2
