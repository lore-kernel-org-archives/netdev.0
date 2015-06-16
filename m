From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 net-next 3/3] iplink_bridge: add support for priority
Date: Tue, 16 Jun 2015 13:38:49 +0300
Message-ID: <1434451129-3241-4-git-send-email-razor@blackwall.org>
References: <1434451129-3241-1-git-send-email-razor@blackwall.org>
Cc: stephen@networkplumber.org, joerg@higgsboson.tk,
	davem@davemloft.net, Nikolay Aleksandrov <razor@blackwall.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:34530 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756887AbbFPKxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 06:53:20 -0400
Received: by wicnd19 with SMTP id nd19so49454039wic.1
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2015 03:53:19 -0700 (PDT)
In-Reply-To: <1434451129-3241-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support to set bridge stp priority via IFLA_BR_PRIORITY.

Signed-off-by: Nikolay Aleksandrov <razor@blackwall.org>
---
 ip/iplink_bridge.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index 79b9e049ff92..297160c490fd 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -25,6 +25,7 @@ static void explain(void)
 		"                  [ max_age MAX_AGE ]\n"
 		"                  [ ageing_time AGEING_TIME ]\n"
 		"                  [ stp_state STP_STATE ]\n"
+		"                  [ priority PRIORITY ]\n"
 	);
 }
 
@@ -69,6 +70,15 @@ static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 				return -1;
 			}
 			addattr32(n, 1024, IFLA_BR_STP_STATE, val);
+		} else if (matches(*argv, "priority") == 0) {
+			__u16 prio;
+
+			NEXT_ARG();
+			if (get_u16(&prio, *argv, 0)) {
+				invarg("invalid priority", *argv);
+				return -1;
+			}
+			addattr16(n, 1024, IFLA_BR_PRIORITY, prio);
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
-- 
2.4.3
