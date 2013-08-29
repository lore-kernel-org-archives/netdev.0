From: Lutz Jaenicke <ljaenicke@innominate.com>
Subject: [iproute2] macvlan: fix typo in macvlan_print_opt()
Date: Thu, 29 Aug 2013 09:50:28 +0200
Message-ID: <1377762628-28843-1-git-send-email-ljaenicke@innominate.com>
Cc: Lutz Jaenicke <ljaenicke@innominate.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from home.innominate.com ([77.245.32.75]:57808 "EHLO
	home.innominate.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755966Ab3H2Huo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 03:50:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mode information is contained in IFLA_MACVLAN_MODE instead
of IFLA_VLAN_ID (both evaluating to "1" in their enums).

Signed-off-by: Lutz Jaenicke <ljaenicke@innominate.com>
---
 ip/iplink_macvlan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iplink_macvlan.c b/ip/iplink_macvlan.c
index 5b4b868..ec51106 100644
--- a/ip/iplink_macvlan.c
+++ b/ip/iplink_macvlan.c
@@ -79,7 +79,7 @@ static void macvlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[]
 	    RTA_PAYLOAD(tb[IFLA_MACVLAN_MODE]) < sizeof(__u32))
 		return;
 
-	mode = rta_getattr_u32(tb[IFLA_VLAN_ID]);
+	mode = rta_getattr_u32(tb[IFLA_MACVLAN_MODE]);
 	fprintf(f, " mode %s ",
 		  mode == MACVLAN_MODE_PRIVATE ? "private"
 		: mode == MACVLAN_MODE_VEPA    ? "vepa"
-- 
1.7.10.4
