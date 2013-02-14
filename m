From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next 6/7] gianfar: Remove wrong buffer size conditioning to VLAN h/w offload
Date: Thu, 14 Feb 2013 17:00:06 +0200
Message-ID: <1360854007-11094-7-git-send-email-claudiu.manoil@freescale.com>
References: <1360854007-11094-1-git-send-email-claudiu.manoil@freescale.com>
 <1360854007-11094-2-git-send-email-claudiu.manoil@freescale.com>
 <1360854007-11094-3-git-send-email-claudiu.manoil@freescale.com>
 <1360854007-11094-4-git-send-email-claudiu.manoil@freescale.com>
 <1360854007-11094-5-git-send-email-claudiu.manoil@freescale.com>
 <1360854007-11094-6-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe004.messaging.microsoft.com ([207.46.163.27]:38412
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754310Ab3BNPAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 10:00:19 -0500
In-Reply-To: <1360854007-11094-6-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The controller's ref manual states clearly that when the hw Rx vlan
offload feature is enabled, meaning that the VLEX bit from RCTRL is
correctly enabled, then the hw performs automatic VLAN tag extraction
and deletion from the ethernet frames. So there's no point in trying to
increase the rx buff size when rxvlan is on, as the frame is actually
smaller.
And the Tx vlan hw accel feature (VLINS) has nothing to do with rx buff
size computation.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index d70f74c..b2c6077 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2385,9 +2385,6 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
 	int oldsize = priv->rx_buffer_size;
 	int frame_size = new_mtu + ETH_HLEN;
 
-	if (gfar_is_vlan_on(priv))
-		frame_size += VLAN_HLEN;
-
 	if ((frame_size < 64) || (frame_size > JUMBO_FRAME_SIZE)) {
 		netif_err(priv, drv, dev, "Invalid MTU setting\n");
 		return -EINVAL;
-- 
1.7.7.4
