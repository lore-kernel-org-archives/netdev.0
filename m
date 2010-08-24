From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ethoc: get rid of ethoc_stats()
Date: Tue, 24 Aug 2010 17:22:11 +0200
Message-ID: <1282663331.2477.255.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:38902 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755175Ab0HXPWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 11:22:16 -0400
Received: by eyg5 with SMTP id 5so3424386eyg.19
        for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 08:22:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers can avoid implementing ndo_get_stats method if using netdevice
stats structure.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/ethoc.c |    6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index 6d653c4..c5a2fe0 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -806,11 +806,6 @@ static void ethoc_tx_timeout(struct net_device *dev)
 		ethoc_interrupt(dev->irq, dev);
 }
 
-static struct net_device_stats *ethoc_stats(struct net_device *dev)
-{
-	return &dev->stats;
-}
-
 static netdev_tx_t ethoc_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ethoc *priv = netdev_priv(dev);
@@ -863,7 +858,6 @@ static const struct net_device_ops ethoc_netdev_ops = {
 	.ndo_set_multicast_list = ethoc_set_multicast_list,
 	.ndo_change_mtu = ethoc_change_mtu,
 	.ndo_tx_timeout = ethoc_tx_timeout,
-	.ndo_get_stats = ethoc_stats,
 	.ndo_start_xmit = ethoc_start_xmit,
 };
 


