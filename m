From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] vlan: Use __vlan_hwaccel_put_tag() in rx
Date: Fri, 13 Nov 2009 17:33:11 +0100
Message-ID: <4AFD8A47.1070908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36301 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756339AbZKMQdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 11:33:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 05423b241311c9380 (vlan: allow null VLAN ID to be used)
forgot to update __vlan_hwaccel_rx() & vlan_gro_common()

We need to set VLAN_TAG_PRESENT flag in skb->vlan_tci

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/8021q/vlan_core.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 8d5ca2a..971d375 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -14,7 +14,7 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 	if (skb_bond_should_drop(skb))
 		goto drop;
 
-	skb->vlan_tci = vlan_tci;
+	__vlan_hwaccel_put_tag(skb, vlan_tci);
 	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
 
 	if (!skb->dev)
@@ -83,7 +83,7 @@ vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
 	if (skb_bond_should_drop(skb))
 		goto drop;
 
-	skb->vlan_tci = vlan_tci;
+	__vlan_hwaccel_put_tag(skb, vlan_tci);
 	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
 
 	if (!skb->dev)
