From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH 16/31] CAPI: Use non-atomic allocation during NCCI setup
Date: Thu, 7 Jan 2010 20:21:27 +0100
Message-ID: <f50c2e3550cc0a8b8ce118a601685df6448031f7.1264201407.git.jan.kiszka@web.de>
References: <cover.1264201406.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755710Ab0AVXYP@vger.kernel.org>
In-Reply-To: <cover.1264201406.git.jan.kiszka@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Both capincci_alloc and capiminor_alloc run in non-atomic context,
update their memory allocations accordingly.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index e7830b7..b71b8b1 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -216,7 +216,7 @@ static struct capiminor *capiminor_alloc(struct capi20_appl *ap, u32 ncci)
 	unsigned int minor = 0;
 	unsigned long flags;
 
-	mp = kzalloc(sizeof(*mp), GFP_ATOMIC);
+	mp = kzalloc(sizeof(*mp), GFP_KERNEL);
   	if (!mp) {
   		printk(KERN_ERR "capi: can't alloc capiminorn");
 		return NULL;
@@ -357,7 +357,7 @@ static struct capincci *capincci_alloc(struct capidev *cdev, u32 ncci)
 {
 	struct capincci *np, **pp;
 
-	np = kzalloc(sizeof(*np), GFP_ATOMIC);
+	np = kzalloc(sizeof(*np), GFP_KERNEL);
 	if (!np)
 		return NULL;
 	np->ncci = ncci;
-- 
1.6.0.2
