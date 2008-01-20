From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN 14/18]: Turn __constant_htons into htons where possible
Date: Sun, 20 Jan 2008 18:11:36 +0100 (MET)
Message-ID: <20080120171136.7980.33228.sendpatchset@localhost.localdomain>
References: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62372 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754321AbYATRLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 12:11:38 -0500
In-Reply-To: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[VLAN]: Turn __constant_htons into htons where possible

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 40048c4ab8a08ea7f0e2df52f0ec02a8010d2a0e
tree bf0486c7fd56dae810144d1695281fb39ce402e7
parent 84ea6a8ff0745f63e25d2d17664fd8c56448f985
author Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 17:37:31 +0100
committer Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 17:37:31 +0100

 include/linux/if_vlan.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 82c2352..34f40ef 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -271,12 +271,12 @@ static inline struct sk_buff *__vlan_put_tag(struct sk_buff *skb, unsigned short
 	memmove(skb->data, skb->data + VLAN_HLEN, 2 * VLAN_ETH_ALEN);
 
 	/* first, the ethernet type */
-	veth->h_vlan_proto = __constant_htons(ETH_P_8021Q);
+	veth->h_vlan_proto = htons(ETH_P_8021Q);
 
 	/* now, the tag */
 	veth->h_vlan_TCI = htons(tag);
 
-	skb->protocol = __constant_htons(ETH_P_8021Q);
+	skb->protocol = htons(ETH_P_8021Q);
 	skb->mac_header -= VLAN_HLEN;
 	skb->network_header -= VLAN_HLEN;
 
@@ -331,7 +331,7 @@ static inline int __vlan_get_tag(struct sk_buff *skb, unsigned short *tag)
 {
 	struct vlan_ethhdr *veth = (struct vlan_ethhdr *)skb->data;
 
-	if (veth->h_vlan_proto != __constant_htons(ETH_P_8021Q)) {
+	if (veth->h_vlan_proto != htons(ETH_P_8021Q)) {
 		return -EINVAL;
 	}
 
