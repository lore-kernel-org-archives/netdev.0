From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next 4/5] gianfar: Remove wrong buffer size conditioning to VLAN h/w offload
Date: Tue, 12 Feb 2013 14:47:16 +0200
Message-ID: <1360673237-349-4-git-send-email-claudiu.manoil@freescale.com>
References: <1360673237-349-1-git-send-email-claudiu.manoil@freescale.com>
 <1360673237-349-2-git-send-email-claudiu.manoil@freescale.com>
 <1360673237-349-3-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe001.messaging.microsoft.com ([216.32.180.11]:28816
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932967Ab3BLMsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 07:48:20 -0500
In-Reply-To: <1360673237-349-3-git-send-email-claudiu.manoil@freescale.com>
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

Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 5622134..59fb3bf 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2390,9 +2390,6 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
 	int oldsize = priv->rx_buffer_size;
 	int frame_size = new_mtu + ETH_HLEN;
 
-	if (gfar_is_vlan_on(priv))
-		frame_size += VLAN_HLEN;
-
 	if ((frame_size < 64) || (frame_size > JUMBO_FRAME_SIZE)) {
 		netif_err(priv, drv, dev, "Invalid MTU setting\n");
 		return -EINVAL;
-- 
1.6.6
