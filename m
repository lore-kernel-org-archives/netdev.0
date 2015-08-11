From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 net-next 1/2] iplink: bridge: add ageing_time, stp_state and priority when showing attributes
Date: Tue, 11 Aug 2015 15:56:23 +0300
Message-ID: <1439297784-1962-2-git-send-email-razor@blackwall.org>
References: <1439297784-1962-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:35983 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965034AbbHKM4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 08:56:38 -0400
Received: by wicja10 with SMTP id ja10so74180649wic.1
        for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 05:56:37 -0700 (PDT)
In-Reply-To: <1439297784-1962-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

When showing bridge attributes, show also ageing_time, stp_state and
priority if available.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 ip/iplink_bridge.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index 297160c490fd..2a0bf6e147d0 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -109,6 +109,18 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_BR_MAX_AGE])
 		fprintf(f, "max_age %u ",
 			rta_getattr_u32(tb[IFLA_BR_MAX_AGE]));
+
+	if (tb[IFLA_BR_AGEING_TIME])
+		fprintf(f, "ageing_time %u ",
+			rta_getattr_u32(tb[IFLA_BR_AGEING_TIME]));
+
+	if (tb[IFLA_BR_STP_STATE])
+		fprintf(f, "stp_state %u ",
+			rta_getattr_u32(tb[IFLA_BR_STP_STATE]));
+
+	if (tb[IFLA_BR_PRIORITY])
+		fprintf(f, "priority %u ",
+			rta_getattr_u16(tb[IFLA_BR_PRIORITY]));
 }
 
 struct link_util bridge_link_util = {
-- 
2.4.3
