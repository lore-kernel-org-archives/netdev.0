From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH] net: core: Remove redundant call to 'nf_reset' in 'dev_forward_skb'
Date: Thu, 28 Mar 2013 11:13:26 +0200
Message-ID: <1364462006-5814-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org,
	Igor Michailov <rgohita@gmail.com>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:44242 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754983Ab3C1JOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 05:14:14 -0400
Received: by mail-ee0-f50.google.com with SMTP id e53so1371242eek.37
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 02:14:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'nf_reset' is called just prior calling 'netif_rx'.
No need to call it twice.

Reported-by: Igor Michailov <rgohita@gmail.com>
Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---
 net/core/dev.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 2db88df..071f398 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1624,7 +1624,6 @@ int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 	}
 
 	skb_orphan(skb);
-	nf_reset(skb);
 
 	if (unlikely(!is_skb_forwardable(dev, skb))) {
 		atomic_long_inc(&dev->rx_dropped);
-- 
1.7.9
