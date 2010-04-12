From: Chris Leech <christopher.leech@intel.com>
Subject: [PATCH] vlan: remove receive checks for bonding
Date: Mon, 12 Apr 2010 15:17:23 -0700
Message-ID: <20100412221723.8068.75393.stgit@localhost6.localdomain6>
References: <20100412221645.8068.71073.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net
To: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:18331 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754257Ab0DLWRX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 18:17:23 -0400
In-Reply-To: <20100412221645.8068.71073.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The checks in the hardware accelerated receive path are not up to date
with what's in netif_receive_skb, which will get called anyway if the
frame is not dropped in the vlan code.

Signed-off-by: Chris Leech <christopher.leech@intel.com>
---

 net/8021q/vlan_core.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index c584a0a..7576f9c 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -11,9 +11,6 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 	if (netpoll_rx(skb))
 		return NET_RX_DROP;
 
-	if (skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
-		goto drop;
-
 	skb->skb_iif = skb->dev->ifindex;
 	__vlan_hwaccel_put_tag(skb, vlan_tci);
 	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
@@ -83,9 +80,6 @@ vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
 {
 	struct sk_buff *p;
 
-	if (skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
-		goto drop;
-
 	skb->skb_iif = skb->dev->ifindex;
 	__vlan_hwaccel_put_tag(skb, vlan_tci);
 	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);

