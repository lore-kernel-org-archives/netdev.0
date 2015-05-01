From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #3 1/8] via-rhine: commit receive buffer address before descriptor status update.
Date: Fri,  1 May 2015 22:14:38 +0200
Message-ID: <ba587daa13881f47b02df778a534e0a39a5222ec.1430509434.git.romieu@fr.zoreil.com>
References: <cover.1430509434.git.romieu@fr.zoreil.com>
Cc: David Miller <davem@davemloft.net>, Nix <nix@esperi.org.uk>,
	Roger.Luethi.rl@hellgate.ch,
	Bjarke Istrup Pedersen <gurligebis@gentoo.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51003 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305AbbEAUPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 16:15:12 -0400
In-Reply-To: <cover.1430509434.git.romieu@fr.zoreil.com>
In-Reply-To: <cover.1430509434.git.romieu@fr.zoreil.com>
References: <cover.1430509434.git.romieu@fr.zoreil.com>
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
Ueimor
