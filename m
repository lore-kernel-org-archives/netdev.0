From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH] batman-adv: set the TAG flag for the vid passed to BLA
Date: Wed, 18 Sep 2013 08:27:38 +0200
Message-ID: <1379485658-2317-2-git-send-email-ordex@autistici.org>
References: <1379485658-2317-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Antonio Quartulli <antonio@open-mesh.org>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:27569 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751645Ab3IRG15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 02:27:57 -0400
In-Reply-To: <1379485658-2317-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

When receiving or sending a packet a packet on a VLAN, the
vid has to be marked with the TAG flag in order to make any
component in batman-adv understand that the packet is coming
from a really tagged network.

This fix the Bridge Loop Avoidance behaviour which was not
able to send announces over VLAN interfaces.

Introduced by 0b1da1765fdb00ca5d53bc95c9abc70dfc9aae5b
("batman-adv: change VID semantic in the BLA code")

Signed-off-by: Antonio Quartulli <antonio@open-mesh.org>
Acked-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/soft-interface.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 4493913..813db4e 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -168,6 +168,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
 	case ETH_P_8021Q:
 		vhdr = (struct vlan_ethhdr *)skb->data;
 		vid = ntohs(vhdr->h_vlan_TCI) & VLAN_VID_MASK;
+		vid |= BATADV_VLAN_HAS_TAG;
 
 		if (vhdr->h_vlan_encapsulated_proto != ethertype)
 			break;
@@ -331,6 +332,7 @@ void batadv_interface_rx(struct net_device *soft_iface,
 	case ETH_P_8021Q:
 		vhdr = (struct vlan_ethhdr *)skb->data;
 		vid = ntohs(vhdr->h_vlan_TCI) & VLAN_VID_MASK;
+		vid |= BATADV_VLAN_HAS_TAG;
 
 		if (vhdr->h_vlan_encapsulated_proto != ethertype)
 			break;
-- 
1.8.1.5
