From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 1/6] via-rhine: commit receive buffer address before descriptor status update.
Date: Wed,  8 Apr 2015 00:40:48 +0200
Message-ID: <f2448365b2a8e43d3f708a7a23aa024fa55fb8db.1428445141.git.romieu@fr.zoreil.com>
References: <cover.1428445141.git.romieu@fr.zoreil.com>
Cc: "Nix" <nix@esperi.org.uk>, "David S. Miller" <davem@davemloft.net>,
	rl@hellgate.ch, "Bjarke Istrup Pedersen" <gurligebis@gentoo.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54409 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753264AbbDGWlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 18:41:07 -0400
In-Reply-To: <cover.1428445141.git.romieu@fr.zoreil.com>
In-Reply-To: <cover.1428445141.git.romieu@fr.zoreil.com>
References: <cover.1428445141.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/via/via-rhine.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index de28504..88b45c7 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -2075,6 +2075,7 @@ static int rhine_rx(struct net_device *dev, int limit)
 				break;
 			}
 			rp->rx_ring[entry].addr = cpu_to_le32(rp->rx_skbuff_dma[entry]);
+			dma_wmb();
 		}
 		rp->rx_ring[entry].rx_status = cpu_to_le32(DescOwn);
 	}
-- 
2.1.0
