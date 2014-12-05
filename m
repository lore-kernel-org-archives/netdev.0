From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: [PATCH net-next 2/3] netlink: IFLA_PHYS_SWITCH_ID to IFLA_PHYS_PARENT_ID
Date: Fri,  5 Dec 2014 13:02:16 -0500
Message-ID: <1417802537-20020-2-git-send-email-gospo@cumulusnetworks.com>
References: <1417802537-20020-1-git-send-email-gospo@cumulusnetworks.com>
Cc: sfeldma@gmail.com, jpirko@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:48578 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848AbaLESCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 13:02:34 -0500
In-Reply-To: <1417802537-20020-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There has been much discussion about proper nomenclature to use for this
and I would prefer parent rather than calling every forwarding element a
switch.

Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h | 2 +-
 net/core/rtnetlink.c         | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index f7d0d2d..3d8edd8 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -145,7 +145,7 @@ enum {
 	IFLA_CARRIER,
 	IFLA_PHYS_PORT_ID,
 	IFLA_CARRIER_CHANGES,
-	IFLA_PHYS_SWITCH_ID,
+	IFLA_PHYS_PARENT_ID,
 	__IFLA_MAX
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 61cb7e7..1fe0a16 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -982,7 +982,7 @@ static int rtnl_phys_switch_id_fill(struct sk_buff *skb, struct net_device *dev)
 		return err;
 	}
 
-	if (nla_put(skb, IFLA_PHYS_SWITCH_ID, psid.id_len, psid.id))
+	if (nla_put(skb, IFLA_PHYS_PARENT_ID, psid.id_len, psid.id))
 		return -EMSGSIZE;
 
 	return 0;
@@ -1222,7 +1222,7 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_NUM_RX_QUEUES]	= { .type = NLA_U32 },
 	[IFLA_PHYS_PORT_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_ITEM_ID_LEN },
 	[IFLA_CARRIER_CHANGES]	= { .type = NLA_U32 },  /* ignored */
-	[IFLA_PHYS_SWITCH_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_ITEM_ID_LEN },
+	[IFLA_PHYS_PARENT_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_ITEM_ID_LEN },
 };
 
 static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
-- 
1.9.3
