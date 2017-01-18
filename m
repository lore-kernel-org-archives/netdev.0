From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCHv2 iproute2 net-next 3/5] iplink: bridge: add support for IFLA_BR_MCAST_STATS_ENABLED
Date: Wed, 18 Jan 2017 14:12:49 +0800
Message-ID: <1484719971-21693-4-git-send-email-liuhangbin@gmail.com>
References: <1484719971-21693-1-git-send-email-liuhangbin@gmail.com>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33632 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751651AbdARGU6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 01:20:58 -0500
Received: by mail-pg0-f68.google.com with SMTP id 194so521741pgd.0
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 22:20:58 -0800 (PST)
In-Reply-To: <1484719971-21693-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements support for the IFLA_BR_MCAST_STATS_ENABLED
attribute in iproute2 so it can enable/disable mcast stats accounting.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 ip/iplink_bridge.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index cd495b3..46bbbee 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -49,6 +49,7 @@ static void print_explain(FILE *f)
 		"                  [ mcast_query_interval QUERY_INTERVAL ]\n"
 		"                  [ mcast_query_response_interval QUERY_RESPONSE_INTERVAL ]\n"
 		"                  [ mcast_startup_query_interval STARTUP_QUERY_INTERVAL ]\n"
+		"                  [ mcast_stats_enabled MCAST_STATS_ENABLED ]\n"
 		"                  [ nf_call_iptables NF_CALL_IPTABLES ]\n"
 		"                  [ nf_call_ip6tables NF_CALL_IP6TABLES ]\n"
 		"                  [ nf_call_arptables NF_CALL_ARPTABLES ]\n"
@@ -299,6 +300,14 @@ static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 
 			addattr64(n, 1024, IFLA_BR_MCAST_STARTUP_QUERY_INTVL,
 				  mcast_startup_query_intvl);
+		} else if (matches(*argv, "mcast_stats_enabled") == 0) {
+			__u8 mcast_stats_enabled;
+
+			NEXT_ARG();
+			if (get_u8(&mcast_stats_enabled, *argv, 0))
+				invarg("invalid mcast_stats_enabled", *argv);
+			addattr8(n, 1024, IFLA_BR_MCAST_STATS_ENABLED,
+				  mcast_stats_enabled);
 		} else if (matches(*argv, "nf_call_iptables") == 0) {
 			__u8 nf_call_ipt;
 
@@ -524,6 +533,10 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		fprintf(f, "mcast_startup_query_interval %llu ",
 			rta_getattr_u64(tb[IFLA_BR_MCAST_STARTUP_QUERY_INTVL]));
 
+	if (tb[IFLA_BR_MCAST_STATS_ENABLED])
+		fprintf(f, "mcast_stats_enabled %u ",
+			rta_getattr_u8(tb[IFLA_BR_MCAST_STATS_ENABLED]));
+
 	if (tb[IFLA_BR_NF_CALL_IPTABLES])
 		fprintf(f, "nf_call_iptables %u ",
 			rta_getattr_u8(tb[IFLA_BR_NF_CALL_IPTABLES]));
-- 
2.5.5
