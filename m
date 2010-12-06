From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 1/6] tg3: Raise the jumbo frame BD flag
 threshold
Date: Mon, 6 Dec 2010 10:28:49 -0800
Message-ID: <1291660134-3801-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4202 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754409Ab0LFS3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Dec 2010 13:29:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current transmit routines set the jumbo frame BD flag too
aggressively.  This can reduce performance for common cases.  This patch
raises the jumbo flag threshold to 1518, up from 1500.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index afb79db..b8ae5e1 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -5761,7 +5761,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 	dma_unmap_addr_set(&tnapi->tx_buffers[entry], mapping, mapping);
 
 	if ((tp->tg3_flags3 & TG3_FLG3_USE_JUMBO_BDFLAG) &&
-	    !mss && skb->len > ETH_DATA_LEN)
+	    !mss && skb->len > VLAN_ETH_FRAME_LEN)
 		base_flags |= TXD_FLAG_JMB_PKT;
 
 	tg3_set_txd(tnapi, entry, mapping, len, base_flags,
@@ -5995,7 +5995,7 @@ static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 #endif
 
 	if ((tp->tg3_flags3 & TG3_FLG3_USE_JUMBO_BDFLAG) &&
-	    !mss && skb->len > ETH_DATA_LEN)
+	    !mss && skb->len > VLAN_ETH_FRAME_LEN)
 		base_flags |= TXD_FLAG_JMB_PKT;
 
 	len = skb_headlen(skb);
-- 
1.7.2.2


