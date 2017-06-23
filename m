From: <netanel@amazon.com>
Subject: [PATCH V2 net-next 09/11] net: ena: use lower_32_bits()/upper_32_bits() to split dma address
Date: Fri, 23 Jun 2017 11:21:58 +0300
Message-ID: <1498206120-13805-10-git-send-email-netanel@amazon.com>
References: <1498206120-13805-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-4101.amazon.com ([72.21.198.25]:12125 "EHLO
        smtp-fw-4101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754079AbdFWIXc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 04:23:32 -0400
In-Reply-To: <1498206120-13805-1-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

In ena_com_mem_addr_set(), use the above functions to split dma address
to the lower 32 bits and the higher 16 bits.

Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 drivers/net/ethernet/amazon/ena/ena_com.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_com.c b/drivers/net/ethernet/amazon/ena/ena_com.c
index f6e1d30523a6..52beba8c7a39 100644
--- a/drivers/net/ethernet/amazon/ena/ena_com.c
+++ b/drivers/net/ethernet/amazon/ena/ena_com.c
@@ -99,8 +99,8 @@ static inline int ena_com_mem_addr_set(struct ena_com_dev *ena_dev,
 		return -EINVAL;
 	}
 
-	ena_addr->mem_addr_low = (u32)addr;
-	ena_addr->mem_addr_high = (u64)addr >> 32;
+	ena_addr->mem_addr_low = lower_32_bits(addr);
+	ena_addr->mem_addr_high = (u16)upper_32_bits(addr);
 
 	return 0;
 }
-- 
2.7.4
