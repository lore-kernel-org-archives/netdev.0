From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 6/10][IPMR]: Ipip tunnel uses on-device stats.
Date: Tue, 20 May 2008 20:38:47 +0400
Message-ID: <4832FE97.9000101@openvz.org>
References: <4832FBD7.7040209@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:45640 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758384AbYETQlQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 12:41:16 -0400
In-Reply-To: <4832FBD7.7040209@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ipmr uses ipip tunnels for its purposes and updates the
tunnels' stats, but the ipip driver is already switched to
use on-device ones.

Actually, this is a part of the patch #4 from this set.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/ipmr.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 11700a4..65f1200 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1230,8 +1230,8 @@ static void ipmr_queue_xmit(struct sk_buff *skb, struct mfc_cache *c, int vifi)
 	if (vif->flags & VIFF_TUNNEL) {
 		ip_encap(skb, vif->local, vif->remote);
 		/* FIXME: extra output firewall step used to be here. --RR */
-		((struct ip_tunnel *)netdev_priv(vif->dev))->stat.tx_packets++;
-		((struct ip_tunnel *)netdev_priv(vif->dev))->stat.tx_bytes+=skb->len;
+		vif->dev->stats.tx_packets++;
+		vif->dev->stats.tx_bytes += skb->len;
 	}
 
 	IPCB(skb)->flags |= IPSKB_FORWARDED;
-- 
1.5.3.4

