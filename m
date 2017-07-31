From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/net/wan/z85230.c: Use designated initializers
Date: Sun, 30 Jul 2017 18:31:17 -0700
Message-ID: <20170731013117.GA67801@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for the randstruct gcc plugin performing randomization of
structures that are entirely function pointers, use designated initializers
so the compiler doesn't get angry.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
This is a prerequisite for the future randstruct fptr randomization. I'd
prefer to carry this in my gcc-plugin tree for v4.14 with an Ack from
someone on net-dev, or if possible, have it applied to v4.13 via net-dev.

Thanks!
---
 drivers/net/wan/z85230.c | 30 ++++++++++++++----------------
 1 file changed, 14 insertions(+), 16 deletions(-)

diff --git a/drivers/net/wan/z85230.c b/drivers/net/wan/z85230.c
index 2f0bd6955f33..deea41e96f01 100644
--- a/drivers/net/wan/z85230.c
+++ b/drivers/net/wan/z85230.c
@@ -483,11 +483,10 @@ static void z8530_status(struct z8530_channel *chan)
 	write_zsctrl(chan, RES_H_IUS);
 }
 
-struct z8530_irqhandler z8530_sync =
-{
-	z8530_rx,
-	z8530_tx,
-	z8530_status
+struct z8530_irqhandler z8530_sync = {
+	.rx = z8530_rx,
+	.tx = z8530_tx,
+	.status = z8530_status,
 };
 
 EXPORT_SYMBOL(z8530_sync);
@@ -605,15 +604,15 @@ static void z8530_dma_status(struct z8530_channel *chan)
 }
 
 static struct z8530_irqhandler z8530_dma_sync = {
-	z8530_dma_rx,
-	z8530_dma_tx,
-	z8530_dma_status
+	.rx = z8530_dma_rx,
+	.tx = z8530_dma_tx,
+	.status = z8530_dma_status,
 };
 
 static struct z8530_irqhandler z8530_txdma_sync = {
-	z8530_rx,
-	z8530_dma_tx,
-	z8530_dma_status
+	.rx = z8530_rx,
+	.tx = z8530_dma_tx,
+	.status = z8530_dma_status,
 };
 
 /**
@@ -678,11 +677,10 @@ static void z8530_status_clear(struct z8530_channel *chan)
 	write_zsctrl(chan, RES_H_IUS);
 }
 
-struct z8530_irqhandler z8530_nop=
-{
-	z8530_rx_clear,
-	z8530_tx_clear,
-	z8530_status_clear
+struct z8530_irqhandler z8530_nop = {
+	.rx = z8530_rx_clear,
+	.tx = z8530_tx_clear,
+	.status = z8530_status_clear,
 };
 
 
-- 
2.7.4


-- 
Kees Cook
Pixel Security
