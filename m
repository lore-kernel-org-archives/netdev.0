From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 1/4] rtnl/do_setlink(): set modified when IFLA_TXQLEN is updated
Date: Mon,  1 Sep 2014 16:07:26 +0200
Message-ID: <1409580449-4562-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1409580449-4562-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:36489 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754150AbaIAOQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 10:16:51 -0400
In-Reply-To: <1409580449-4562-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The only effect of this patch is to print a warning if IFLA_TXQLEN is updated
and a following change fails.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/core/rtnetlink.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index f0493e3b7471..5bbaf74bf457 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1611,8 +1611,14 @@ static int do_setlink(const struct sk_buff *skb,
 		modified = 1;
 	}
 
-	if (tb[IFLA_TXQLEN])
-		dev->tx_queue_len = nla_get_u32(tb[IFLA_TXQLEN]);
+	if (tb[IFLA_TXQLEN]) {
+		unsigned long value = nla_get_u32(tb[IFLA_TXQLEN]);
+
+		if (dev->tx_queue_len ^ value)
+			modified = 1;
+
+		dev->tx_queue_len = value;
+	}
 
 	if (tb[IFLA_OPERSTATE])
 		set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
-- 
1.9.0
