From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next] sfc: use ALIGN macro for aligning frame sizes
Date: Mon, 30 Nov 2015 17:12:21 -0500
Message-ID: <1448921541-13343-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Shradha Shah <sshah@solarflare.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53859 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754358AbbK3WM3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Nov 2015 17:12:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't open-code it.

CC: Solarflare linux maintainers <linux-net-drivers@solarflare.com>
CC: Shradha Shah <sshah@solarflare.com>
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/sfc/net_driver.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index a8ddd12..746d591 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -1502,8 +1502,9 @@ static inline struct efx_rx_buffer *efx_rx_buffer(struct efx_rx_queue *rx_queue,
  * same cycle, the XMAC can miss the IPG altogether.  We work around
  * this by adding a further 16 bytes.
  */
+#define EFX_FRAME_PAD	16
 #define EFX_MAX_FRAME_LEN(mtu) \
-	((((mtu) + ETH_HLEN + VLAN_HLEN + 4/* FCS */ + 7) & ~7) + 16)
+	(ALIGN(((mtu) + ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN + EFX_FRAME_PAD), 8))
 
 static inline bool efx_xmit_with_hwtstamp(struct sk_buff *skb)
 {
-- 
1.8.3.1
