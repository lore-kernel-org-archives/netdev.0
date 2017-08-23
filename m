From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 1/3] bnxt_en: Fix .ndo_setup_tc() to include XDP rings.
Date: Wed, 23 Aug 2017 19:34:03 -0400
Message-ID: <1503531245-4046-2-git-send-email-michael.chan@broadcom.com>
References: <1503531245-4046-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:33362 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751146AbdHWXeU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 19:34:20 -0400
Received: by mail-qk0-f181.google.com with SMTP id a77so8888656qkb.0
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 16:34:20 -0700 (PDT)
In-Reply-To: <1503531245-4046-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the number of TX rings is changed in bnxt_setup_tc(), we need to
include the XDP rings in the total TX ring count.

Fixes: 38413406277f ("bnxt_en: Add support for XDP_TX action.")
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index e7c8539..f2f2bbf 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -7152,6 +7152,7 @@ int bnxt_setup_mq_tc(struct net_device *dev, u8 tc)
 		bp->tx_nr_rings = bp->tx_nr_rings_per_tc;
 		netdev_reset_tc(dev);
 	}
+	bp->tx_nr_rings += bp->tx_nr_rings_xdp;
 	bp->cp_nr_rings = sh ? max_t(int, bp->tx_nr_rings, bp->rx_nr_rings) :
 			       bp->tx_nr_rings + bp->rx_nr_rings;
 	bp->num_stat_ctxs = bp->cp_nr_rings;
-- 
1.8.3.1
