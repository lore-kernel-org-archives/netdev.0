From: akpm@osdl.org
Subject: [patch 04/13] IRDA: Replace hard-coded dev_self[] array sizes with ARRAY_SIZE()
Date: Mon, 14 Aug 2006 23:03:39 -0700
Message-ID: <200608150603.k7F63dbr012933@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, bjorn.helgaas@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:40851 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965160AbWHOGDp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:03:45 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bjorn Helgaas <bjorn.helgaas@hp.com>

Several IR drivers used "for (i = 0; i < 4; i++)" to walk their dev_self[]
table.  Better to use ARRAY_SIZE().  And fix ali-ircc so it won't run off
the end if we find too many adapters.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/irda/ali-ircc.c    |    8 +++++++-
 drivers/net/irda/irport.c      |    4 ++--
 drivers/net/irda/via-ircc.c    |    5 ++++-
 drivers/net/irda/w83977af_ir.c |    4 ++--
 4 files changed, 15 insertions(+), 6 deletions(-)

diff -puN drivers/net/irda/ali-ircc.c~irda-replace-hard-coded-dev_self-array-sizes-with-array_size drivers/net/irda/ali-ircc.c
--- a/drivers/net/irda/ali-ircc.c~irda-replace-hard-coded-dev_self-array-sizes-with-array_size
+++ a/drivers/net/irda/ali-ircc.c
@@ -249,7 +249,7 @@ static void __exit ali_ircc_cleanup(void
 
 	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__);	
 
-	for (i=0; i < 4; i++) {
+	for (i=0; i < ARRAY_SIZE(dev_self); i++) {
 		if (dev_self[i])
 			ali_ircc_close(dev_self[i]);
 	}
@@ -273,6 +273,12 @@ static int ali_ircc_open(int i, chipio_t
 	int err;
 			
 	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__);	
+
+	if (i >= ARRAY_SIZE(dev_self)) {
+		IRDA_ERROR("%s(), maximum number of supported chips reached!\n",
+			   __FUNCTION__);
+		return -ENOMEM;
+	}
 	
 	/* Set FIR FIFO and DMA Threshold */
 	if ((ali_ircc_setup(info)) == -1)
diff -puN drivers/net/irda/irport.c~irda-replace-hard-coded-dev_self-array-sizes-with-array_size drivers/net/irda/irport.c
--- a/drivers/net/irda/irport.c~irda-replace-hard-coded-dev_self-array-sizes-with-array_size
+++ a/drivers/net/irda/irport.c
@@ -1090,7 +1090,7 @@ static int __init irport_init(void)
 {
  	int i;
 
- 	for (i=0; (io[i] < 2000) && (i < 4); i++) {
+ 	for (i=0; (io[i] < 2000) && (i < ARRAY_SIZE(dev_self)); i++) {
  		if (irport_open(i, io[i], irq[i]) != NULL)
  			return 0;
  	}
@@ -1112,7 +1112,7 @@ static void __exit irport_cleanup(void)
 
         IRDA_DEBUG( 4, "%s()\n", __FUNCTION__);
 
-	for (i=0; i < 4; i++) {
+	for (i=0; i < ARRAY_SIZE(dev_self); i++) {
  		if (dev_self[i])
  			irport_close(dev_self[i]);
  	}
diff -puN drivers/net/irda/via-ircc.c~irda-replace-hard-coded-dev_self-array-sizes-with-array_size drivers/net/irda/via-ircc.c
--- a/drivers/net/irda/via-ircc.c~irda-replace-hard-coded-dev_self-array-sizes-with-array_size
+++ a/drivers/net/irda/via-ircc.c
@@ -279,7 +279,7 @@ static void via_ircc_clean(void)
 
 	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
 
-	for (i=0; i < 4; i++) {
+	for (i=0; i < ARRAY_SIZE(dev_self); i++) {
 		if (dev_self[i])
 			via_ircc_close(dev_self[i]);
 	}
@@ -327,6 +327,9 @@ static __devinit int via_ircc_open(int i
 
 	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
 
+	if (i >= ARRAY_SIZE(dev_self))
+		return -ENOMEM;
+
 	/* Allocate new instance of the driver */
 	dev = alloc_irdadev(sizeof(struct via_ircc_cb));
 	if (dev == NULL) 
diff -puN drivers/net/irda/w83977af_ir.c~irda-replace-hard-coded-dev_self-array-sizes-with-array_size drivers/net/irda/w83977af_ir.c
--- a/drivers/net/irda/w83977af_ir.c~irda-replace-hard-coded-dev_self-array-sizes-with-array_size
+++ a/drivers/net/irda/w83977af_ir.c
@@ -116,7 +116,7 @@ static int __init w83977af_init(void)
 
 	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
 
-	for (i=0; (io[i] < 2000) && (i < 4); i++) { 
+	for (i=0; (io[i] < 2000) && (i < ARRAY_SIZE(dev_self)); i++) {
 		if (w83977af_open(i, io[i], irq[i], dma[i]) == 0)
 			return 0;
 	}
@@ -135,7 +135,7 @@ static void __exit w83977af_cleanup(void
 
         IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
 
-	for (i=0; i < 4; i++) {
+	for (i=0; i < ARRAY_SIZE(dev_self); i++) {
 		if (dev_self[i])
 			w83977af_close(dev_self[i]);
 	}
_
