From: j223yang@asset.uwaterloo.ca
Subject: [Patch] ariadne: fix possible null dereference
Date: Fri, 4 Mar 2011 12:46:26 -0500
Message-ID: <20110304174625.GA31042@asset.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes bugzilla #13853:
https://bugzilla.kernel.org/show_bug.cgi?id=13853

The patch removes dereference of 'dev' after testing for NULL.
The source code ariadne.c uses spaces instead of tabs, so the patch
uses spaces too.

Signed-off-by: Jinqiu Yang<crindy646@gmail.com>
---
 drivers/net/ariadne.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ariadne.c b/drivers/net/ariadne.c
--- a/drivers/net/ariadne.c
+++ b/drivers/net/ariadne.c
@@ -420,7 +420,7 @@ static inline void ariadne_reset(struct
 static irqreturn_t ariadne_interrupt(int irq, void *data)
 {
     struct net_device *dev = (struct net_device *)data;
-    volatile struct Am79C960 *lance = (struct Am79C960*)dev->base_addr;
+    volatile struct Am79C960 *lance;
     struct ariadne_private *priv;
     int csr0, boguscnt;
     int handled = 0;
@@ -430,6 +430,7 @@ static irqreturn_t ariadne_interrupt(int
        return IRQ_NONE;
     }

+    lance = (struct Am79C960 *)dev->base_addr;
     lance->RAP = CSR0;                 /* PCnet-ISA Controller Status */

     if (!(lance->RDP & INTR))          /* Check if any interrupt has been */
