From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net-next 12/13] net: ethernet: aquantia: Fixed incorrect buff->len calculation.
Date: Wed, 15 Feb 2017 23:01:20 +0300
Message-ID: <ab5139eca1493e73c036c4279c5baf37f74ba934.1487187192.git.pavel.belous@aquantia.com>
References: <cover.1487187192.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0043.outbound.protection.outlook.com ([104.47.40.43]:35328
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751430AbdBOUDu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Feb 2017 15:03:50 -0500
In-Reply-To: <cover.1487187192.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

rxd_wb->pkt_len is the total length of the packet.
If we received a large packet (with length > AQ_CFG_RX_FRAME_MAX) then we
will get multiple buffers. We need to fix the length of the last buffer.

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c | 4 ++--
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c
index 1f38805..a2b746a 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c
@@ -659,8 +659,8 @@ static int hw_atl_a0_hw_ring_rx_receive(struct aq_hw_s *self,
 			}
 
 			if (HW_ATL_A0_RXD_WB_STAT2_EOP & rxd_wb->status) {
-				buff->len = (rxd_wb->pkt_len &
-						(AQ_CFG_RX_FRAME_MAX - 1U));
+				buff->len = rxd_wb->pkt_len %
+					AQ_CFG_RX_FRAME_MAX;
 				buff->len = buff->len ?
 					buff->len : AQ_CFG_RX_FRAME_MAX;
 				buff->next = 0U;
diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c
index e7e694f..cab2931 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c
@@ -673,8 +673,8 @@ static int hw_atl_b0_hw_ring_rx_receive(struct aq_hw_s *self,
 			}
 
 			if (HW_ATL_B0_RXD_WB_STAT2_EOP & rxd_wb->status) {
-				buff->len = (rxd_wb->pkt_len &
-						(AQ_CFG_RX_FRAME_MAX - 1U));
+				buff->len = rxd_wb->pkt_len %
+					AQ_CFG_RX_FRAME_MAX;
 				buff->len = buff->len ?
 					buff->len : AQ_CFG_RX_FRAME_MAX;
 				buff->next = 0U;
-- 
2.7.4
