From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: ena: Fix error return code in ena_device_init()
Date: Mon, 15 Aug 2016 22:51:04 +0000
Message-ID: <1471301464-24748-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyj.lk@gmail.com>, netdev@vger.kernel.org
To: Netanel Belgazal <netanel@annapurnalabs.com>,
	Saeed Bishara <saeed@annapurnalabs.com>,
	Zorik Machulsky <zorik@annapurnalabs.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:36155 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752258AbcHOWvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 18:51:13 -0400
Received: by mail-pa0-f68.google.com with SMTP id ez1so4212034pab.3
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 15:51:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix to return a negative error code from the invalid dma width
error handling case instead of 0.

Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index 94790df..4cbe014 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -2329,6 +2329,7 @@ static int ena_device_init(struct ena_com_dev *ena_dev, struct pci_dev *pdev,
 	dma_width = ena_com_get_dma_width(ena_dev);
 	if (dma_width < 0) {
 		dev_err(dev, "Invalid dma width value %d", dma_width);
+		rc = dma_width;
 		goto err_mmio_read_less;
 	}
