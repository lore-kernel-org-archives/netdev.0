From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V3 06/10] dnet: enable transmit time stamping.
Date: Sun, 12 Jun 2011 14:19:03 +0200
Message-ID: <fd0436f8fb58a20ee88df33eb7c176be5a449202.1307880494.git.richard.cochran@omicron.at>
References: <cover.1307880494.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>, Ilya Yanok <yanok@emcraft.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:46427 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753514Ab1FLMT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 08:19:27 -0400
Received: by mail-bw0-f46.google.com with SMTP id 15so3125460bwz.19
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2011 05:19:27 -0700 (PDT)
In-Reply-To: <cover.1307880494.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1307880494.git.richard.cochran@omicron.at>
References: <cover.1307880494.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables software (and phy device) transmit time stamping
in the "Dave ethernet interface." Compile tested only.

Cc: Ilya Yanok <yanok@emcraft.com>
Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/dnet.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/dnet.c b/drivers/net/dnet.c
index 8318ea0..c36763c 100644
--- a/drivers/net/dnet.c
+++ b/drivers/net/dnet.c
@@ -587,6 +587,8 @@ static netdev_tx_t dnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		dnet_writel(bp, irq_enable, INTR_ENB);
 	}
 
+	skb_tx_timestamp(skb);
+
 	/* free the buffer */
 	dev_kfree_skb(skb);
 
-- 
1.7.0.4

