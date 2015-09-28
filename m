From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH bluetooth-next 2/4] nl802154: use nla_get_le64 for get extended addr
Date: Mon, 28 Sep 2015 09:00:24 +0200
Message-ID: <1443423626-3609-3-git-send-email-alex.aring@gmail.com>
References: <1443423626-3609-1-git-send-email-alex.aring@gmail.com>
Cc: kernel@pengutronix.de, netdev@vger.kernel.org,
	phoebe.buckheister@itwm.fraunhofer.de,
	Alexander Aring <alex.aring@gmail.com>
To: linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:35440 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755392AbbI1HCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 03:02:17 -0400
In-Reply-To: <1443423626-3609-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch uses the nla_get_le64 function instead of doing a force
converting to le64.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 net/ieee802154/nl802154.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/ieee802154/nl802154.c b/net/ieee802154/nl802154.c
index 3f89c0a..51110a6 100644
--- a/net/ieee802154/nl802154.c
+++ b/net/ieee802154/nl802154.c
@@ -753,10 +753,8 @@ static int nl802154_new_interface(struct sk_buff *skb, struct genl_info *info)
 			return -EINVAL;
 	}
 
-	/* TODO add nla_get_le64 to netlink */
 	if (info->attrs[NL802154_ATTR_EXTENDED_ADDR])
-		extended_addr = (__force __le64)nla_get_u64(
-				info->attrs[NL802154_ATTR_EXTENDED_ADDR]);
+		extended_addr = nla_get_le64(info->attrs[NL802154_ATTR_EXTENDED_ADDR]);
 
 	if (!rdev->ops->add_virtual_intf)
 		return -EOPNOTSUPP;
-- 
2.5.3
