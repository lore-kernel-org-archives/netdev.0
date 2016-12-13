From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next 02/27] net/vlan: introduce __vlan_hwaccel_copy_tag()
 helper
Date: Tue, 13 Dec 2016 01:12:32 +0100 (CET)
Message-ID: <220781de31536dd0df214302a74eb454676b0496.1481586602.git.mirq-linux@rere.qmqm.pl>
References: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Patrick McHardy <kaber@trash.net> (maintainer:VLAN (802.1Q))
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:50194 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753232AbcLMAMg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 19:12:36 -0500
In-Reply-To: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 include/linux/if_vlan.h | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 38be904..75e839b 100644
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
2.10.2
