From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [iproute PATCH] ss: Remove unused argument from kill_inet_sock
Date: Mon,  9 May 2016 14:54:36 -0600
Message-ID: <1462827276-3822-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: lorenzo@google.com, netdev@vger.kernel.org,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:52814 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447AbcEIU4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 16:56:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

addr is not used here.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 misc/ss.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index deefc96..5cda728 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2232,8 +2232,7 @@ struct inet_diag_arg {
 	struct rtnl_handle *rth;
 };
 
-static int kill_inet_sock(const struct sockaddr_nl *addr,
-		struct nlmsghdr *h, void *arg)
+static int kill_inet_sock(struct nlmsghdr *h, void *arg)
 {
 	struct inet_diag_msg *d = NLMSG_DATA(h);
 	struct inet_diag_arg *diag_arg = arg;
@@ -2260,7 +2259,7 @@ static int show_one_inet_sock(const struct sockaddr_nl *addr,
 
 	if (!(diag_arg->f->families & (1 << r->idiag_family)))
 		return 0;
-	if (diag_arg->f->kill && kill_inet_sock(addr, h, arg) != 0) {
+	if (diag_arg->f->kill && kill_inet_sock(h, arg) != 0) {
 		if (errno == EOPNOTSUPP || errno == ENOENT) {
 			/* Socket can't be closed, or is already closed. */
 			return 0;
-- 
1.8.2.1
