From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next v2 01/27] net/vlan: introduce __vlan_hwaccel_clear_tag()
 helper
Date: Tue,  3 Jan 2017 21:52:33 +0100 (CET)
Message-ID: <deadd7b0b65b538196f74876384f7b9bd12a0804.1483475202.git.mirq-linux@rere.qmqm.pl>
References: <cover.1483475202.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:34678 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935882AbdACUwh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 15:52:37 -0500
In-Reply-To: <cover.1483475202.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 include/linux/if_vlan.h | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 8d5fcd6284ce..38be9041cde4 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -382,6 +382,17 @@ static inline struct sk_buff *vlan_insert_tag_set_proto(struct sk_buff *skb,
 	return skb;
 }
 
+/**
+ * __vlan_hwaccel_clear_tag - clear hardware accelerated VLAN info
+ * @skb: skbuff to clear
+ *
+ * Clears the VLAN information from @skb
+ */
+static inline void __vlan_hwaccel_clear_tag(struct sk_buff *skb)
+{
+	skb->vlan_tci = 0;
+}
+
 /*
  * __vlan_hwaccel_push_inside - pushes vlan tag to the payload
  * @skb: skbuff to tag
@@ -396,7 +407,7 @@ static inline struct sk_buff *__vlan_hwaccel_push_inside(struct sk_buff *skb)
 	skb = vlan_insert_tag_set_proto(skb, skb->vlan_proto,
 					skb_vlan_tag_get(skb));
 	if (likely(skb))
-		skb->vlan_tci = 0;
+		__vlan_hwaccel_clear_tag(skb);
 	return skb;
 }
 
-- 
2.11.0
