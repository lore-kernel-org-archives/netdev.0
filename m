From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCHv2 iproute2 net-next 5/5] iplink: bridge: add support for IFLA_BR_MCAST_MLD_VERSION
Date: Wed, 18 Jan 2017 14:12:51 +0800
Message-ID: <1484719971-21693-6-git-send-email-liuhangbin@gmail.com>
References: <1484719971-21693-1-git-send-email-liuhangbin@gmail.com>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35489 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751470AbdARGV6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 01:21:58 -0500
Received: by mail-pf0-f196.google.com with SMTP id f144so412230pfa.2
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 22:21:25 -0800 (PST)
In-Reply-To: <1484719971-21693-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements support for the IFLA_BR_MCAST_MLD_VERSION
attribute in iproute2 so it can change the mcast mld version.

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 ip/iplink_bridge.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index 3e9143e..a17ff35 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -51,6 +51,7 @@ static void print_explain(FILE *f)
 		"                  [ mcast_startup_query_interval STARTUP_QUERY_INTERVAL ]\n"
 		"                  [ mcast_stats_enabled MCAST_STATS_ENABLED ]\n"
 		"                  [ mcast_igmp_version IGMP_VERSION ]\n"
+		"                  [ mcast_mld_version MLD_VERSION ]\n"
 		"                  [ nf_call_iptables NF_CALL_IPTABLES ]\n"
 		"                  [ nf_call_ip6tables NF_CALL_IP6TABLES ]\n"
 		"                  [ nf_call_arptables NF_CALL_ARPTABLES ]\n"
@@ -317,6 +318,14 @@ static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 				invarg("invalid mcast_igmp_version", *argv);
 			addattr8(n, 1024, IFLA_BR_MCAST_IGMP_VERSION,
 				  igmp_version);
+		} else if (matches(*argv, "mcast_mld_version") == 0) {
+			__u8 mld_version;
+
+			NEXT_ARG();
+			if (get_u8(&mld_version, *argv, 0))
+				invarg("invalid mcast_mld_version", *argv);
+			addattr8(n, 1024, IFLA_BR_MCAST_MLD_VERSION,
+				  mld_version);
 		} else if (matches(*argv, "nf_call_iptables") == 0) {
 			__u8 nf_call_ipt;
 
@@ -550,6 +559,10 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		fprintf(f, "mcast_igmp_version %u ",
 			rta_getattr_u8(tb[IFLA_BR_MCAST_IGMP_VERSION]));
 
+	if (tb[IFLA_BR_MCAST_MLD_VERSION])
+		fprintf(f, "mcast_mld_version %u ",
+			rta_getattr_u8(tb[IFLA_BR_MCAST_MLD_VERSION]));
+
 	if (tb[IFLA_BR_NF_CALL_IPTABLES])
 		fprintf(f, "nf_call_iptables %u ",
 			rta_getattr_u8(tb[IFLA_BR_NF_CALL_IPTABLES]));
-- 
2.5.5
