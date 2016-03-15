From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next iproute2 v2 1/2] netconf: add support for ignore route attribute
Date: Tue, 15 Mar 2016 02:32:11 +0000
Message-ID: <1458009132-21621-2-git-send-email-zhangshengju@cmss.chinamobile.com>
References: <1458009132-21621-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:2875 "EHLO
	cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933379AbcCOC2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 22:28:11 -0400
In-Reply-To: <1458009132-21621-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for ignore route attribute, and refine the code to use
rta_getattr_* function to get attribute value.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 ip/ipnetconf.c | 25 +++++++++++++++++--------
 1 file changed, 17 insertions(+), 8 deletions(-)

diff --git a/ip/ipnetconf.c b/ip/ipnetconf.c
index eca6eee..caea63b 100644
--- a/ip/ipnetconf.c
+++ b/ip/ipnetconf.c
@@ -38,6 +38,11 @@ static void usage(void)
 	exit(-1);
 }
 
+static void print_onoff(FILE *f, char *flag, __u32 val)
+{
+	fprintf(f, "%s %s ", flag, val ? "on" : "off");
+}
+
 #define NETCONF_RTA(r)	((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct netconfmsg))))
 
 int print_netconf(const struct sockaddr_nl *who, struct rtnl_ctrl_data *ctrl,
@@ -81,7 +86,7 @@ int print_netconf(const struct sockaddr_nl *who, struct rtnl_ctrl_data *ctrl,
 	}
 
 	if (tb[NETCONFA_IFINDEX]) {
-		int *ifindex = (int *)RTA_DATA(tb[NETCONFA_IFINDEX]);
+		int *ifindex = (int *)rta_getattr_str(tb[NETCONFA_IFINDEX]);
 
 		switch (*ifindex) {
 		case NETCONFA_IFINDEX_ALL:
@@ -97,10 +102,10 @@ int print_netconf(const struct sockaddr_nl *who, struct rtnl_ctrl_data *ctrl,
 	}
 
 	if (tb[NETCONFA_FORWARDING])
-		fprintf(fp, "forwarding %s ",
-			*(int *)RTA_DATA(tb[NETCONFA_FORWARDING])?"on":"off");
+		print_onoff(fp, "forwarding",
+				rta_getattr_u32(tb[NETCONFA_FORWARDING]));
 	if (tb[NETCONFA_RP_FILTER]) {
-		int rp_filter = *(int *)RTA_DATA(tb[NETCONFA_RP_FILTER]);
+		__u32 rp_filter = rta_getattr_u32(tb[NETCONFA_RP_FILTER]);
 
 		if (rp_filter == 0)
 			fprintf(fp, "rp_filter off ");
@@ -112,12 +117,16 @@ int print_netconf(const struct sockaddr_nl *who, struct rtnl_ctrl_data *ctrl,
 			fprintf(fp, "rp_filter unknown mode ");
 	}
 	if (tb[NETCONFA_MC_FORWARDING])
-		fprintf(fp, "mc_forwarding %d ",
-			*(int *)RTA_DATA(tb[NETCONFA_MC_FORWARDING]));
+		print_onoff(fp, "mc_forwarding",
+				rta_getattr_u32(tb[NETCONFA_MC_FORWARDING]));
 
 	if (tb[NETCONFA_PROXY_NEIGH])
-		fprintf(fp, "proxy_neigh %s ",
-			*(int *)RTA_DATA(tb[NETCONFA_PROXY_NEIGH])?"on":"off");
+		print_onoff(fp, "proxy_neigh",
+				rta_getattr_u32(tb[NETCONFA_PROXY_NEIGH]));
+
+	if (tb[NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN])
+		print_onoff(fp, "ignore_routes_with_linkdown",
+		     rta_getattr_u32(tb[NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN]));
 
 	fprintf(fp, "\n");
 	fflush(fp);
-- 
1.8.3.1
