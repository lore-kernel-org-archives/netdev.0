From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH iproute2] ip link: use addattr_nest()/addattr_nest_end()
Date: Wed, 17 Dec 2014 15:28:45 +0800
Message-ID: <549130AD.6090407@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: stephen hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:29288 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751137AbaLQH2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 02:28:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Use addattr_nest() and addattr_nest_end() to simplify the code.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 ip/iplink.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index ce6eb3e..3ce5e39 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -706,11 +706,11 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 	}
 
 	if (type) {
-		struct rtattr *linkinfo = NLMSG_TAIL(&req.n);
+		struct rtattr *linkinfo;
 		char slavebuf[128], *ulinep = strchr(type, '_');
 		int iflatype;
 
-		addattr_l(&req.n, sizeof(req), IFLA_LINKINFO, NULL, 0);
+		linkinfo = addattr_nest(&req.n, sizeof(req), IFLA_LINKINFO);
 		addattr_l(&req.n, sizeof(req), IFLA_INFO_KIND, type,
 			 strlen(type));
 
@@ -728,14 +728,13 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 			iflatype = IFLA_INFO_DATA;
 		}
 		if (lu && argc) {
-			struct rtattr * data = NLMSG_TAIL(&req.n);
-			addattr_l(&req.n, sizeof(req), iflatype, NULL, 0);
+			struct rtattr *data = addattr_nest(&req.n, sizeof(req), iflatype);
 
 			if (lu->parse_opt &&
 			    lu->parse_opt(lu, argc, argv, &req.n))
 				return -1;
 
-			data->rta_len = (void *)NLMSG_TAIL(&req.n) - (void *)data;
+			addattr_nest_end(&req.n, data);
 		} else if (argc) {
 			if (matches(*argv, "help") == 0)
 				usage();
@@ -743,7 +742,7 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 					"Try \"ip link help\".\n", *argv);
 			return -1;
 		}
-		linkinfo->rta_len = (void *)NLMSG_TAIL(&req.n) - (void *)linkinfo;
+		addattr_nest_end(&req.n, linkinfo);
 	} else if (flags & NLM_F_CREATE) {
 		fprintf(stderr, "Not enough information: \"type\" argument "
 				"is required\n");
-- 
1.8.3.1
