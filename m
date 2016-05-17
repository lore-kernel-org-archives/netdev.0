From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1] net: irda: avoid null pointer dereference
Date: Wed, 18 May 2016 00:06:02 +0200
Message-ID: <1463522762-11144-1-git-send-email-xypron.glpk@gmx.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Only dereference variable self after checking it is not NULL.

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/irda/nsc-ircc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/irda/nsc-ircc.c b/drivers/net/irda/nsc-ircc.c
index 9ef13d8..aaecc3b 100644
--- a/drivers/net/irda/nsc-ircc.c
+++ b/drivers/net/irda/nsc-ircc.c
@@ -1253,7 +1253,7 @@ static void nsc_ircc_change_dongle_speed(int iobase, int speed, int dongle_id)
  */
 static __u8 nsc_ircc_change_speed(struct nsc_ircc_cb *self, __u32 speed)
 {
-	struct net_device *dev = self->netdev;
+	struct net_device *dev;
 	__u8 mcr = MCR_SIR;
 	int iobase; 
 	__u8 bank;
@@ -1263,6 +1263,7 @@ static __u8 nsc_ircc_change_speed(struct nsc_ircc_cb *self, __u32 speed)
 
 	IRDA_ASSERT(self != NULL, return 0;);
 
+	dev = self->netdev;
 	iobase = self->io.fir_base;
 
 	/* Update accounting for new speed */
-- 
2.1.4
