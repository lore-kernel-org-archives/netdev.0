From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: cavium: liquidio: fix check for in progress flag
Date: Fri,  5 Feb 2016 16:30:39 +0000
Message-ID: <1454689839-6360-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

smatch detected a suspicious looking bitop condition:

drivers/net/ethernet/cavium/liquidio/lio_main.c:2529
  handle_timestamp() warn: suspicious bitop condition

(skb_shinfo(skb)->tx_flags | SKBTX_IN_PROGRESS is always non-zero,
so the logic is definitely not correct.  Use & to mask the correct
bit.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 8727655..06b6be8 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -2524,7 +2524,7 @@ static void handle_timestamp(struct octeon_device *oct,
 
 	octeon_swap_8B_data(&resp->timestamp, 1);
 
-	if (unlikely((skb_shinfo(skb)->tx_flags | SKBTX_IN_PROGRESS) != 0)) {
+	if (unlikely((skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS) != 0)) {
 		struct skb_shared_hwtstamps ts;
 		u64 ns = resp->timestamp;
 
-- 
2.7.0
