From: John Ogness <john.ogness@linutronix.de>
Subject: [PATCH 1/1] drivers: net: cpsw: Fix TX_IN_SEL offset
Date: Fri, 14 Nov 2014 15:42:52 +0100
Message-ID: <87sihlj11v.fsf@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Cc: mugunthanvnm@ti.com
Cc: balbi@ti.com
Cc: george.cherian@ti.com
Cc: jhovold@gmail.com
Cc: mpa@pengutronix.de
Cc: bhutchings@solarflare.com
Cc: zonque@gmail.com
Cc: tklauser@distanz.ch
Cc: netdev@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The TX_IN_SEL offset for the CPSW_PORT/TX_IN_CTL register was
incorrect. This caused the Dual MAC mode to never get set when
it should. It also caused possible unintentional setting of a
bit in the CPSW_PORT/TX_BLKS_REM register.

The purpose of setting the Dual MAC mode for this register is to:

    "... allow packets from both ethernet ports to be written into
     the FIFO without one port starving the other port."
					- AM335x ARM TRM

Signed-off-by: John Ogness <john.ogness@linutronix.de>
---
 drivers/net/ethernet/ti/cpsw.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index d879448..c560f9a 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -129,9 +129,9 @@ do {								\
 #define CPSW_VLAN_AWARE		BIT(1)
 #define CPSW_ALE_VLAN_AWARE	1
 
-#define CPSW_FIFO_NORMAL_MODE		(0 << 15)
-#define CPSW_FIFO_DUAL_MAC_MODE		(1 << 15)
-#define CPSW_FIFO_RATE_LIMIT_MODE	(2 << 15)
+#define CPSW_FIFO_NORMAL_MODE		(0 << 16)
+#define CPSW_FIFO_DUAL_MAC_MODE		(1 << 16)
+#define CPSW_FIFO_RATE_LIMIT_MODE	(2 << 16)
 
 #define CPSW_INTPACEEN		(0x3f << 16)
 #define CPSW_INTPRESCALE_MASK	(0x7FF << 0)
-- 
1.7.10.4
