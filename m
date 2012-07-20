From: Shuah Khan <shuah.khan@hp.com>
Subject: [PATCH RFT RESEND] net: Fix Neptune ethernet driver to check dma
 mapping error
Date: Fri, 20 Jul 2012 15:50:35 -0600
Message-ID: <1342821035.5434.60.camel@lorien2>
Reply-To: shuah.khan@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	shuahkhan@gmail.com, stable@vger.kernel.org
To: davem@davemloft.net, mcarlson@broadcom.com,
	bhutchings@solarflare.com, eric.dumazet@gmail.com,
	mchan@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix Neptune ethernet driver to check dma mapping error after map_page()
interface returns.

Signed-off-by: Shuah Khan <shuah.khan@hp.com>
---
 drivers/net/ethernet/sun/niu.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 8c726b7..60d5c03 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -3335,6 +3335,10 @@ static int niu_rbr_add_page(struct niu *np, struct rx_ring_info *rp,
 
 	addr = np->ops->map_page(np->device, page, 0,
 				 PAGE_SIZE, DMA_FROM_DEVICE);
+	if (!addr) {
+		__free_page(page);
+		return -ENOMEM;
+	}
 
 	niu_hash_page(rp, page, addr);
 	if (rp->rbr_blocks_per_page > 1)
-- 
1.7.9.5
