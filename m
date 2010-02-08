From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 16/41] CAPI: Use non-atomic allocation during NCCI setup
Date: Mon,  8 Feb 2010 21:12:20 +0100
Message-ID: <677229a3b0c5ffd5aea3e6ec7f9879197df56ea1.1265659935.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Both capincci_alloc and capiminor_alloc run in non-atomic context,
update their memory allocations accordingly.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 403bf8f..f8f8660 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -217,7 +217,7 @@ static struct capiminor *capiminor_alloc(struct capi20_appl *ap, u32 ncci)
 	unsigned int minor = 0;
 	unsigned long flags;
 
-	mp = kzalloc(sizeof(*mp), GFP_ATOMIC);
+	mp = kzalloc(sizeof(*mp), GFP_KERNEL);
   	if (!mp) {
   		printk(KERN_ERR "capi: can't alloc capiminor\n");
 		return NULL;
@@ -358,7 +358,7 @@ static struct capincci *capincci_alloc(struct capidev *cdev, u32 ncci)
 {
 	struct capincci *np, **pp;
 
-	np = kzalloc(sizeof(*np), GFP_ATOMIC);
+	np = kzalloc(sizeof(*np), GFP_KERNEL);
 	if (!np)
 		return NULL;
 	np->ncci = ncci;
-- 
1.6.0.2
