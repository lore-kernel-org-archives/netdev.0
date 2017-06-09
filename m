From: <netanel@amazon.com>
Subject: [PATCH net-next 7/8] net: ena: disable admin msix while working in polling mode
Date: Sat, 10 Jun 2017 01:13:56 +0300
Message-ID: <1497046437-20390-8-git-send-email-netanel@amazon.com>
References: <1497046437-20390-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-9101.amazon.com ([207.171.184.25]:1475 "EHLO
        smtp-fw-9101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751571AbdFIWPl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 18:15:41 -0400
In-Reply-To: <1497046437-20390-1-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 drivers/net/ethernet/amazon/ena/ena_com.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/amazon/ena/ena_com.c b/drivers/net/ethernet/amazon/ena/ena_com.c
index ea60b9e..f5b237e 100644
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
