From: roel kluin <roel.kluin@gmail.com>
Subject: [PATCH] net: eepro testing positive EBUSY return by request_irq()?
Date: Fri, 31 Dec 2010 15:47:24 +0100
Message-ID: <4D1DECFC.8020701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix -EBUSY test for request_irq().

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
 drivers/net/eepro.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

I just found this in the code, no bug was observed. Is this patch needed? the test
for an -EBUSY return by request_irq() occurs much more frequently in kernel code.

diff --git a/drivers/net/eepro.c b/drivers/net/eepro.c
index 7c82631..47cfecb 100644
--- a/drivers/net/eepro.c
+++ b/drivers/net/eepro.c
@@ -920,7 +920,7 @@ static int	eepro_grab_irq(struct net_device *dev)
 
 		eepro_sw2bank0(ioaddr); /* Switch back to Bank 0 */
 
-		if (request_irq (*irqp, NULL, IRQF_SHARED, "bogus", dev) != EBUSY) {
+		if (request_irq (*irqp, NULL, IRQF_SHARED, "bogus", dev) != -EBUSY) {
 			unsigned long irq_mask;
 			/* Twinkle the interrupt, and check if it's seen */
 			irq_mask = probe_irq_on();
