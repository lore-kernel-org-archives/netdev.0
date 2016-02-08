From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 03/21] iplink: bridge: export read-only timers
Date: Mon,  8 Feb 2016 12:55:09 +0100
Message-ID: <1454932527-30569-4-git-send-email-razor@blackwall.org>
References: <1454932527-30569-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:37227 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752073AbcBHL4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 06:56:12 -0500
Received: by mail-wm0-f53.google.com with SMTP id g62so112738745wme.0
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 03:56:11 -0800 (PST)
In-Reply-To: <1454932527-30569-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Netlink already provides hello_timer, tcn_timer, topology_change_timer
and gc_timer, so let's make them visible.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/utils.h    |  1 -
 ip/iplink_bridge.c | 16 ++++++++++++++++
 2 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/include/utils.h b/include/utils.h
index 7310f4e0e5db..f109521a904e 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -175,7 +175,6 @@ static inline __u32 nl_mgrp(__u32 group)
 	return group ? (1 << (group - 1)) : 0;
 }
 
-
 int print_timestamp(FILE *fp);
 void print_nlmsg_timestamp(FILE *fp, const struct nlmsghdr *n);
 
diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index d9a725b0be0f..8504be5625fa 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -196,6 +196,22 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_BR_TOPOLOGY_CHANGE_DETECTED])
 		fprintf(f, "topology_change_detected %u ",
 			rta_getattr_u8(tb[IFLA_BR_TOPOLOGY_CHANGE_DETECTED]));
+
+	if (tb[IFLA_BR_HELLO_TIMER])
+		fprintf(f, "hello_timer %llu ",
+			rta_getattr_u64(tb[IFLA_BR_HELLO_TIMER]));
+
+	if (tb[IFLA_BR_TCN_TIMER])
+		fprintf(f, "tcn_timer %llu ",
+			rta_getattr_u64(tb[IFLA_BR_TCN_TIMER]));
+
+	if (tb[IFLA_BR_TOPOLOGY_CHANGE_TIMER])
+		fprintf(f, "topology_change_timer %llu ",
+			rta_getattr_u64(tb[IFLA_BR_TOPOLOGY_CHANGE_TIMER]));
+
+	if (tb[IFLA_BR_GC_TIMER])
+		fprintf(f, "gc_timer %llu ",
+			rta_getattr_u64(tb[IFLA_BR_GC_TIMER]));
 }
 
 static void bridge_print_help(struct link_util *lu, int argc, char **argv,
-- 
2.4.3
