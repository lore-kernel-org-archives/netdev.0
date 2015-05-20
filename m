From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2-next 4/6] ipmonitor: introduce print_headers
Date: Wed, 20 May 2015 16:19:59 +0200
Message-ID: <1432131601-4641-5-git-send-email-nicolas.dichtel@6wind.com>
References: <20150509.221554.38834063932093195.davem@davemloft.net>
 <1432131601-4641-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:44039 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753900AbbETOUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 10:20:09 -0400
In-Reply-To: <1432131601-4641-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal of this patch is to avoid code duplication.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/ipmonitor.c | 45 +++++++++++++++++++--------------------------
 1 file changed, 19 insertions(+), 26 deletions(-)

diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index 27bbe4410644..cae186d86153 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -37,6 +37,15 @@ static void usage(void)
 	exit(-1);
 }
 
+static void print_headers(FILE *fp, char *label)
+{
+	if (timestamp)
+		print_timestamp(fp);
+
+	if (prefix_banner)
+		fprintf(fp, "%s", label);
+}
+
 static int accept_msg(const struct sockaddr_nl *who,
 		      struct rtnl_ctrl_data *ctrl,
 		      struct nlmsghdr *n, void *arg)
@@ -55,42 +64,31 @@ static int accept_msg(const struct sockaddr_nl *who,
 		if (r->rtm_flags & RTM_F_CLONED)
 			return 0;
 
-		if (timestamp)
-			print_timestamp(fp);
-
 		if (r->rtm_family == RTNL_FAMILY_IPMR ||
 		    r->rtm_family == RTNL_FAMILY_IP6MR) {
-			if (prefix_banner)
-				fprintf(fp, "[MROUTE]");
+			print_headers(fp, "[MROUTE]");
 			print_mroute(who, n, arg);
 			return 0;
 		} else {
-			if (prefix_banner)
-				fprintf(fp, "[ROUTE]");
+			print_headers(fp, "[ROUTE]");
 			print_route(who, n, arg);
 			return 0;
 		}
 	}
 
-	if (timestamp)
-		print_timestamp(fp);
-
 	if (n->nlmsg_type == RTM_NEWLINK || n->nlmsg_type == RTM_DELLINK) {
 		ll_remember_index(who, n, NULL);
-		if (prefix_banner)
-			fprintf(fp, "[LINK]");
+		print_headers(fp, "[LINK]");
 		print_linkinfo(who, n, arg);
 		return 0;
 	}
 	if (n->nlmsg_type == RTM_NEWADDR || n->nlmsg_type == RTM_DELADDR) {
-		if (prefix_banner)
-			fprintf(fp, "[ADDR]");
+		print_headers(fp, "[ADDR]");
 		print_addrinfo(who, n, arg);
 		return 0;
 	}
 	if (n->nlmsg_type == RTM_NEWADDRLABEL || n->nlmsg_type == RTM_DELADDRLABEL) {
-		if (prefix_banner)
-			fprintf(fp, "[ADDRLABEL]");
+		print_headers(fp, "[ADDRLABEL]");
 		print_addrlabel(who, n, arg);
 		return 0;
 	}
@@ -103,26 +101,22 @@ static int accept_msg(const struct sockaddr_nl *who,
 				return 0;
 		}
 
-		if (prefix_banner)
-			fprintf(fp, "[NEIGH]");
+		print_headers(fp, "[NEIGH]");
 		print_neigh(who, n, arg);
 		return 0;
 	}
 	if (n->nlmsg_type == RTM_NEWPREFIX) {
-		if (prefix_banner)
-			fprintf(fp, "[PREFIX]");
+		print_headers(fp, "[PREFIX]");
 		print_prefix(who, n, arg);
 		return 0;
 	}
 	if (n->nlmsg_type == RTM_NEWRULE || n->nlmsg_type == RTM_DELRULE) {
-		if (prefix_banner)
-			fprintf(fp, "[RULE]");
+		print_headers(fp, "[RULE]");
 		print_rule(who, n, arg);
 		return 0;
 	}
 	if (n->nlmsg_type == RTM_NEWNETCONF) {
-		if (prefix_banner)
-			fprintf(fp, "[NETCONF]");
+		print_headers(fp, "[NETCONF]");
 		print_netconf(who, ctrl, n, arg);
 		return 0;
 	}
@@ -131,8 +125,7 @@ static int accept_msg(const struct sockaddr_nl *who,
 		return 0;
 	}
 	if (n->nlmsg_type == RTM_NEWNSID || n->nlmsg_type == RTM_DELNSID) {
-		if (prefix_banner)
-			fprintf(fp, "[NSID]");
+		print_headers(fp, "[NSID]");
 		print_nsid(who, n, arg);
 		return 0;
 	}
-- 
2.2.2
