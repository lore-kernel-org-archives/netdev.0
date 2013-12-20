From: Nithin Nayak Sujir <nsujir@broadcom.com>
Subject: [PATCH net] tg3: Expand 4g_overflow_test workaround to skb fragments of any size.
Date: Thu, 19 Dec 2013 16:24:12 -0800
Message-ID: <1387499052-7838-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Nithin Nayak Sujir <nsujir@broadcom.com>,
	<stable@vger.kernel.org>, Michael Chan <mchan@broadcom.com>
To: <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current driver assumes that an skb fragment can only be upto jumbo
size. Presumably this was a fast-path optimization. This assumption is
no longer true as fragments can be upto 32k.

Cc: stable@vger.kernel.org
Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index f3dd93b..8ab21d7 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -7622,7 +7622,7 @@ static inline int tg3_4g_overflow_test(dma_addr_t mapping, int len)
 {
 	u32 base = (u32) mapping & 0xffffffff;
 
-	return (base > 0xffffdcc0) && (base + len + 8 < base);
+	return (base + len + 8 < base);
 }
 
 /* Test for TSO DMA buffers that cross into regions which are within MSS bytes
-- 
1.8.1.4
