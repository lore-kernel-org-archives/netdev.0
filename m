From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH] smc911x: Fix unused variable warning.
Date: Wed, 21 Nov 2007 15:34:15 +0100
Message-ID: <E1IuqyC-0004ek-R2@nanv.dk>
To: netdev@vger.kernel.org, jeff@garzik.org, dustin@sensoria.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps.korsgaard.com ([64.79.194.204]:40924 "EHLO nanv.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755698AbXKUOya (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2007 09:54:30 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The smc911x_local pointer in smc911x_rcv is only used in the SMC_USE_DMA
case. Move it under the #ifdef so GCC doesn't generate a warning in the
non-DMA case.

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
---
 drivers/net/smc911x.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index dd18af0..69a78b3 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -428,7 +428,6 @@ static inline void smc911x_drop_pkt(struct net_device *dev)
  */
 static inline void	 smc911x_rcv(struct net_device *dev)
 {
-	struct smc911x_local *lp = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 	unsigned int pkt_len, status;
 	struct sk_buff *skb;
@@ -473,6 +472,7 @@ static inline void	 smc911x_rcv(struct net_device *dev)
 		skb_put(skb,pkt_len-4);
 #ifdef SMC_USE_DMA
 		{
+		struct smc911x_local *lp = netdev_priv(dev);
 		unsigned int fifo;
 		/* Lower the FIFO threshold if possible */
 		fifo = SMC_GET_FIFO_INT();
-- 
1.5.3.4

