From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] bna: fix sparse warnings/errors
Date: Wed, 04 Jan 2012 15:02:24 -0800
Message-ID: <20120104230239.111580138@vyatta.com>
References: <20120104230222.355802239@vyatta.com>
Cc: netdev@vger.kernel.org
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sfca-50.vyatta.com ([76.74.103.50]:45895 "EHLO fiji.vyatta.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757227Ab2ADXD7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jan 2012 18:03:59 -0500
Content-Disposition: inline; filename=bna-sparse.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a several sparse warnings.
  * the __iomem tag was being used incorrectly (needs to be a prefix)
  * several variables should have been static since local to one file
  * the firmware was not being forwared declared
    and was const one place and not the other

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/ethernet/brocade/bna/bna_types.h |    6 +++---
 drivers/net/ethernet/brocade/bna/bnad.c      |    6 +++---
 drivers/net/ethernet/brocade/bna/bnad.h      |    2 +-
 drivers/net/ethernet/brocade/bna/cna_fwimg.c |    1 +
 4 files changed, 8 insertions(+), 7 deletions(-)

--- a/drivers/net/ethernet/brocade/bna/bnad.c	2011-12-23 21:06:15.720436866 -0800
+++ b/drivers/net/ethernet/brocade/bna/bnad.c	2012-01-04 14:25:57.474471816 -0800
@@ -53,9 +53,9 @@ MODULE_PARM_DESC(bna_debugfs_enable, "En
  * Global variables
  */
 u32 bnad_rxqs_per_cq = 2;
-u32 bna_id;
-struct mutex bnad_list_mutex;
-LIST_HEAD(bnad_list);
+static u32 bna_id;
+static struct mutex bnad_list_mutex;
+static LIST_HEAD(bnad_list);
 static const u8 bnad_bcast_addr[] =  {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
 
 /*
--- a/drivers/net/ethernet/brocade/bna/bna_types.h	2011-12-23 21:06:15.720436866 -0800
+++ b/drivers/net/ethernet/brocade/bna/bna_types.h	2012-01-04 14:46:00.232255609 -0800
@@ -427,7 +427,7 @@ struct bna_ethport {
 
 /* Doorbell structure */
 struct bna_ib_dbell {
-	void *__iomem doorbell_addr;
+	void __iomem   *doorbell_addr;
 	u32		doorbell_ack;
 };
 
@@ -463,7 +463,7 @@ struct bna_tcb {
 	u32		consumer_index;
 	volatile u32	*hw_consumer_index;
 	u32		q_depth;
-	void *__iomem q_dbell;
+	void __iomem   *q_dbell;
 	struct bna_ib_dbell *i_dbell;
 	int			page_idx;
 	int			page_count;
@@ -599,7 +599,7 @@ struct bna_rcb {
 	u32		producer_index;
 	u32		consumer_index;
 	u32		q_depth;
-	void *__iomem q_dbell;
+	void __iomem   *q_dbell;
 	int			page_idx;
 	int			page_count;
 	/* Control path */
--- a/drivers/net/ethernet/brocade/bna/bnad.h	2011-12-23 21:06:15.724436897 -0800
+++ b/drivers/net/ethernet/brocade/bna/bnad.h	2012-01-04 14:37:34.562824877 -0800
@@ -347,7 +347,7 @@ struct bnad_drvinfo {
 /*
  * EXTERN VARIABLES
  */
-extern struct firmware *bfi_fw;
+extern const struct firmware *bfi_fw;
 extern u32		bnad_rxqs_per_cq;
 
 /*
--- a/drivers/net/ethernet/brocade/bna/cna_fwimg.c	2011-12-07 10:54:18.724278422 -0800
+++ b/drivers/net/ethernet/brocade/bna/cna_fwimg.c	2012-01-04 14:30:33.165920654 -0800
@@ -16,6 +16,7 @@
  * www.brocade.com
  */
 #include <linux/firmware.h>
+#include "bnad.h"
 #include "bfi.h"
 #include "cna.h"
 
