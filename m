From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 3/9] bnxt_en: Fix ethtool -l pre-set max combined channel.
Date: Sun, 12 Feb 2017 19:18:12 -0500
Message-ID: <1486945098-4086-4-git-send-email-michael.chan@broadcom.com>
References: <1486945098-4086-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:37111 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751302AbdBMASw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 19:18:52 -0500
Received: by mail-it0-f45.google.com with SMTP id x75so22849447itb.0
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 16:18:52 -0800 (PST)
In-Reply-To: <1486945098-4086-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With commit d1e7925e6d80 ("bnxt_en: Centralize logic to reserve rings."),
ring allocation for combined rings has become stricter.  A combined
ring must now have an rx-tx ring pair.  The pre-set max. for combined
rings should now be min(rx, tx).

Fixes: d1e7925e6d80 ("bnxt_en: Centralize logic to reserve rings.")
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 4b45b88..6903a87 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -357,7 +357,7 @@ static void bnxt_get_channels(struct net_device *dev,
 	int max_rx_rings, max_tx_rings, tcs;
 
 	bnxt_get_max_rings(bp, &max_rx_rings, &max_tx_rings, true);
-	channel->max_combined = max_t(int, max_rx_rings, max_tx_rings);
+	channel->max_combined = min_t(int, max_rx_rings, max_tx_rings);
 
 	if (bnxt_get_max_rings(bp, &max_rx_rings, &max_tx_rings, false)) {
 		max_rx_rings = 0;
-- 
1.8.3.1
