From: David Miller <davem@davemloft.net>
Subject: [PATCH 36/42] netlabel: Fix set-but-unused variables.
Date: Sun, 17 Apr 2011 17:34:16 -0700 (PDT)
Message-ID: <20110417.173416.13741109.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51093
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754116Ab1DRAev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:34:51 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id A519524C08B
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:34:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'type_str' is set but unused in netlbl_cipsov4_add().

Just kill it off.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netlabel/netlabel_cipso_v4.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/netlabel/netlabel_cipso_v4.c b/net/netlabel/netlabel_cipso_v4.c
index 5f14c84..bae5756 100644
--- a/net/netlabel/netlabel_cipso_v4.c
+++ b/net/netlabel/netlabel_cipso_v4.c
@@ -422,7 +422,6 @@ static int netlbl_cipsov4_add(struct sk_buff *skb, struct genl_info *info)
 
 {
 	int ret_val = -EINVAL;
-	const char *type_str = "(unknown)";
 	struct netlbl_audit audit_info;
 
 	if (!info->attrs[NLBL_CIPSOV4_A_DOI] ||
@@ -432,15 +431,12 @@ static int netlbl_cipsov4_add(struct sk_buff *skb, struct genl_info *info)
 	netlbl_netlink_auditinfo(skb, &audit_info);
 	switch (nla_get_u32(info->attrs[NLBL_CIPSOV4_A_MTYPE])) {
 	case CIPSO_V4_MAP_TRANS:
-		type_str = "trans";
 		ret_val = netlbl_cipsov4_add_std(info, &audit_info);
 		break;
 	case CIPSO_V4_MAP_PASS:
-		type_str = "pass";
 		ret_val = netlbl_cipsov4_add_pass(info, &audit_info);
 		break;
 	case CIPSO_V4_MAP_LOCAL:
-		type_str = "local";
 		ret_val = netlbl_cipsov4_add_local(info, &audit_info);
 		break;
 	}
-- 
1.7.4.3

