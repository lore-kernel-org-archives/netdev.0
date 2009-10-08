From: Thomas Chou <thomas@wytron.com.tw>
Subject: [PATCH 1/2] ethoc: inline regs access
Date: Thu,  8 Oct 2009 08:16:42 +0800
Message-ID: <1254961003-2453-1-git-send-email-thomas@wytron.com.tw>
Cc: thierry.reding@avionic-design.de,
	Nios2 development list <nios2-dev@sopc.et.ntust.edu.tw>,
	linux-kernel@vger.kernel.org, Thomas Chou <thomas@wytron.com.tw>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756591AbZJHAQ0@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Chou <thomas@wytron.com.tw>
---
 drivers/net/ethoc.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index 22df0a6..6b39723 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -222,24 +222,25 @@ struct ethoc_bd {
 	u32 addr;
 };
 
-static u32 ethoc_read(struct ethoc *dev, loff_t offset)
+static inline u32 ethoc_read(struct ethoc *dev, loff_t offset)
 {
 	return ioread32(dev->iobase + offset);
 }
 
-static void ethoc_write(struct ethoc *dev, loff_t offset, u32 data)
+static inline void ethoc_write(struct ethoc *dev, loff_t offset, u32 data)
 {
 	iowrite32(data, dev->iobase + offset);
 }
 
-static void ethoc_read_bd(struct ethoc *dev, int index, struct ethoc_bd *bd)
+static inline void ethoc_read_bd(struct ethoc *dev, int index,
+		struct ethoc_bd *bd)
 {
 	loff_t offset = ETHOC_BD_BASE + (index * sizeof(struct ethoc_bd));
 	bd->stat = ethoc_read(dev, offset + 0);
 	bd->addr = ethoc_read(dev, offset + 4);
 }
 
-static void ethoc_write_bd(struct ethoc *dev, int index,
+static inline void ethoc_write_bd(struct ethoc *dev, int index,
 		const struct ethoc_bd *bd)
 {
 	loff_t offset = ETHOC_BD_BASE + (index * sizeof(struct ethoc_bd));
@@ -247,33 +248,33 @@ static void ethoc_write_bd(struct ethoc *dev, int index,
 	ethoc_write(dev, offset + 4, bd->addr);
 }
 
-static void ethoc_enable_irq(struct ethoc *dev, u32 mask)
+static inline void ethoc_enable_irq(struct ethoc *dev, u32 mask)
 {
 	u32 imask = ethoc_read(dev, INT_MASK);
 	imask |= mask;
 	ethoc_write(dev, INT_MASK, imask);
 }
 
-static void ethoc_disable_irq(struct ethoc *dev, u32 mask)
+static inline void ethoc_disable_irq(struct ethoc *dev, u32 mask)
 {
 	u32 imask = ethoc_read(dev, INT_MASK);
 	imask &= ~mask;
 	ethoc_write(dev, INT_MASK, imask);
 }
 
-static void ethoc_ack_irq(struct ethoc *dev, u32 mask)
+static inline void ethoc_ack_irq(struct ethoc *dev, u32 mask)
 {
 	ethoc_write(dev, INT_SOURCE, mask);
 }
 
-static void ethoc_enable_rx_and_tx(struct ethoc *dev)
+static inline void ethoc_enable_rx_and_tx(struct ethoc *dev)
 {
 	u32 mode = ethoc_read(dev, MODER);
 	mode |= MODER_RXEN | MODER_TXEN;
 	ethoc_write(dev, MODER, mode);
 }
 
-static void ethoc_disable_rx_and_tx(struct ethoc *dev)
+static inline void ethoc_disable_rx_and_tx(struct ethoc *dev)
 {
 	u32 mode = ethoc_read(dev, MODER);
 	mode &= ~(MODER_RXEN | MODER_TXEN);
-- 
1.6.2.5
