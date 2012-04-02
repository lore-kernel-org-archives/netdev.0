From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 34/51] macvlan: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:24 -0400
Message-ID: <1333335521-1348-35-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46769 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754473Ab2DBDAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 23:00:07 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/macvlan.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index f975afd..b17fc90 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -773,7 +773,8 @@ static int macvlan_fill_info(struct sk_buff *skb,
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 
-	NLA_PUT_U32(skb, IFLA_MACVLAN_MODE, vlan->mode);
+	if (nla_put_u32(skb, IFLA_MACVLAN_MODE, vlan->mode))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
-- 
1.7.7.6
