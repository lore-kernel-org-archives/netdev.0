From: <netanel@amazon.com>
Subject: [PATCH net 7/9] net: ena: disable admin msix while working in polling mode
Date: Sun, 11 Jun 2017 15:42:49 +0300
Message-ID: <1497184971-28178-8-git-send-email-netanel@amazon.com>
References: <1497184971-28178-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-2101.amazon.com ([72.21.196.25]:62969 "EHLO
        smtp-fw-2101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751850AbdFKMyC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 08:54:02 -0400
In-Reply-To: <1497184971-28178-1-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

Fixes: 1738cd3ed342 ("Add a driver for Amazon Elastic Network Adapters (ENA)")
Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 drivers/net/ethernet/amazon/ena/ena_com.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/amazon/ena/ena_com.c b/drivers/net/ethernet/amazon/ena/ena_com.c
index ea60b9e67acb..f5b237e0bd60 100644
--- a/drivers/net/ethernet/amazon/ena/ena_com.c
+++ b/drivers/net/ethernet/amazon/ena/ena_com.c
@@ -61,6 +61,8 @@
 
 #define ENA_MMIO_READ_TIMEOUT 0xFFFFFFFF
 
+#define ENA_REGS_ADMIN_INTR_MASK 1
+
 /*****************************************************************************/
 /*****************************************************************************/
 /*****************************************************************************/
@@ -1454,6 +1456,12 @@ void ena_com_admin_destroy(struct ena_com_dev *ena_dev)
 
 void ena_com_set_admin_polling_mode(struct ena_com_dev *ena_dev, bool polling)
 {
+	u32 mask_value = 0;
+
+	if (polling)
+		mask_value = ENA_REGS_ADMIN_INTR_MASK;
+
+	writel(mask_value, ena_dev->reg_bar + ENA_REGS_INTR_MASK_OFF);
 	ena_dev->admin_queue.polling = polling;
 }
 
-- 
2.7.4
