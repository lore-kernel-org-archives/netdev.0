From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 2/4] rtnl/do_setlink(): set modified when IFLA_LINKMODE is updated
Date: Mon,  1 Sep 2014 16:07:27 +0200
Message-ID: <1409580449-4562-3-git-send-email-nicolas.dichtel@6wind.com>
References: <1409580449-4562-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:36485 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754149AbaIAOQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 10:16:51 -0400
In-Reply-To: <1409580449-4562-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The only effect of this patch is to print a warning if IFLA_LINKMODE is updated
and a following change fails.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/core/rtnetlink.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 5bbaf74bf457..2bd9fb15b987 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1624,8 +1624,12 @@ static int do_setlink(const struct sk_buff *skb,
 		set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
 
 	if (tb[IFLA_LINKMODE]) {
+		unsigned char value = nla_get_u8(tb[IFLA_LINKMODE]);
+
 		write_lock_bh(&dev_base_lock);
-		dev->link_mode = nla_get_u8(tb[IFLA_LINKMODE]);
+		if (dev->link_mode ^ value)
+			modified = 1;
+		dev->link_mode = value;
 		write_unlock_bh(&dev_base_lock);
 	}
 
-- 
1.9.0
