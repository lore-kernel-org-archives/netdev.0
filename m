From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next 2/3] net/vlan: introduce __vlan_hwaccel_copy_tag()
 helper
Date: Wed,  4 Jan 2017 00:53:51 +0100 (CET)
Message-ID: <1ecd41d32565a178302ffe8ff1f6364804d60e49.1483487429.git.mirq-linux@rere.qmqm.pl>
References: <cover.1483487429.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:37050 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966836AbdACXxx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 18:53:53 -0500
In-Reply-To: <cover.1483487429.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 include/linux/if_vlan.h | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 38be9041cde4..75e839b84a63 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -393,6 +393,19 @@ static inline void __vlan_hwaccel_clear_tag(struct sk_buff *skb)
 	skb->vlan_tci = 0;
 }
 
+/**
+ * __vlan_hwaccel_copy_tag - copy hardware accelerated VLAN info from another skb
+ * @dst: skbuff to copy to
+ * @src: skbuff to copy from
+ *
+ * Copies VLAN information from @src to @dst (for branchless code)
+ */
+static inline void __vlan_hwaccel_copy_tag(struct sk_buff *dst, const struct sk_buff *src)
+{
+	dst->vlan_proto = src->vlan_proto;
+	dst->vlan_tci = src->vlan_tci;
+}
+
 /*
  * __vlan_hwaccel_push_inside - pushes vlan tag to the payload
  * @skb: skbuff to tag
-- 
2.11.0
