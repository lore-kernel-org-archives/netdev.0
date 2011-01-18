From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH] net offloading: Do not mask out NETIF_F_HW_VLAN_TX for vlan.
Date: Mon, 17 Jan 2011 22:46:00 -0800
Message-ID: <1295333160-1667-1-git-send-email-jesse@nicira.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:45117 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750984Ab1ARGqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 01:46:07 -0500
Received: by qwa26 with SMTP id 26so5557203qwa.19
        for <netdev@vger.kernel.org>; Mon, 17 Jan 2011 22:46:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In netif_skb_features() we return only the features that are valid for vlans
if we have a vlan packet.  However, we should not mask out NETIF_F_HW_VLAN_TX
since it enables transmission of vlan tags and is obviously valid.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/core/dev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 83507c2..4c58d11 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2023,13 +2023,13 @@ int netif_skb_features(struct sk_buff *skb)
 		return harmonize_features(skb, protocol, features);
 	}
 
-	features &= skb->dev->vlan_features;
+	features &= (skb->dev->vlan_features | NETIF_F_HW_VLAN_TX);
 
 	if (protocol != htons(ETH_P_8021Q)) {
 		return harmonize_features(skb, protocol, features);
 	} else {
 		features &= NETIF_F_SG | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST |
-				NETIF_F_GEN_CSUM;
+				NETIF_F_GEN_CSUM | NETIF_F_HW_VLAN_TX;
 		return harmonize_features(skb, protocol, features);
 	}
 }
-- 
1.7.1

