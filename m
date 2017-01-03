From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next 3/3] net/vlan: include the shift in
 skb_vlan_tag_get_prio()
Date: Wed,  4 Jan 2017 00:53:51 +0100 (CET)
Message-ID: <3fa0ecaaa0ac711a17c1e459a9dbf3846cab605c.1483487429.git.mirq-linux@rere.qmqm.pl>
References: <cover.1483487429.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:37056 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966835AbdACXxx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 18:53:53 -0500
In-Reply-To: <cover.1483487429.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 include/linux/if_vlan.h   | 2 +-
 net/core/flow_dissector.c | 3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 75e839b84a63..bc4e8c2533da 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -81,7 +81,7 @@ static inline bool is_vlan_dev(const struct net_device *dev)
 #define skb_vlan_tag_present(__skb)	((__skb)->vlan_tci & VLAN_TAG_PRESENT)
 #define skb_vlan_tag_get(__skb)		((__skb)->vlan_tci & ~VLAN_TAG_PRESENT)
 #define skb_vlan_tag_get_id(__skb)	((__skb)->vlan_tci & VLAN_VID_MASK)
-#define skb_vlan_tag_get_prio(__skb)	((__skb)->vlan_tci & VLAN_PRIO_MASK)
+#define skb_vlan_tag_get_prio(__skb)	(((__skb)->vlan_tci & VLAN_PRIO_MASK) >> VLAN_PRIO_SHIFT)
 
 /**
  *	struct vlan_pcpu_stats - VLAN percpu rx/tx stats
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index d6447dc10371..d93768ac39a1 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -295,8 +295,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 
 			if (vlan_tag_present) {
 				key_vlan->vlan_id = skb_vlan_tag_get_id(skb);
-				key_vlan->vlan_priority =
-					(skb_vlan_tag_get_prio(skb) >> VLAN_PRIO_SHIFT);
+				key_vlan->vlan_priority = skb_vlan_tag_get_prio(skb);
 			} else {
 				key_vlan->vlan_id = ntohs(vlan->h_vlan_TCI) &
 					VLAN_VID_MASK;
-- 
2.11.0
