From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] wan: remove some pointless conditionals before kfree_skb()
Date: Wed, 25 Feb 2009 18:22:41 +0800
Message-ID: <49A51BF1.2030503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Jan \"Yenya\" Kasprzak" <kas@fi.muni.cz>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49495 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757368AbZBYKXN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 05:23:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove some pointless conditionals before kfree_skb().

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 drivers/net/wan/cosa.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
index 0d7ba11..d276d72 100644
--- a/drivers/net/wan/cosa.c
+++ b/drivers/net/wan/cosa.c
@@ -731,8 +731,7 @@ static char *cosa_net_setup_rx(struct channel_data *chan, int size)
 	 * We can safely fall back to non-dma-able memory, because we have
 	 * the cosa->bouncebuf pre-allocated.
 	 */
-	if (chan->rx_skb)
-		kfree_skb(chan->rx_skb);
+	kfree_skb(chan->rx_skb);
 	chan->rx_skb = dev_alloc_skb(size);
 	if (chan->rx_skb == NULL) {
 		printk(KERN_NOTICE "%s: Memory squeeze, dropping packet\n",
-- 
1.5.3.8




