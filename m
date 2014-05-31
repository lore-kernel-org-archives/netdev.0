From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 4/11] via-ircc: Remove useless return variables
Date: Sat, 31 May 2014 10:14:04 -0300
Message-ID: <1401542051-3174-4-git-send-email-peter.senna@gmail.com>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch remove variables that are initialized with a constant,
are never updated, and are only used as parameter of return.
Return the constant instead of using a variable.

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
 drivers/net/irda/via-ircc.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index 2900af0..3fde116 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -509,11 +509,9 @@ static void via_hw_init(struct via_ircc_cb *self)
  *
  */
 static int via_ircc_read_dongle_id(int iobase)
-{
-	int dongle_id = 9;	/* Default to IBM */
-
+{/* Default to IBM */
 	IRDA_ERROR("via-ircc: dongle probing not supported, please specify dongle_id module parameter.\n");
-	return dongle_id;
+	return 9;
 }
 
 /*
@@ -926,7 +924,6 @@ static int via_ircc_dma_xmit(struct via_ircc_cb *self, u16 iobase)
 static int via_ircc_dma_xmit_complete(struct via_ircc_cb *self)
 {
 	int iobase;
-	int ret = TRUE;
 	u8 Tx_status;
 
 	IRDA_DEBUG(3, "%s()\n", __func__);
@@ -983,7 +980,7 @@ F01_E*/
 	// Tell the network layer, that we can accept more frames 
 	netif_wake_queue(self->netdev);
 //F01   }
-	return ret;
+	return TRUE;
 }
 
 /*
