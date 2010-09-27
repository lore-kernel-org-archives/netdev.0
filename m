From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] vlan: use this_cpu_ptr() in vlan_skb_recv()
Date: Mon, 27 Sep 2010 10:47:09 +0200
Message-ID: <1285577229.10965.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40718 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754586Ab0I0IrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 04:47:14 -0400
Received: by fxm3 with SMTP id 3so1642663fxm.19
        for <netdev@vger.kernel.org>; Mon, 27 Sep 2010 01:47:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/8021q/vlan_dev.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 94a1fed..f6fbcc0 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -177,8 +177,8 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	} else {
 		skb->dev = vlan_dev;
 
-		rx_stats = per_cpu_ptr(vlan_dev_info(skb->dev)->vlan_rx_stats,
-					smp_processor_id());
+		rx_stats = this_cpu_ptr(vlan_dev_info(skb->dev)->vlan_rx_stats);
+
 		u64_stats_update_begin(&rx_stats->syncp);
 		rx_stats->rx_packets++;
 		rx_stats->rx_bytes += skb->len;


