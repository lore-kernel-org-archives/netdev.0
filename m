From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH iproute2 net-next] iplink: bridge_slave: add support for IFLA_BRPORT_FLUSH
Date: Wed, 18 Jan 2017 14:36:45 +0800
Message-ID: <1484721405-22519-1-git-send-email-liuhangbin@gmail.com>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33200 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbdARGhk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 01:37:40 -0500
Received: by mail-pg0-f65.google.com with SMTP id 194so560526pgd.0
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 22:37:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements support for the IFLA_BRPORT_FLUSH attribute
in iproute2 so it can flush bridge slave's fdb dynamic entries.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 ip/iplink_bridge_slave.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/ip/iplink_bridge_slave.c b/ip/iplink_bridge_slave.c
index fbb3f06..6353fc5 100644
--- a/ip/iplink_bridge_slave.c
+++ b/ip/iplink_bridge_slave.c
@@ -22,7 +22,10 @@
 static void print_explain(FILE *f)
 {
 	fprintf(f,
-		"Usage: ... bridge_slave [ state STATE ] [ priority PRIO ] [cost COST ]\n"
+		"Usage: ... bridge_slave [ fdb_flush ]\n"
+		"                        [ state STATE ]\n"
+		"                        [ priority PRIO ]\n"
+		"                        [ cost COST ]\n"
 		"                        [ guard {on | off} ]\n"
 		"                        [ hairpin {on | off} ]\n"
 		"                        [ fastleave {on | off} ]\n"
@@ -217,7 +220,9 @@ static int bridge_slave_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u32 cost;
 
 	while (argc > 0) {
-		if (matches(*argv, "state") == 0) {
+		if (matches(*argv, "fdb_flush") == 0) {
+			addattr(n, 1024, IFLA_BRPORT_FLUSH);
+		} else if (matches(*argv, "state") == 0) {
 			NEXT_ARG();
 			if (get_u8(&state, *argv, 0))
 				invarg("state is invalid", *argv);
-- 
2.5.5
