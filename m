From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 2/8] net: dsa: tag_brcm: Set output queue from skb queue mapping
Date: Wed, 30 Aug 2017 17:18:46 -0700
Message-ID: <1504138732-65383-3-git-send-email-f.fainelli@gmail.com>
References: <1504138732-65383-1-git-send-email-f.fainelli@gmail.com>
Cc: jiri@resnulli.us, jhs@mojatatu.com, davem@davemloft.net,
        xiyou.wangcong@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36591 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750814AbdHaA0t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 20:26:49 -0400
Received: by mail-wr0-f194.google.com with SMTP id 40so4798733wrv.3
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 17:26:48 -0700 (PDT)
In-Reply-To: <1504138732-65383-1-git-send-email-f.fainelli@gmail.com>
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
1.9.1
