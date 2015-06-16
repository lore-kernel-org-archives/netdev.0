From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 net-next 2/3] iplink_bridge: add support for stp_state
Date: Tue, 16 Jun 2015 13:38:48 +0300
Message-ID: <1434451129-3241-3-git-send-email-razor@blackwall.org>
References: <1434451129-3241-1-git-send-email-razor@blackwall.org>
Cc: stephen@networkplumber.org, joerg@higgsboson.tk,
	davem@davemloft.net, Nikolay Aleksandrov <razor@blackwall.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:34051 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756788AbbFPKxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 06:53:19 -0400
Received: by wgv5 with SMTP id 5so9305518wgv.1
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2015 03:53:18 -0700 (PDT)
In-Reply-To: <1434451129-3241-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support to set stp_state via IFLA_BR_STP_STATE.

Signed-off-by: Nikolay Aleksandrov <razor@blackwall.org>
---
 ip/iplink_bridge.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index 2726a369803e..79b9e049ff92 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -24,6 +24,7 @@ static void explain(void)
 		"                  [ hello_time HELLO_TIME ]\n"
 		"                  [ max_age MAX_AGE ]\n"
 		"                  [ ageing_time AGEING_TIME ]\n"
+		"                  [ stp_state STP_STATE ]\n"
 	);
 }
 
@@ -61,6 +62,13 @@ static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 				return -1;
 			}
 			addattr32(n, 1024, IFLA_BR_AGEING_TIME, val);
+		} else if (matches(*argv, "stp_state") == 0) {
+			NEXT_ARG();
+			if (get_u32(&val, *argv, 0)) {
+				invarg("invalid stp_state", *argv);
+				return -1;
+			}
+			addattr32(n, 1024, IFLA_BR_STP_STATE, val);
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
-- 
2.4.3
