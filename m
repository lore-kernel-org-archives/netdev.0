From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH v2] net: smsc: remove build warning of duplicate definition
Date: Sun,  4 Sep 2016 23:02:21 +0530
Message-ID: <1473010341-10359-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Sudip Mukherjee <sudipm.mukherjee@gmail.com>
To: Nicolas Pitre <nico@fluxnic.net>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The build of m32r was giving warning:

In file included from drivers/net/ethernet/smsc/smc91x.c:92:0:
drivers/net/ethernet/smsc/smc91x.h:448:0: warning: "SMC_inb" redefined
 #define SMC_inb(ioaddr, reg)  ({ BUG(); 0; })
 
drivers/net/ethernet/smsc/smc91x.h:106:0:
	note: this is the location of the previous definition
 #define SMC_inb(a, r)  inb(((u32)a) + (r))
 
drivers/net/ethernet/smsc/smc91x.h:449:0: warning: "SMC_outb" redefined
 #define SMC_outb(x, ioaddr, reg) BUG()
 
drivers/net/ethernet/smsc/smc91x.h:108:0:
	note: this is the location of the previous definition
 #define SMC_outb(v, a, r) outb(v, ((u32)a) + (r))

Signed-off-by: Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>
---

v2: +#ifdef of v1 is removed.

 drivers/net/ethernet/smsc/smc91x.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/smsc/smc91x.h b/drivers/net/ethernet/smsc/smc91x.h
index 1a55c79..06d7dca 100644
--- a/drivers/net/ethernet/smsc/smc91x.h
+++ b/drivers/net/ethernet/smsc/smc91x.h
@@ -445,7 +445,9 @@ smc_pxa_dma_insw(void __iomem *ioaddr, struct smc_local *lp, int reg, int dma,
 #endif
 
 #if ! SMC_CAN_USE_8BIT
+#undef SMC_inb
 #define SMC_inb(ioaddr, reg)		({ BUG(); 0; })
+#undef SMC_outb
 #define SMC_outb(x, ioaddr, reg)	BUG()
 #define SMC_insb(a, r, p, l)		BUG()
 #define SMC_outsb(a, r, p, l)		BUG()
-- 
1.9.1
