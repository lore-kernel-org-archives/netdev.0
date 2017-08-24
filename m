From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v4 4/4] tipc/bearer: Prevent NULL pointer dereference
Date: Thu, 24 Aug 2017 11:46:34 +0200
Message-ID: <20170824094634.4093-5-phil@nwl.cc>
References: <20170824094634.4093-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:58599 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752587AbdHXJrF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Aug 2017 05:47:05 -0400
In-Reply-To: <20170824094634.4093-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
Changes since v2:
- Keep assignment and check in separate statements.
---
 tipc/bearer.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tipc/bearer.c b/tipc/bearer.c
index c3d4491f8f6ef..0d84570150624 100644
--- a/tipc/bearer.c
+++ b/tipc/bearer.c
@@ -439,7 +439,7 @@ static int cmd_bearer_enable(struct nlmsghdr *nlh, const struct cmd *cmd,
 		return err;
 
 	opt = get_opt(opts, "media");
-	if (strcmp(opt->val, "udp") == 0) {
+	if (opt && strcmp(opt->val, "udp") == 0) {
 		err = nl_add_udp_enable_opts(nlh, opts, cmdl);
 		if (err)
 			return err;
-- 
2.13.1
