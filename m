From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 1/4] via-rhine: commit receive buffer address before descriptor status update.
Date: Mon,  6 Apr 2015 20:01:49 +0200
Message-ID: <87c90b27962c818239073d3a65341054922bd563.1428340371.git.romieu@fr.zoreil.com>
References: <cover.1428340371.git.romieu@fr.zoreil.com>
Cc: "Nix" <nix@esperi.org.uk>, "David S. Miller" <davem@davemloft.net>,
	rl@hellgate.ch, "Bjarke Istrup Pedersen" <gurligebis@gentoo.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50042 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752825AbbDFSCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 14:02:15 -0400
In-Reply-To: <cover.1428340371.git.romieu@fr.zoreil.com>
In-Reply-To: <cover.1428340371.git.romieu@fr.zoreil.com>
References: <cover.1428340371.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/via/via-rhine.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index a191afc..00fea3d 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -2063,6 +2063,7 @@ static int rhine_rx(struct net_device *dev, int limit)
 				break;
 			}
 			rp->rx_ring[entry].addr = cpu_to_le32(rp->rx_skbuff_dma[entry]);
+			wmb();
 		}
 		rp->rx_ring[entry].rx_status = cpu_to_le32(DescOwn);
 	}
-- 
2.1.0
