From: Pradeep A Dalvi <netdev@pradeepdalvi.com>
Subject: [PATCH net-next] mace: Fix build for mace due to netdev_alloc_skb
Date: Wed,  8 Feb 2012 15:33:15 +0530
Message-ID: <1328695395-2565-1-git-send-email-netdev@pradeepdalvi.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Pradeep A Dalvi <netdev@pradeepdalvi.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:60171 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503Ab2BHKEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 05:04:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refs:
1. pmac32_defconfig
http://kisskb.ellerman.id.au/kisskb/buildresult/5583746/
2. ppc6xx_defconfig
http://kisskb.ellerman.id.au/kisskb/buildresult/5584116/

Confirmed any such occurances from all failed defconfigs &
in net-next sources with
grep -nrs "netdev_alloc_skb" drivers/net/ethernet/ | grep -v ","

Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
Signed-off-by: Pradeep A Dalvi <netdev@pradeepdalvi.com>
---
 drivers/net/ethernet/apple/mace.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/apple/mace.c b/drivers/net/ethernet/apple/mace.c
index 0699846..e1df4b7 100644
--- a/drivers/net/ethernet/apple/mace.c
+++ b/drivers/net/ethernet/apple/mace.c
@@ -956,7 +956,7 @@ static irqreturn_t mace_rxdma_intr(int irq, void *dev_id)
 	cp = mp->rx_cmds + i;
 	skb = mp->rx_bufs[i];
 	if (!skb) {
-	    skb = netdev_alloc_skb(RX_BUFLEN + 2);
+	    skb = netdev_alloc_skb(dev, RX_BUFLEN + 2);
 	    if (skb) {
 		skb_reserve(skb, 2);
 		mp->rx_bufs[i] = skb;
