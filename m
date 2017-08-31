From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 7/8] net: dsa: tag_brcm: Indicate to master netdevice port + queue
Date: Wed, 30 Aug 2017 17:18:51 -0700
Message-ID: <1504138732-65383-8-git-send-email-f.fainelli@gmail.com>
References: <1504138732-65383-1-git-send-email-f.fainelli@gmail.com>
Cc: jiri@resnulli.us, jhs@mojatatu.com, davem@davemloft.net,
        xiyou.wangcong@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36644 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750814AbdHaA1N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 20:27:13 -0400
Received: by mail-wr0-f194.google.com with SMTP id 40so4799013wrv.3
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 17:27:13 -0700 (PDT)
In-Reply-To: <1504138732-65383-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to tell the DSA master network device doing the actual
transmission what the desired switch port and queue number is for it to
resolve that to the internal transmit queue it is mapped to.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/tag_brcm.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index dbb016434ace..19a617b09b3c 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -86,6 +86,11 @@ static struct sk_buff *brcm_tag_xmit(struct sk_buff *skb, struct net_device *dev
 		brcm_tag[2] = BRCM_IG_DSTMAP2_MASK;
 	brcm_tag[3] = (1 << p->dp->index) & BRCM_IG_DSTMAP1_MASK;
 
+	/* Now tell the master network device about the desired output queue
+	 * as well
+	 */
+	skb_set_queue_mapping(skb, p->dp->index << dev->num_tx_queues | queue);
+
 	return skb;
 }
 
-- 
1.9.1
