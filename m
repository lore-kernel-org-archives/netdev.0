From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN 03/04]: Constify skb argument to vlan_get_tag()
Date: Tue,  5 Feb 2008 15:29:43 +0100 (MET)
Message-ID: <20080205142906.13543.98167.sendpatchset@localhost.localdomain>
References: <20080205142902.13543.88604.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59225 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752437AbYBEO3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 09:29:44 -0500
In-Reply-To: <20080205142902.13543.88604.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[VLAN]: Constify skb argument to vlan_get_tag()

Required by next patch to use it from the flow classifier.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 03faf81b8195be455c3c7592d76d712ea9d80b13
tree 9da377d2bd44421494a4c4d7cf6c705d199c26ce
parent 2e5915ef51e55135522e59e041bb176432857d82
author Patrick McHardy <kaber@trash.net> Tue, 05 Feb 2008 15:22:23 +0100
committer Patrick McHardy <kaber@trash.net> Tue, 05 Feb 2008 15:22:23 +0100

 include/linux/if_vlan.h |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 34f40ef..79504b2 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -327,7 +327,7 @@ static inline struct sk_buff *vlan_put_tag(struct sk_buff *skb, unsigned short t
  * 
  * Returns error if the skb is not of VLAN type
  */
-static inline int __vlan_get_tag(struct sk_buff *skb, unsigned short *tag)
+static inline int __vlan_get_tag(const struct sk_buff *skb, unsigned short *tag)
 {
 	struct vlan_ethhdr *veth = (struct vlan_ethhdr *)skb->data;
 
@@ -347,7 +347,8 @@ static inline int __vlan_get_tag(struct sk_buff *skb, unsigned short *tag)
  * 
  * Returns error if @skb->cb[] is not set correctly
  */
-static inline int __vlan_hwaccel_get_tag(struct sk_buff *skb, unsigned short *tag)
+static inline int __vlan_hwaccel_get_tag(const struct sk_buff *skb,
+					 unsigned short *tag)
 {
 	struct vlan_skb_tx_cookie *cookie;
 
@@ -370,7 +371,7 @@ static inline int __vlan_hwaccel_get_tag(struct sk_buff *skb, unsigned short *ta
  * 
  * Returns error if the skb is not VLAN tagged
  */
-static inline int vlan_get_tag(struct sk_buff *skb, unsigned short *tag)
+static inline int vlan_get_tag(const struct sk_buff *skb, unsigned short *tag)
 {
 	if (skb->dev->features & NETIF_F_HW_VLAN_TX) {
 		return __vlan_hwaccel_get_tag(skb, tag);
