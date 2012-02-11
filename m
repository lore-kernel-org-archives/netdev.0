From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/7] skbuff: Move rxhash and vlan_tci to consolidate holes in sk_buff
Date: Fri, 10 Feb 2012 16:08:24 -0800
Message-ID: <1328918904-11511-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328918904-11511-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:48299 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761189Ab2BKAIc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Feb 2012 19:08:32 -0500
In-Reply-To: <1328918904-11511-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change helps to reduce the overall size of the sk_buff by moving
rxhash and vlan_tci so that the u16 values and u8 bitfields can be better
combined to create only one hole instead of multiple.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 include/linux/skbuff.h |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 50db9b0..2b7317f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -438,6 +438,11 @@ struct sk_buff {
 #endif
 
 	int			skb_iif;
+
+	__u32			rxhash;
+
+	__u16			vlan_tci;
+
 #ifdef CONFIG_NET_SCHED
 	__u16			tc_index;	/* traffic control index */
 #ifdef CONFIG_NET_CLS_ACT
@@ -445,8 +450,6 @@ struct sk_buff {
 #endif
 #endif
 
-	__u32			rxhash;
-
 	__u16			queue_mapping;
 	kmemcheck_bitfield_begin(flags2);
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
@@ -470,8 +473,6 @@ struct sk_buff {
 		__u32		dropcount;
 	};
 
-	__u16			vlan_tci;
-
 	sk_buff_data_t		transport_header;
 	sk_buff_data_t		network_header;
 	sk_buff_data_t		mac_header;
-- 
1.7.7.6
