From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] isdn/gigaset: Use kzalloc instead of open-coded field zeroing
Date: Thu, 5 Oct 2017 12:30:17 -0700
Message-ID: <20171005193017.GA105834@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Karsten Keil <isdn@linux-pingi.de>,
        "David S. Miller" <davem@davemloft.net>,
        Johan Hovold <johan@kernel.org>, linux-kernel@vger.kernel.org,
        gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This replaces a kmalloc followed by a bunch of per-field zeroing with a
single kzalloc call, reducing the lines of code.

Cc: Paul Bolle <pebolle@tiscali.nl>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Johan Hovold <johan@kernel.org>
Cc: gigaset307x-common@lists.sourceforge.net
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/isdn/gigaset/bas-gigaset.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/bas-gigaset.c
index 2da3ff650e1d..33151f05e744 100644
--- a/drivers/isdn/gigaset/bas-gigaset.c
+++ b/drivers/isdn/gigaset/bas-gigaset.c
@@ -2200,7 +2200,7 @@ static int gigaset_initcshw(struct cardstate *cs)
 {
 	struct bas_cardstate *ucs;
 
-	cs->hw.bas = ucs = kmalloc(sizeof *ucs, GFP_KERNEL);
+	cs->hw.bas = ucs = kzalloc(sizeof(*ucs), GFP_KERNEL);
 	if (!ucs) {
 		pr_err("out of memory\n");
 		return -ENOMEM;
@@ -2212,15 +2212,7 @@ static int gigaset_initcshw(struct cardstate *cs)
 		return -ENOMEM;
 	}
 
-	ucs->urb_cmd_in = NULL;
-	ucs->urb_cmd_out = NULL;
-	ucs->rcvbuf = NULL;
-	ucs->rcvbuf_size = 0;
-
 	spin_lock_init(&ucs->lock);
-	ucs->pending = 0;
-
-	ucs->basstate = 0;
 	setup_timer(&ucs->timer_ctrl, req_timeout, (unsigned long) cs);
 	setup_timer(&ucs->timer_atrdy, atrdy_timeout, (unsigned long) cs);
 	setup_timer(&ucs->timer_cmd_in, cmd_in_timeout, (unsigned long) cs);
-- 
2.7.4


-- 
Kees Cook
Pixel Security
