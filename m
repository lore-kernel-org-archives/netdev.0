From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Subject: [PATCH] net: smsc: remove deprecated IRQF_DISABLED
Date: Fri, 13 Sep 2013 06:27:47 +0200
Message-ID: <1379046467-6900-1-git-send-email-michael.opdenacker@free-electrons.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	will.deacon@arm.com,
	Michael Opdenacker <michael.opdenacker@free-electrons.com>
To: steve.glendinning@shawell.net, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch proposes to remove the IRQF_DISABLED flag from
code in drivers/net/ethernet/smsc/

It's a NOOP since 2.6.35 and it will be removed one day.

Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>
---
 drivers/net/ethernet/smsc/smc91x.h   | 2 +-
 drivers/net/ethernet/smsc/smsc9420.c | 3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc91x.h b/drivers/net/ethernet/smsc/smc91x.h
index 370e13d..5730fe2 100644
--- a/drivers/net/ethernet/smsc/smc91x.h
+++ b/drivers/net/ethernet/smsc/smc91x.h
@@ -271,7 +271,7 @@ static inline void mcf_outsw(void *a, unsigned char *p, int l)
 #define SMC_insw(a, r, p, l)	mcf_insw(a + r, p, l)
 #define SMC_outsw(a, r, p, l)	mcf_outsw(a + r, p, l)
 
-#define SMC_IRQ_FLAGS		(IRQF_DISABLED)
+#define SMC_IRQ_FLAGS		0
 
 #else
 
diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index ffa5c4a..5f9e79f 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -1356,8 +1356,7 @@ static int smsc9420_open(struct net_device *dev)
 	smsc9420_reg_write(pd, INT_STAT, 0xFFFFFFFF);
 	smsc9420_pci_flush_write(pd);
 
-	result = request_irq(irq, smsc9420_isr, IRQF_SHARED | IRQF_DISABLED,
-			     DRV_NAME, pd);
+	result = request_irq(irq, smsc9420_isr, IRQF_SHARED, DRV_NAME, pd);
 	if (result) {
 		smsc_warn(IFUP, "Unable to use IRQ = %d", irq);
 		result = -ENODEV;
-- 
1.8.1.2
