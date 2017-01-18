From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCHv2 iproute2 net-next 1/5] iplink: bridge: add support for IFLA_BR_FDB_FLUSH
Date: Wed, 18 Jan 2017 14:12:47 +0800
Message-ID: <1484719971-21693-2-git-send-email-liuhangbin@gmail.com>
References: <1484719971-21693-1-git-send-email-liuhangbin@gmail.com>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34638 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751507AbdARGV6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 01:21:58 -0500
Received: by mail-pg0-f67.google.com with SMTP id t6so520620pgt.1
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 22:21:36 -0800 (PST)
In-Reply-To: <1484719971-21693-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements support for the IFLA_BR_FDB_FLUSH attribute
in iproute2 so it can flush bridge fdb dynamic entries.

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 ip/iplink_bridge.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index d2d4202..85e6597 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -22,7 +22,8 @@
 static void print_explain(FILE *f)
 {
 	fprintf(f,
-		"Usage: ... bridge [ forward_delay FORWARD_DELAY ]\n"
+		"Usage: ... bridge [ fdb_flush ]\n"
+		"                  [ forward_delay FORWARD_DELAY ]\n"
 		"                  [ hello_time HELLO_TIME ]\n"
 		"                  [ max_age MAX_AGE ]\n"
 		"                  [ ageing_time AGEING_TIME ]\n"
@@ -145,6 +146,8 @@ static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 			if (len < 0)
 				return -1;
 			addattr_l(n, 1024, IFLA_BR_GROUP_ADDR, llabuf, len);
+		} else if (matches(*argv, "fdb_flush") == 0) {
+			addattr(n, 1024, IFLA_BR_FDB_FLUSH);
 		} else if (matches(*argv, "vlan_default_pvid") == 0) {
 			__u16 default_pvid;
 
-- 
2.5.5
