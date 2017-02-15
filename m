From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next 3/3] iplink: bridge_slave: add support for displaying xstats
Date: Wed, 15 Feb 2017 15:23:13 +0100
Message-ID: <1487168593-31321-4-git-send-email-nikolay@cumulusnetworks.com>
References: <1487168593-31321-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f170.google.com ([209.85.128.170]:36191 "EHLO
        mail-wr0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750999AbdBOOX3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 09:23:29 -0500
Received: by mail-wr0-f170.google.com with SMTP id k90so191646590wrc.3
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 06:23:28 -0800 (PST)
In-Reply-To: <1487168593-31321-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support to the bridge_slave link type for displaying
xstats by reusing the previously added bridge xstats callbacks.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 ip/ip_common.h           | 3 +++
 ip/iplink_bridge.c       | 6 +++---
 ip/iplink_bridge_slave.c | 2 ++
 3 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/ip/ip_common.h b/ip/ip_common.h
index 071c3db280f2..9c3cd294d79e 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -97,6 +97,9 @@ struct link_util {
 struct link_util *get_link_kind(const char *kind);
 
 void br_dump_bridge_id(const struct ifla_bridge_id *id, char *buf, size_t len);
+int bridge_parse_xstats(struct link_util *lu, int argc, char **argv);
+int bridge_print_xstats(const struct sockaddr_nl *who,
+			struct nlmsghdr *n, void *arg);
 
 __u32 ipvrf_get_table(const char *name);
 int name_is_vrf(const char *name);
diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index 62ceee6b571e..818b43c89b5b 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -680,8 +680,8 @@ static void bridge_print_stats_attr(FILE *f, struct rtattr *attr, int ifindex)
 	}
 }
 
-static int bridge_print_xstats(const struct sockaddr_nl *who,
-			       struct nlmsghdr *n, void *arg)
+int bridge_print_xstats(const struct sockaddr_nl *who,
+			struct nlmsghdr *n, void *arg)
 {
 	struct if_stats_msg *ifsm = NLMSG_DATA(n);
 	struct rtattr *tb[IFLA_STATS_MAX+1];
@@ -708,7 +708,7 @@ static int bridge_print_xstats(const struct sockaddr_nl *who,
 	return 0;
 }
 
-static int bridge_parse_xstats(struct link_util *lu, int argc, char **argv)
+int bridge_parse_xstats(struct link_util *lu, int argc, char **argv)
 {
 	while (argc > 0) {
 		if (strcmp(*argv, "igmp") == 0 || strcmp(*argv, "mcast") == 0) {
diff --git a/ip/iplink_bridge_slave.c b/ip/iplink_bridge_slave.c
index 6353fc533bf9..3e883328ae0c 100644
--- a/ip/iplink_bridge_slave.c
+++ b/ip/iplink_bridge_slave.c
@@ -312,4 +312,6 @@ struct link_util bridge_slave_link_util = {
 	.print_opt	= bridge_slave_print_opt,
 	.parse_opt	= bridge_slave_parse_opt,
 	.print_help     = bridge_slave_print_help,
+	.parse_ifla_xstats = bridge_parse_xstats,
+	.print_ifla_xstats = bridge_print_xstats,
 };
-- 
2.1.4
