From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: nlmon: flag nlmon devs with LLTX/SG
Date: Thu, 27 Mar 2014 16:34:59 +0100
Message-ID: <1395934499-29092-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35577 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753943AbaC0PfC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2014 11:35:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As in xmit path we merely update statistics and free the skb, we
can mark the device with LLTX feature, so that upper layers can
avoid taking the single txq lock on xmit. While at it, also add
missing NETIF_F_SG.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 drivers/net/nlmon.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/nlmon.c b/drivers/net/nlmon.c
index 6929b03..34924df 100644
--- a/drivers/net/nlmon.c
+++ b/drivers/net/nlmon.c
@@ -136,7 +136,8 @@ static void nlmon_setup(struct net_device *dev)
 	dev->ethtool_ops = &nlmon_ethtool_ops;
 	dev->destructor	= free_netdev;
 
-	dev->features = NETIF_F_FRAGLIST | NETIF_F_HIGHDMA;
+	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST |
+			NETIF_F_HIGHDMA | NETIF_F_LLTX;
 	dev->flags = IFF_NOARP;
 
 	/* That's rather a softlimit here, which, of course,
-- 
1.7.11.7
