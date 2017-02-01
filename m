From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch net-next] ethernet: aquantia: fix dma_mapping_error test
Date: Wed, 1 Feb 2017 11:52:15 +0300
Message-ID: <20170201085215.GB31514@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:32023 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751420AbdBAIwg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 03:52:36 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dma_mapping_error() returns 1 if there is an error and 0 if not.

Fixes: 018423e90bee ("net: ethernet: aquantia: Add ring support code")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
index 817c145520c8..dea9e9bbb8e7 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_ring.c
@@ -298,9 +298,10 @@ int aq_ring_rx_fill(struct aq_ring_s *self)
 					buff->page, 0,
 					AQ_CFG_RX_FRAME_MAX, DMA_FROM_DEVICE);
 
-		err = dma_mapping_error(aq_nic_get_dev(self->aq_nic), buff->pa);
-		if (err < 0)
+		if (dma_mapping_error(aq_nic_get_dev(self->aq_nic), buff->pa)) {
+			err = -ENOMEM;
 			goto err_exit;
+		}
 
 		buff = NULL;
 	}
