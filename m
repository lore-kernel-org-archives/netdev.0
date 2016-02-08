From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 v2 21/21] iplink: bridge: add support for netfilter call attributes
Date: Tue,  9 Feb 2016 00:14:39 +0100
Message-ID: <1454973279-9170-22-git-send-email-razor@blackwall.org>
References: <1454973279-9170-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:35227 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932607AbcBHXPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 18:15:01 -0500
Received: by mail-wm0-f42.google.com with SMTP id c200so37718281wme.0
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 15:15:01 -0800 (PST)
In-Reply-To: <1454973279-9170-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

This patch implements support for the IFLA_BR_NF_CALL_(IP|IP6|ARP)TABLES
attributes in iproute2 so it can change their values.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 ip/iplink_bridge.c | 45 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 45 insertions(+)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index a55a36adacdf..1b666f0adef4 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -47,6 +47,9 @@ static void print_explain(FILE *f)
 		"                  [ mcast_query_interval QUERY_INTERVAL ]\n"
 		"                  [ mcast_query_response_interval QUERY_RESPONSE_INTERVAL ]\n"
 		"                  [ mcast_startup_query_interval STARTUP_QUERY_INTERVAL ]\n"
+		"                  [ nf_call_iptables NF_CALL_IPTABLES ]\n"
+		"                  [ nf_call_ip6tables NF_CALL_IP6TABLES ]\n"
+		"                  [ nf_call_arptables NF_CALL_ARPTABLES ]\n"
 		"\n"
 		"Where: VLAN_PROTOCOL := { 802.1Q | 802.1ad }\n"
 	);
@@ -292,6 +295,36 @@ static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 			}
 			addattr64(n, 1024, IFLA_BR_MCAST_STARTUP_QUERY_INTVL,
 				  mcast_startup_query_intvl);
+		} else if (matches(*argv, "nf_call_iptables") == 0) {
+			__u8 nf_call_ipt;
+
+			NEXT_ARG();
+			if (get_u8(&nf_call_ipt, *argv, 0)) {
+				invarg("invalid nf_call_iptables", *argv);
+				return -1;
+			}
+			addattr8(n, 1024, IFLA_BR_NF_CALL_IPTABLES,
+				 nf_call_ipt);
+		} else if (matches(*argv, "nf_call_ip6tables") == 0) {
+			__u8 nf_call_ip6t;
+
+			NEXT_ARG();
+			if (get_u8(&nf_call_ip6t, *argv, 0)) {
+				invarg("invalid nf_call_ip6tables", *argv);
+				return -1;
+			}
+			addattr8(n, 1024, IFLA_BR_NF_CALL_IP6TABLES,
+				 nf_call_ip6t);
+		} else if (matches(*argv, "nf_call_arptables") == 0) {
+			__u8 nf_call_arpt;
+
+			NEXT_ARG();
+			if (get_u8(&nf_call_arpt, *argv, 0)) {
+				invarg("invalid nf_call_arptables", *argv);
+				return -1;
+			}
+			addattr8(n, 1024, IFLA_BR_NF_CALL_ARPTABLES,
+				 nf_call_arpt);
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -485,6 +518,18 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_BR_MCAST_STARTUP_QUERY_INTVL])
 		fprintf(f, "mcast_startup_query_interval %llu ",
 			rta_getattr_u64(tb[IFLA_BR_MCAST_STARTUP_QUERY_INTVL]));
+
+	if (tb[IFLA_BR_NF_CALL_IPTABLES])
+		fprintf(f, "nf_call_iptables %u ",
+			rta_getattr_u8(tb[IFLA_BR_NF_CALL_IPTABLES]));
+
+	if (tb[IFLA_BR_NF_CALL_IP6TABLES])
+		fprintf(f, "nf_call_ip6tables %u ",
+			rta_getattr_u8(tb[IFLA_BR_NF_CALL_IP6TABLES]));
+
+	if (tb[IFLA_BR_NF_CALL_ARPTABLES])
+		fprintf(f, "nf_call_arptables %u ",
+			rta_getattr_u8(tb[IFLA_BR_NF_CALL_ARPTABLES]));
 }
 
 static void bridge_print_help(struct link_util *lu, int argc, char **argv,
-- 
2.4.3
