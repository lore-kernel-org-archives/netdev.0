From: Colin King <colin.king@canonical.com>
Subject: [PATCH][V2] net: ethernet: slicoss: remove redundant initialization of idx
Date: Tue, 31 Oct 2017 10:08:23 +0000
Message-ID: <20171031100823.19733-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Variable idx is being initialized and later on over-written by
a new value in a do-loop without the initial value ever being
read. Hence the initializion is redundant and can be removed.
Cleans up clang warning:

drivers/net/ethernet/alacritech/slicoss.c:358:15: warning: Value
stored to 'idx' during its initialization is never read

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/alacritech/slicoss.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/alacritech/slicoss.c b/drivers/net/ethernet/alacritech/slicoss.c
index 15a8096c60df..0b60921c392f 100644
--- a/drivers/net/ethernet/alacritech/slicoss.c
+++ b/drivers/net/ethernet/alacritech/slicoss.c
@@ -355,10 +355,10 @@ static void slic_xmit_complete(struct slic_device *sdev)
 {
 	struct slic_tx_queue *txq = &sdev->txq;
 	struct net_device *dev = sdev->netdev;
-	unsigned int idx = txq->done_idx;
 	struct slic_tx_buffer *buff;
 	unsigned int frames = 0;
 	unsigned int bytes = 0;
+	unsigned int idx;
 
 	/* Limit processing to SLIC_MAX_TX_COMPLETIONS frames to avoid that new
 	 * completions during processing keeps the loop running endlessly.
-- 
2.14.1
