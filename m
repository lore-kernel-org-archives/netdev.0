From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 RESEND 2/4] net: dsa: tag_brcm: Set output queue from skb queue mapping
Date: Sun,  3 Sep 2017 20:27:01 -0700
Message-ID: <20170904032703.4593-3-f.fainelli@gmail.com>
References: <20170904032703.4593-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:33138 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753124AbdIDD1N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 23:27:13 -0400
Received: by mail-oi0-f68.google.com with SMTP id l185so608338oib.0
        for <netdev@vger.kernel.org>; Sun, 03 Sep 2017 20:27:12 -0700 (PDT)
In-Reply-To: <20170904032703.4593-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We originally used skb->priority but that was not quite correct as this
bitfield needs to contain the egress switch queue we intend to send this
SKB to.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/tag_brcm.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index de74c3f77818..dbb016434ace 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -62,6 +62,7 @@
 static struct sk_buff *brcm_tag_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
+	u16 queue = skb_get_queue_mapping(skb);
 	u8 *brcm_tag;
 
 	if (skb_cow_head(skb, BRCM_TAG_LEN) < 0)
@@ -78,7 +79,7 @@ static struct sk_buff *brcm_tag_xmit(struct sk_buff *skb, struct net_device *dev
 	 * deprecated
 	 */
 	brcm_tag[0] = (1 << BRCM_OPCODE_SHIFT) |
-			((skb->priority << BRCM_IG_TC_SHIFT) & BRCM_IG_TC_MASK);
+		       ((queue & BRCM_IG_TC_MASK) << BRCM_IG_TC_SHIFT);
 	brcm_tag[1] = 0;
 	brcm_tag[2] = 0;
 	if (p->dp->index == 8)
-- 
2.11.0
