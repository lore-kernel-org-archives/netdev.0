From: akpm@osdl.org
Subject: [patch 6/8] drivers/char/hw_random.c: remove assert()'s
Date: Thu, 08 Jun 2006 22:19:47 -0700
Message-ID: <200606090519.k595JlHj032029@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:53980 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965171AbWFIFXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2006 01:23:10 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Adrian Bunk <bunk@stusta.de>

Remove the assert()'s from drivers/char/hw_random.c since you both needed
to enable a manual option in the driver source to make them effective and
they only covered some obviously impossible cases.

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/char/hw_random.c |   21 ---------------------
 1 files changed, 21 deletions(-)

diff -puN drivers/char/hw_random.c~drivers-char-hw_randomc-remove-asserts drivers/char/hw_random.c
--- 25/drivers/char/hw_random.c~drivers-char-hw_randomc-remove-asserts	Mon May  8 12:03:00 2006
+++ 25-akpm/drivers/char/hw_random.c	Mon May  8 12:03:00 2006
@@ -66,17 +66,6 @@
 #define DPRINTK(fmt, args...) pr_debug(PFX "%s: " fmt, __FUNCTION__ , ## args)
 
 
-#undef RNG_NDEBUG        /* define to enable lightweight runtime checks */
-#ifdef RNG_NDEBUG
-#define assert(expr)							\
-		if(!(expr)) {						\
-		printk(KERN_DEBUG PFX "Assertion failed! %s,%s,%s,"	\
-		"line=%d\n", #expr, __FILE__, __FUNCTION__, __LINE__);	\
-		}
-#else
-#define assert(expr)
-#endif
-
 #define RNG_MISCDEV_MINOR		183 /* official */
 
 static int rng_dev_open (struct inode *inode, struct file *filp);
@@ -211,29 +200,23 @@ static void __iomem *rng_mem;
 
 static inline u8 intel_hwstatus (void)
 {
-	assert (rng_mem != NULL);
 	return readb (rng_mem + INTEL_RNG_HW_STATUS);
 }
 
 static inline u8 intel_hwstatus_set (u8 hw_status)
 {
-	assert (rng_mem != NULL);
 	writeb (hw_status, rng_mem + INTEL_RNG_HW_STATUS);
 	return intel_hwstatus ();
 }
 
 static unsigned int intel_data_present(void)
 {
-	assert (rng_mem != NULL);
-
 	return (readb (rng_mem + INTEL_RNG_STATUS) & INTEL_RNG_DATA_PRESENT) ?
 		1 : 0;
 }
 
 static u32 intel_data_read(void)
 {
-	assert (rng_mem != NULL);
-
 	return readb (rng_mem + INTEL_RNG_DATA);
 }
 
@@ -495,7 +478,6 @@ static u32 geode_data_read(void)
 {
 	u32 val;
 
-	assert(geode_rng_base != NULL);
 	val = readl(geode_rng_base + GEODE_RNG_DATA_REG);
 	return val;
 }
@@ -504,7 +486,6 @@ static unsigned int geode_data_present(v
 {
 	u32 val;
 
-	assert(geode_rng_base != NULL);
 	val = readl(geode_rng_base + GEODE_RNG_STATUS_REG);
 	return val;
 }
@@ -605,8 +586,6 @@ static int __init rng_init_one (struct p
 
 	DPRINTK ("ENTER\n");
 
-	assert(rng_ops != NULL);
-
 	rc = rng_ops->init(dev);
 	if (rc)
 		goto err_out;
_
