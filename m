From: Hans Wennborg <hans@hanshq.net>
Subject: [PATCH 06/15] vmxnet3: fix decimal printf format specifiers prefixed with 0x
Date: Tue,  5 Aug 2014 21:42:41 -0700
Message-ID: <1407300161-32600-1-git-send-email-hans@hanshq.net>
Cc: Hans Wennborg <hans@hanshq.net>
To: sbhatewara@vmware.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The prefix suggests the number should be printed in hex, so use
the %x specifier to do that.

Found by using regex suggested by Joe Perches.

Signed-off-by: Hans Wennborg <hans@hanshq.net>
---
 drivers/net/vmxnet3/vmxnet3_drv.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index b76f7dc..d0db371 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -766,7 +766,7 @@ vmxnet3_map_pkt(struct sk_buff *skb, struct vmxnet3_tx_ctx *ctx,
 			gdesc->dword[3] = 0;
 
 			netdev_dbg(adapter->netdev,
-				"txd[%u]: 0x%llu %u %u\n",
+				"txd[%u]: 0x%llx %u %u\n",
 				tq->tx_ring.next2fill, le64_to_cpu(gdesc->txd.addr),
 				le32_to_cpu(gdesc->dword[2]), gdesc->dword[3]);
 			vmxnet3_cmd_ring_adv_next2fill(&tq->tx_ring);
-- 
2.0.0.526.g5318336
