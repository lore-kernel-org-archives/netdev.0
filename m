From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2] libnetlink: don't confuse variables in rtnl_talk()
Date: Thu,  3 Dec 2015 17:13:48 +0100
Message-ID: <1449159228-4233-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:51443 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760574AbbLCQOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 11:14:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is two variables named 'len' in rtnl_talk. In fact, commit
c079e121a73a didn't work. For example, it was possible to trigger
a seg fault with this command:
$ ip link set gre2 type ip6gre hoplimit 32

Let's rename the argument len to maxlen.

Fixes: c079e121a73a ("libnetlink: add size argument to rtnl_talk")
Reported-by: Thomas Faivre <thomas.faivre@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 lib/libnetlink.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 922ec2d9f872..165821447b2d 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -332,7 +332,7 @@ int rtnl_dump_filter_nc(struct rtnl_handle *rth,
 }
 
 int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
-	      struct nlmsghdr *answer, size_t len)
+	      struct nlmsghdr *answer, size_t maxlen)
 {
 	int status;
 	unsigned seq;
@@ -415,7 +415,7 @@ int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 				} else if (!err->error) {
 					if (answer)
 						memcpy(answer, h,
-						       MIN(len, h->nlmsg_len));
+						       MIN(maxlen, h->nlmsg_len));
 					return 0;
 				}
 
@@ -427,7 +427,7 @@ int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 
 			if (answer) {
 				memcpy(answer, h,
-				       MIN(len, h->nlmsg_len));
+				       MIN(maxlen, h->nlmsg_len));
 				return 0;
 			}
 
-- 
2.4.2
