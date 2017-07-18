From: "Gustavo A. R. Silva" <gustavo-L1vi/lXTdts+Va1GwOuvDg@public.gmane.org>
Subject: [PATCH] wireless: airo: remove unnecessary static in writerids()
Date: Tue, 18 Jul 2017 15:37:11 -0500
Message-ID: <20170718203711.GA30044@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        "Gustavo A. R. Silva" <gustavo-L1vi/lXTdts+Va1GwOuvDg@public.gmane.org>
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Remove unnecessary static on local function pointer _writer_.
Such pointer is initialized before being used, on every
execution path throughout the function. The static has no
benefit and, removing it reduces the object file size.

This issue was detected using Coccinelle and the following semantic patch:

@bad exists@
position p;
identifier x;
type T;
@@

static T x@p;
...
x = <+...x...+>

@@
identifier x;
expression e;
type T;
position p != bad.p;
@@

-static
 T x@p;
 ... when != x
     when strict
?x = e;

In the following log you can see a significant difference in the object
file size. This log is the output of the size command, before and after
the code change:

before:
   text    data     bss     dec     hex filename
 113797   19152    1216  134165   20c15 drivers/net/wireless/cisco/airo.o

after:
   text	   data	    bss	    dec	    hex	filename
 113881	  19096	   1152	 134129	  20bf1	drivers/net/wireless/cisco/airo.o

Signed-off-by: Gustavo A. R. Silva <gustavo-L1vi/lXTdts+Va1GwOuvDg@public.gmane.org>
---
 drivers/net/wireless/cisco/airo.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/cisco/airo.c b/drivers/net/wireless/cisco/airo.c
index 84143a0..1066d84 100644
--- a/drivers/net/wireless/cisco/airo.c
+++ b/drivers/net/wireless/cisco/airo.c
@@ -7837,7 +7837,7 @@ static int writerids(struct net_device *dev, aironet_ioctl *comp) {
 	struct airo_info *ai = dev->ml_priv;
 	int  ridcode;
         int  enabled;
-	static int (* writer)(struct airo_info *, u16 rid, const void *, int, int);
+	int (*writer)(struct airo_info *, u16 rid, const void *, int, int);
 	unsigned char *iobuf;
 
 	/* Only super-user can write RIDs */
-- 
2.5.0
