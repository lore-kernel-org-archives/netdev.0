From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] ixgbe: only check pfc bits in hang logic if pfc is
	enabled
Date: Thu, 03 Jun 2010 20:03:45 -0700
Message-ID: <20100604030314.16356.79492.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:49336 "EHLO
	qmta06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757071Ab0FDDEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 23:04:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Only check pfc bits in hang logic if PFC is enabled.  Previously,
if DCB was enabled but PFC was disabled the incorrect pause
bits would be checked.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Acked-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index d571d10..b2af2f6 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -642,7 +642,7 @@ static inline bool ixgbe_tx_xon_state(struct ixgbe_adapter *adapter,
 	u32 txoff = IXGBE_TFCS_TXOFF;
 
 #ifdef CONFIG_IXGBE_DCB
-	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
+	if (adapter->dcb_cfg.pfc_mode_enable) {
 		int tc;
 		int reg_idx = tx_ring->reg_idx;
 		int dcb_i = adapter->ring_feature[RING_F_DCB].indices;

