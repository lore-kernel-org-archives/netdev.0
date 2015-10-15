From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] bonding: support encapsulated ipv6 TSO
Date: Thu, 15 Oct 2015 09:22:11 -0700
Message-ID: <1444926131.25595.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33633 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753595AbbJOQWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 12:22:13 -0400
Received: by pabrc13 with SMTP id rc13so92085683pab.0
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 09:22:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

If using a sixtofour device on top of a bonding device,
skb segmentation of TCP traffic is done right before calling
bonding xmit, because bonding only enables TSO for IPv4.

This patch improves single flow performance by about 120 % on my hosts,
because segmentation is deferred right before calling slave xmit.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
drivers/net/bonding/bond_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 90f2615428c0..d0f23cd6e236 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1071,7 +1071,7 @@ static netdev_features_t bond_fix_features(struct net_device *dev,
 				 NETIF_F_HIGHDMA | NETIF_F_LRO)
 
 #define BOND_ENC_FEATURES	(NETIF_F_ALL_CSUM | NETIF_F_SG | NETIF_F_RXCSUM |\
-				 NETIF_F_TSO)
+				 NETIF_F_ALL_TSO)
 
 static void bond_compute_features(struct bonding *bond)
 {
