From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH v2 1/2] net: skbuff: Export __skb_vlan_pop
Date: Mon, 19 Sep 2016 19:11:09 +0300
Message-ID: <1474301470-17965-2-git-send-email-shmulik.ladkani@gmail.com>
References: <1474301470-17965-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34738 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751411AbcISQLd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 12:11:33 -0400
Received: by mail-wm0-f65.google.com with SMTP id l132so14574568wmf.1
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 09:11:32 -0700 (PDT)
In-Reply-To: <1474301470-17965-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This exports the functionality of extracting the tag from the payload,
without moving next vlan tag into hw accel tag.

Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---
 include/linux/skbuff.h | 1 +
 net/core/skbuff.c      | 7 +++++--
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4c5662f05b..000c5301b8 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3075,6 +3075,7 @@ bool skb_gso_validate_mtu(const struct sk_buff *skb, unsigned int mtu);
 struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features);
 struct sk_buff *skb_vlan_untag(struct sk_buff *skb);
 int skb_ensure_writable(struct sk_buff *skb, int write_len);
+int __skb_vlan_pop(struct sk_buff *skb, u16 *vlan_tci);
 int skb_vlan_pop(struct sk_buff *skb);
 int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci);
 struct sk_buff *pskb_extract(struct sk_buff *skb, int off, int to_copy,
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 1369faa182..c927ed4727 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4493,8 +4493,10 @@ int skb_ensure_writable(struct sk_buff *skb, int write_len)
 }
 EXPORT_SYMBOL(skb_ensure_writable);
 
-/* remove VLAN header from packet and update csum accordingly. */
-static int __skb_vlan_pop(struct sk_buff *skb, u16 *vlan_tci)
+/* remove VLAN header from packet and update csum accordingly.
+ * expects a non skb_vlan_tag_present skb with a vlan tag payload
+ */
+int __skb_vlan_pop(struct sk_buff *skb, u16 *vlan_tci)
 {
 	struct vlan_hdr *vhdr;
 	unsigned int offset = skb->data - skb_mac_header(skb);
@@ -4525,6 +4527,7 @@ pull:
 
 	return err;
 }
+EXPORT_SYMBOL(__skb_vlan_pop);
 
 int skb_vlan_pop(struct sk_buff *skb)
 {
-- 
2.7.4
