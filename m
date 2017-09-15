From: Srishti Sharma <srishtishar@gmail.com>
Subject: [PATCH] Staging: irda: Don't use assignment inside if statement
Date: Sat, 16 Sep 2017 01:03:56 +0530
Message-ID: <1505504036-21807-1-git-send-email-srishtishar@gmail.com>
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org,
        devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org,
        outreachy-kernel@googlegroups.com,
        Srishti Sharma <srishtishar@gmail.com>
To: samuel@sortiz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Write assignment statement outside the if statement. Done using
the following semantic patch by coccinelle.

@@
identifier E;
expression F;
statement S;
@@

-if((E = F))
+E = F
+if(E)
  S

Signed-off-by: Srishti Sharma <srishtishar@gmail.com>
---
 drivers/staging/irda/drivers/irda-usb.c | 4 ++--
 drivers/staging/irda/drivers/mcs7780.c  | 9 ++++++---
 drivers/staging/irda/net/irqueue.c      | 3 ++-
 3 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/irda/drivers/irda-usb.c b/drivers/staging/irda/drivers/irda-usb.c
index 723e49b..82bfc05 100644
--- a/drivers/staging/irda/drivers/irda-usb.c
+++ b/drivers/staging/irda/drivers/irda-usb.c
@@ -334,9 +334,9 @@ static void irda_usb_change_speed_xbofs(struct irda_usb_cb *self)
 	urb->transfer_flags = 0;
 
 	/* Irq disabled -> GFP_ATOMIC */
-	if ((ret = usb_submit_urb(urb, GFP_ATOMIC))) {
+	ret = usb_submit_urb(urb, GFP_ATOMIC);
+	if (ret)
 		net_warn_ratelimited("%s(), failed Speed URB\n", __func__);
-	}
 }
 
 /*------------------------------------------------------------------*/
diff --git a/drivers/staging/irda/drivers/mcs7780.c b/drivers/staging/irda/drivers/mcs7780.c
index c3f0b25..2b674d5 100644
--- a/drivers/staging/irda/drivers/mcs7780.c
+++ b/drivers/staging/irda/drivers/mcs7780.c
@@ -605,19 +605,22 @@ static int mcs_speed_change(struct mcs_cb *mcs)
 	if (mcs->new_speed <= 115200) {
 		rval &= ~MCS_FIR;
 
-		if ((rst = (mcs->speed > 115200)))
+		rst = (mcs->speed > 115200);
+		if (rst)
 			mcs_set_reg(mcs, MCS_MINRXPW_REG, 0);
 
 	} else if (mcs->new_speed <= 1152000) {
 		rval &= ~MCS_FIR;
 
-		if ((rst = !(mcs->speed == 576000 || mcs->speed == 1152000)))
+		rst = !(mcs->speed == 576000 || mcs->speed == 1152000);
+		if (rst)
 			mcs_set_reg(mcs, MCS_MINRXPW_REG, 5);
 
 	} else {
 		rval |= MCS_FIR;
 
-		if ((rst = (mcs->speed != 4000000)))
+		rst = (mcs->speed != 4000000);
+		if (rst)
 			mcs_set_reg(mcs, MCS_MINRXPW_REG, 5);
 
 	}
diff --git a/drivers/staging/irda/net/irqueue.c b/drivers/staging/irda/net/irqueue.c
index 160dc89..5aab072 100644
--- a/drivers/staging/irda/net/irqueue.c
+++ b/drivers/staging/irda/net/irqueue.c
@@ -217,7 +217,8 @@ static __u32 hash( const char* name)
 
 	while(*name) {
 		h = (h<<4) + *name++;
-		if ((g = (h & 0xf0000000)))
+		g = (h & 0xf0000000);
+		if (g)
 			h ^=g>>24;
 		h &=~g;
 	}
-- 
2.7.4
