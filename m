From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 1/5] ISDN-CAPI: Use kmalloc_array() in capidrv_addcontr()
Date: Sun, 25 Sep 2016 13:11:13 +0200
Message-ID: <f3c51d3b-ee3e-f877-40c2-898221ff0e67@users.sourceforge.net>
References: <be07f84d-fc84-e47d-207e-aedd8c960151@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: netdev@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <be07f84d-fc84-e47d-207e-aedd8c960151@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 25 Sep 2016 11:06:17 +0200

A multiplication for the size determination of a memory allocation
indicated that an array data structure should be processed.
Thus use the corresponding function "kmalloc_array".

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/isdn/capi/capidrv.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/isdn/capi/capidrv.c b/drivers/isdn/capi/capidrv.c
index 85cfa4f..cd8e1a6 100644
--- a/drivers/isdn/capi/capidrv.c
+++ b/drivers/isdn/capi/capidrv.c
@@ -2268,7 +2268,9 @@ static int capidrv_addcontr(u16 contr, struct capi_profile *profp)
 	strcpy(card->name, id);
 	card->contrnr = contr;
 	card->nbchan = profp->nbchannel;
-	card->bchans = kmalloc(sizeof(capidrv_bchan) * card->nbchan, GFP_ATOMIC);
+	card->bchans = kmalloc_array(card->nbchan,
+				     sizeof(capidrv_bchan),
+				     GFP_ATOMIC);
 	if (!card->bchans) {
 		printk(KERN_WARNING
 		       "capidrv: (%s) Could not allocate bchan-structs.\n", id);
-- 
2.10.0
