From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2] ip: Add support for MPLS netconf
Date: Tue, 21 Feb 2017 09:23:31 -0800
Message-ID: <1487697811-28638-1-git-send-email-dsa@cumulusnetworks.com>
Cc: nicolas.dichtel@6wind.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:36204 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753782AbdBURXj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 12:23:39 -0500
Received: by mail-pg0-f49.google.com with SMTP id s67so27422466pgb.3
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 09:23:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for MPLS netconf to ip monitor and ip netconf commands.
Changes to header files not included as those are typically pulled
in my a header sync with the kernel.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 ip/ipmonitor.c | 3 +++
 ip/ipnetconf.c | 6 ++++++
 2 files changed, 9 insertions(+)

diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index c892b8f1c224..3171d4712887 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -176,6 +176,7 @@ int do_ipmonitor(int argc, char **argv)
 	groups |= nl_mgrp(RTNLGRP_IPV4_RULE);
 	groups |= nl_mgrp(RTNLGRP_IPV6_RULE);
 	groups |= nl_mgrp(RTNLGRP_NSID);
+	groups |= nl_mgrp(RTNLGRP_MPLS_NETCONF);
 
 	rtnl_close(&rth);
 
@@ -271,6 +272,8 @@ int do_ipmonitor(int argc, char **argv)
 			groups |= nl_mgrp(RTNLGRP_IPV4_NETCONF);
 		if (!preferred_family || preferred_family == AF_INET6)
 			groups |= nl_mgrp(RTNLGRP_IPV6_NETCONF);
+		if (!preferred_family || preferred_family == AF_MPLS)
+			groups |= nl_mgrp(RTNLGRP_MPLS_NETCONF);
 	}
 	if (lrule) {
 		if (!preferred_family || preferred_family == AF_INET)
diff --git a/ip/ipnetconf.c b/ip/ipnetconf.c
index 50c4e33cfe93..af539f5e945c 100644
--- a/ip/ipnetconf.c
+++ b/ip/ipnetconf.c
@@ -83,6 +83,9 @@ int print_netconf(const struct sockaddr_nl *who, struct rtnl_ctrl_data *ctrl,
 	case AF_INET6:
 		fprintf(fp, "ipv6 ");
 		break;
+	case AF_MPLS:
+		fprintf(fp, "mpls ");
+		break;
 	default:
 		fprintf(fp, "unknown ");
 		break;
@@ -131,6 +134,9 @@ int print_netconf(const struct sockaddr_nl *who, struct rtnl_ctrl_data *ctrl,
 		print_onoff(fp, "ignore_routes_with_linkdown",
 		     rta_getattr_u32(tb[NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN]));
 
+	if (tb[NETCONFA_INPUT])
+		print_onoff(fp, "input", rta_getattr_u32(tb[NETCONFA_INPUT]));
+
 	fprintf(fp, "\n");
 	fflush(fp);
 	return 0;
-- 
2.1.4
