From: skallam <siva.kallam@broadcom.com>
Subject: [PATCH net 1/2] tg3: Fix for diasllow rx coalescing time to be 0
Date: Wed,  3 Aug 2016 09:43:59 +0530
Message-ID: <1470197640-13587-2-git-send-email-siva.kallam@broadcom.com>
References: <1470197640-13587-1-git-send-email-siva.kallam@broadcom.com>
Cc: netdev@vger.kernel.org, michael.chan@broadcom.com,
	prashant@broadcom.com, satish.baddipadige@broadcom.com,
	Siva Reddy Kallam <siva.kallam@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:22585 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751606AbcHCFcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 01:32:52 -0400
In-Reply-To: <1470197640-13587-1-git-send-email-siva.kallam@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Satish Baddipadige <satish.baddipadige@broadcom.com>

When the rx coalescing time is 0, interrupts
are not generated from the controller and rx path hangs.
To avoid this rx hang, updating the driver to not allow
rx coalescing time to be 0.

Signed-off-by: Satish Baddipadige <satish.baddipadige@broadcom.com>
Signed-off-by: Siva Reddy Kallam <siva.kallam@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index ff300f7..f3c6c91 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -14014,6 +14014,7 @@ static int tg3_set_coalesce(struct net_device *dev, struct ethtool_coalesce *ec)
 	}
 
 	if ((ec->rx_coalesce_usecs > MAX_RXCOL_TICKS) ||
+	    (!ec->rx_coalesce_usecs) ||
 	    (ec->tx_coalesce_usecs > MAX_TXCOL_TICKS) ||
 	    (ec->rx_max_coalesced_frames > MAX_RXMAX_FRAMES) ||
 	    (ec->tx_max_coalesced_frames > MAX_TXMAX_FRAMES) ||
-- 
1.7.1
