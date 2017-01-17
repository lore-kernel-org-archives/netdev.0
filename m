From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH iproute2 net-next 4/5] iplink: bridge: add support for IFLA_BR_MCAST_IGMP_VERSION
Date: Tue, 17 Jan 2017 17:32:31 +0800
Message-ID: <1484645552-29440-5-git-send-email-liuhangbin@gmail.com>
References: <1484645552-29440-1-git-send-email-liuhangbin@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35775 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751028AbdAQJmT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 04:42:19 -0500
Received: by mail-pf0-f194.google.com with SMTP id f144so15915232pfa.2
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 01:42:18 -0800 (PST)
In-Reply-To: <1484645552-29440-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements support for the IFLA_BR_MCAST_IGMP_VERSION
attribute in iproute2 so it can change the mcast igmp version.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 ip/iplink_bridge.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index 622bd07..6611a85 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -50,6 +50,7 @@ static void print_explain(FILE *f)
 		"                  [ mcast_query_response_interval QUERY_RESPONSE_INTERVAL ]\n"
 		"                  [ mcast_startup_query_interval STARTUP_QUERY_INTERVAL ]\n"
 		"                  [ mcast_state MCAST_STATE ]\n"
+		"                  [ mcast_igmp_version IGMP_VERSION ]\n"
 		"                  [ nf_call_iptables NF_CALL_IPTABLES ]\n"
 		"                  [ nf_call_ip6tables NF_CALL_IP6TABLES ]\n"
 		"                  [ nf_call_arptables NF_CALL_ARPTABLES ]\n"
@@ -308,6 +309,14 @@ static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 				invarg("invalid mcast_state", *argv);
 			addattr8(n, 1024, IFLA_BR_MCAST_STATS_ENABLED,
 				  mcast_state);
+		} else if (matches(*argv, "mcast_igmp_version") == 0) {
+			__u8 igmp_version;
+
+			NEXT_ARG();
+			if (get_u8(&igmp_version, *argv, 0))
+				invarg("invalid mcast_igmp_version", *argv);
+			addattr8(n, 1024, IFLA_BR_MCAST_IGMP_VERSION,
+				  igmp_version);
 		} else if (matches(*argv, "nf_call_iptables") == 0) {
 			__u8 nf_call_ipt;
 
@@ -537,6 +546,10 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		fprintf(f, "mcast_state %u ",
 			rta_getattr_u8(tb[IFLA_BR_MCAST_STATS_ENABLED]));
 
+	if (tb[IFLA_BR_MCAST_IGMP_VERSION])
+		fprintf(f, "mcast_igmp_version %u ",
+			rta_getattr_u8(tb[IFLA_BR_MCAST_IGMP_VERSION]));
+
 	if (tb[IFLA_BR_NF_CALL_IPTABLES])
 		fprintf(f, "nf_call_iptables %u ",
 			rta_getattr_u8(tb[IFLA_BR_NF_CALL_IPTABLES]));
-- 
2.5.5
