From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 24/27] orinoco_usb: Use setup_timer
Date: Fri, 26 Dec 2014 15:35:55 +0100
Message-ID: <1419604558-29743-25-git-send-email-Julia.Lawall@lip6.fr>
References: <1419604558-29743-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419604558-29743-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert a call to init_timer and accompanying intializations of
the timer's data and function fields to a call to setup_timer.

A simplified version of the semantic match that fixes this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression t,f,d;
@@

-init_timer(&t);
+setup_timer(&t,f,d);
-t.function = f;
-t.data = d;
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/wireless/orinoco/orinoco_usb.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/wireless/orinoco/orinoco_usb.c b/drivers/net/wireless/orinoco/orinoco_usb.c
index 9958464..61612a6 100644
--- a/drivers/net/wireless/orinoco/orinoco_usb.c
+++ b/drivers/net/wireless/orinoco/orinoco_usb.c
@@ -364,9 +364,7 @@ static struct request_context *ezusb_alloc_ctx(struct ezusb_priv *upriv,
 	atomic_set(&ctx->refcount, 1);
 	init_completion(&ctx->done);
 
-	init_timer(&ctx->timer);
-	ctx->timer.function = ezusb_request_timerfn;
-	ctx->timer.data = (u_long) ctx;
+	setup_timer(&ctx->timer, ezusb_request_timerfn, (u_long)ctx);
 	return ctx;
 }
 
