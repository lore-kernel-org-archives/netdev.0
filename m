From: "Hegde, Vinay" <vinay.hegde@ti.com>
Subject: [PATCH] davinci: da850/omap-l138: Add Carrier Link OK check in Davinci RX Handler
Date: Fri, 25 Feb 2011 15:26:28 +0530
Message-ID: <1298627788-32339-1-git-send-email-vinay.hegde@ti.com>
Cc: khilman@ti.com, davinci-linux-open-source@linux.davincidsp.com,
	linux-arm-kernel@lists.infradead.org,
	"Hegde, Vinay" <vinay.hegde@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:34615 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932415Ab1BYKAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 05:00:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds an additional check in the Davinci EMAC RX Handler,
which tests the __LINK_STATE_NOCARRIER flag along with the
__LINK_STATE_START flag as part EMAC shutting down procedure.

This avoids
WARNING: at drivers/net/davinci_emac.c:1040 emac_rx_handler+0xf8/0x120()
during rtcwake used to suspend the target for a specified duration.

Signed-off-by: Hegde, Vinay <vinay.hegde@ti.com>
---
 drivers/net/davinci_emac.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 2a628d1..7018bfe 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -1008,7 +1008,7 @@ static void emac_rx_handler(void *token, int len, int status)
 	int			ret;
 
 	/* free and bail if we are shutting down */
-	if (unlikely(!netif_running(ndev))) {
+	if (unlikely(!netif_running(ndev) || !netif_carrier_ok(ndev))) {
 		dev_kfree_skb_any(skb);
 		return;
 	}
-- 
1.7.1

