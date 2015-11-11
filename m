From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net 1/1] r8169: fix kasan reported skb use-after-free.
Date: Wed, 11 Nov 2015 23:35:18 +0100
Message-ID: <20151111223518.GA29672@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Dave Jones <davej@codemonkey.org.uk>,
	Eric Dumazet <edumazet@google.com>,
	Corinna Vinschen <vinschen@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:36954 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752480AbbKKWfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 17:35:31 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Reported-by: Dave Jones <davej@codemonkey.org.uk>
Fixes: d7d2d89d4b0af ("r8169: Add software counter for multicast packages")
Acked-by: Eric Dumazet <edumazet@google.com>
Acked-by: Corinna Vinschen <vinschen@redhat.com>
---

 Applies to davem's net as of c5a37883f42be712a989e54d5d6c0159b0e56599
 ("Merge branch 'akpm' (patches from Andrew)")

 4.2 needs it as well.

 drivers/net/ethernet/realtek/r8169.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index b4f2123..79ef799 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -7429,15 +7429,15 @@ process_pkt:
 
 			rtl8169_rx_vlan_tag(desc, skb);
 
+			if (skb->pkt_type == PACKET_MULTICAST)
+				dev->stats.multicast++;
+
 			napi_gro_receive(&tp->napi, skb);
 
 			u64_stats_update_begin(&tp->rx_stats.syncp);
 			tp->rx_stats.packets++;
 			tp->rx_stats.bytes += pkt_size;
 			u64_stats_update_end(&tp->rx_stats.syncp);
-
-			if (skb->pkt_type == PACKET_MULTICAST)
-				dev->stats.multicast++;
 		}
 release_descriptor:
 		desc->opts2 = 0;
-- 
2.5.0
