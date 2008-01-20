From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN 02/18]: Clean up vlan_hdr/vlan_ethhdr structs
Date: Sun, 20 Jan 2008 18:11:20 +0100 (MET)
Message-ID: <20080120171120.7980.15797.sendpatchset@localhost.localdomain>
References: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62335 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754013AbYATRLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 12:11:21 -0500
In-Reply-To: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[VLAN]: Clean up vlan_hdr/vlan_ethhdr structs

Fix 3 space indentation and some overly long lines by moving the comments
to a kdoc structure description.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit f12d203e024ce5e0c98a9e88f6fdf8517a665ce4
tree cebd9edb5b883aa901eaad4702ec428b2af87fc1
parent a8d2fc16ef0ffc7eb3502130f87994ba07129dae
author Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 16:24:52 +0100
committer Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 16:24:52 +0100

 include/linux/if_vlan.h |   33 +++++++++++++++++++++++----------
 1 files changed, 23 insertions(+), 10 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index a268051..a1b0066 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -34,12 +34,30 @@ struct hlist_node;
 #define VLAN_ETH_DATA_LEN	1500	/* Max. octets in payload	 */
 #define VLAN_ETH_FRAME_LEN	1518	/* Max. octets in frame sans FCS */
 
+/*
+ * 	struct vlan_hdr - vlan header
+ * 	@h_vlan_TCI: priority and VLAN ID
+ *	@h_vlan_encapsulated_proto: packet type ID or len
+ */
+struct vlan_hdr {
+	__be16	h_vlan_TCI;
+	__be16	h_vlan_encapsulated_proto;
+};
+
+/**
+ *	struct vlan_ethhdr - vlan ethernet header (ethhdr + vlan_hdr)
+ *	@h_dest: destination ethernet address
+ *	@h_source: source ethernet address
+ *	@h_vlan_proto: ethernet protocol (always 0x8100)
+ *	@h_vlan_TCI: priority and VLAN ID
+ *	@h_vlan_encapsulated_proto: packet type ID or len
+ */
 struct vlan_ethhdr {
-   unsigned char	h_dest[ETH_ALEN];	   /* destination eth addr	*/
-   unsigned char	h_source[ETH_ALEN];	   /* source ether addr	*/
-   __be16               h_vlan_proto;              /* Should always be 0x8100 */
-   __be16               h_vlan_TCI;                /* Encapsulates priority and VLAN ID */
-   __be16		h_vlan_encapsulated_proto; /* packet type ID field (or len) */
+	unsigned char	h_dest[ETH_ALEN];
+	unsigned char	h_source[ETH_ALEN];
+	__be16		h_vlan_proto;
+	__be16		h_vlan_TCI;
+	__be16		h_vlan_encapsulated_proto;
 };
 
 #include <linux/skbuff.h>
@@ -49,11 +67,6 @@ static inline struct vlan_ethhdr *vlan_eth_hdr(const struct sk_buff *skb)
 	return (struct vlan_ethhdr *)skb_mac_header(skb);
 }
 
-struct vlan_hdr {
-   __be16               h_vlan_TCI;                /* Encapsulates priority and VLAN ID */
-   __be16               h_vlan_encapsulated_proto; /* packet type ID field (or len) */
-};
-
 #define VLAN_VID_MASK	0xfff
 
 /* found in socket.c */
