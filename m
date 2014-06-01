From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 4/11 V3] via-ircc: Remove useless return variables
Date: Sun,  1 Jun 2014 10:56:29 -0300
Message-ID: <1401630989-5773-1-git-send-email-peter.senna@gmail.com>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dan.carpenter@oracle.com,
	wharms@bfs.de
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch remove variables that are initialized with a constant,
are never updated, and are only used as parameter of return.
Return the constant instead of using a variable.

For via_ircc_read_dongle_id(), return IBM_DONGLE_ID instead of 9.
The #define IBM_DONGLE_ID 9 is added by this patch.

Verified by compilation only.

The coccinelle script that find and fixes this issue is:
// <smpl>
@@
type T;
constant C;
identifier ret;
@@
- T ret = C;
... when != ret
    when strict
return
- ret
+ C
;
// </smpl>

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

---
Changes from V2:
 - added #define IBM_DONGLE_ID 9
 - return IBM_DONGLE_ID instead of 9

Changes from V1:
 - Moved comment about return value to near the return value

 drivers/net/irda/via-ircc.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index 2900af0..2dd6582 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -65,6 +65,7 @@ F02 Oct/28/02: Add SB device ID for 3147 and 3177.
 
 #define VIA_MODULE_NAME "via-ircc"
 #define CHIP_IO_EXTENT 0x40
+#define IBM_DONGLE_ID 9
 
 static char *driver_name = VIA_MODULE_NAME;
 
@@ -510,10 +511,10 @@ static void via_hw_init(struct via_ircc_cb *self)
  */
 static int via_ircc_read_dongle_id(int iobase)
 {
-	int dongle_id = 9;	/* Default to IBM */
-
 	IRDA_ERROR("via-ircc: dongle probing not supported, please specify dongle_id module parameter.\n");
-	return dongle_id;
+
+	/* Everything is an IBM */
+	return IBM_DONGLE_ID;
 }
 
 /*
@@ -926,7 +927,6 @@ static int via_ircc_dma_xmit(struct via_ircc_cb *self, u16 iobase)
 static int via_ircc_dma_xmit_complete(struct via_ircc_cb *self)
 {
 	int iobase;
-	int ret = TRUE;
 	u8 Tx_status;
 
 	IRDA_DEBUG(3, "%s()\n", __func__);
@@ -983,7 +983,7 @@ F01_E*/
 	// Tell the network layer, that we can accept more frames 
 	netif_wake_queue(self->netdev);
 //F01   }
-	return ret;
+	return TRUE;
 }
 
 /*
