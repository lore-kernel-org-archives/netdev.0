From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net 1/6] mpls: Fix config check for mpls.
Date: Tue, 23 Dec 2014 16:20:11 -0800
Message-ID: <1419380411-1545-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog124.obsmtp.com ([74.125.149.151]:39403 "HELO
	na3sys009aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756656AbaLXAUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2014 19:20:14 -0500
Received: by mail-pd0-f175.google.com with SMTP id g10so8774544pdj.6
        for <netdev@vger.kernel.org>; Tue, 23 Dec 2014 16:20:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes MPLS GSO for case when mpls is compiled as kernel module.

Fixes: 0d89d2035f ("MPLS: Add limited GSO support").
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/core/dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index f411c28..fa621fd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2522,7 +2522,7 @@ static int illegal_highdma(struct net_device *dev, struct sk_buff *skb)
 /* If MPLS offload request, verify we are testing hardware MPLS features
  * instead of standard features for the netdev.
  */
-#ifdef CONFIG_NET_MPLS_GSO
+#if IS_ENABLED(CONFIG_NET_MPLS_GSO)
 static netdev_features_t net_mpls_features(struct sk_buff *skb,
 					   netdev_features_t features,
 					   __be16 type)
-- 
1.7.1
