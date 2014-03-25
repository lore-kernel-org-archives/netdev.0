From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 45/54] spider_net: Call dev_consume_skb_any instead of dev_kfree_skb.
Date: Mon, 24 Mar 2014 23:05:31 -0700
Message-ID: <1395727540-12148-45-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58461 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752141AbaCYGLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:11:31 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace dev_kfree_skb with dev_consume_skb_any in
spider_net_release_tx_chain which can be called in hard irq and other
contexts.

dev_consume_skb_any was choosen as it preserves the current
dev_kfree_skb semantics (dev_kfree_skb is consume_skb) and
is because it is correct most of the time as most packets
will have been successfully transmitted not dropeed.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/toshiba/spider_net.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/toshiba/spider_net.c b/drivers/net/ethernet/toshiba/spider_net.c
index 3f4a32e39d27..0282d0161859 100644
--- a/drivers/net/ethernet/toshiba/spider_net.c
+++ b/drivers/net/ethernet/toshiba/spider_net.c
@@ -860,7 +860,7 @@ spider_net_release_tx_chain(struct spider_net_card *card, int brutal)
 		if (skb) {
 			pci_unmap_single(card->pdev, buf_addr, skb->len,
 					PCI_DMA_TODEVICE);
-			dev_kfree_skb(skb);
+			dev_consume_skb_any(skb);
 		}
 	}
 	return 0;
-- 
1.7.10.4
