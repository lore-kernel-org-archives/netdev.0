From: Vaishali Thakkar <vthakkar1994@gmail.com>
Subject: [PATCH] isdn/capi: Use setup_timer
Date: Mon, 1 Jun 2015 07:10:15 +0530
Message-ID: <20150601014015.GA6747@vaishali-Ideapad-Z570>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julia Lawall <julia.lawall@lip6.fr>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the timer API function setup_timer instead of structure field
assignments to initialize a timer.

A simplified version of the Coccinelle semantic patch that performs
this transformation is as follows:

@change@
expression e1, e2, e3, e4, a, b;
@@

-init_timer(&e1);
+setup_timer(&e1, a, b);

... when != a = e2
    when != b = e3

-e1.data = b;
... when != a = e4
-e1.function = a;

Signed-off-by: Vaishali Thakkar <vthakkar1994@gmail.com>
---
 drivers/isdn/capi/capidrv.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/isdn/capi/capidrv.c b/drivers/isdn/capi/capidrv.c
index 1cc6ca8..85cfa4f 100644
--- a/drivers/isdn/capi/capidrv.c
+++ b/drivers/isdn/capi/capidrv.c
@@ -2264,7 +2264,7 @@ static int capidrv_addcontr(u16 contr, struct capi_profile *profp)
 		return -1;
 	}
 	card->owner = THIS_MODULE;
-	init_timer(&card->listentimer);
+	setup_timer(&card->listentimer, listentimerfunc, (unsigned long)card);
 	strcpy(card->name, id);
 	card->contrnr = contr;
 	card->nbchan = profp->nbchannel;
@@ -2331,8 +2331,6 @@ static int capidrv_addcontr(u16 contr, struct capi_profile *profp)
 	card->cipmask = 0x1FFF03FF;	/* any */
 	card->cipmask2 = 0;
 
-	card->listentimer.data = (unsigned long)card;
-	card->listentimer.function = listentimerfunc;
 	send_listen(card);
 	mod_timer(&card->listentimer, jiffies + 60 * HZ);
 
-- 
1.9.1
