From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 3/4] batman-adv: increase default hop penalty
Date: Tue,  5 Aug 2014 09:36:27 +0200
Message-ID: <1407224188-28626-4-git-send-email-antonio@meshcoding.com>
References: <1407224188-28626-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:20716 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756471AbaHEHhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 03:37:20 -0400
In-Reply-To: <1407224188-28626-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon@open-mesh.com>

The default hop penalty is currently set to 15, which is applied like
that for multi interface devices (e.g. dual band APs). Single band
devices will still use an effective penalty of 30 (hop penalty + wifi
penalty).

After receiving reports of too long paths in mesh networks with dual
band APs which were fixed by increasing the hop penalty, we'd like to
suggest to increase that default value in the default setting as well.
We've evaluated that increase in a handful of medium sized mesh
networks (5-20 nodes) with single and dual band devices, with changes
for the better (shorter routes, higher throughput) or no change at all.

This patch changes the hop penalty to 30, which will give an effective
penalty of 60 on single band devices (hop penalty + wifi penalty).

Signed-off-by: Simon Wunderlich <simon@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/soft-interface.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index e0a7239..5467955 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -751,7 +751,7 @@ static int batadv_softif_init_late(struct net_device *dev)
 	atomic_set(&bat_priv->gw.bandwidth_down, 100);
 	atomic_set(&bat_priv->gw.bandwidth_up, 20);
 	atomic_set(&bat_priv->orig_interval, 1000);
-	atomic_set(&bat_priv->hop_penalty, 15);
+	atomic_set(&bat_priv->hop_penalty, 30);
 #ifdef CONFIG_BATMAN_ADV_DEBUG
 	atomic_set(&bat_priv->log_level, 0);
 #endif
-- 
1.8.5.5
