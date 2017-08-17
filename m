From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 5/5] tipc/bearer: Prevent NULL pointer dereference
Date: Thu, 17 Aug 2017 19:09:31 +0200
Message-ID: <20170817170931.24545-6-phil@nwl.cc>
References: <20170817170931.24545-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:45049 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753331AbdHQRK1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 13:10:27 -0400
In-Reply-To: <20170817170931.24545-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tipc/bearer.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tipc/bearer.c b/tipc/bearer.c
index c3d4491f8f6ef..0598328ab1f1b 100644
--- a/tipc/bearer.c
+++ b/tipc/bearer.c
@@ -438,8 +438,8 @@ static int cmd_bearer_enable(struct nlmsghdr *nlh, const struct cmd *cmd,
 	if (err)
 		return err;
 
-	opt = get_opt(opts, "media");
-	if (strcmp(opt->val, "udp") == 0) {
+	if ((opt = get_opt(opts, "media")) &&
+	    strcmp(opt->val, "udp") == 0) {
 		err = nl_add_udp_enable_opts(nlh, opts, cmdl);
 		if (err)
 			return err;
-- 
2.13.1
