From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/10] skfp: Fix SysKonnect FDDI driver compile issues
Date: Wed, 24 Aug 2011 21:50:27 -0700
Message-ID: <1314247835-24586-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1314247835-24586-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, "Maciej W. Rozycki" <macro@linux-mips.org>,
	Christoph Goos <cgoos@syskonnect.de>, <linux@syskonnect.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55250 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752335Ab1HYEuj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Aug 2011 00:50:39 -0400
In-Reply-To: <1314247835-24586-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After moving the skfp driver, issues with the #include pathing to
their locel headers was somehow exposed.  Several headers had the
incorrect path, so they were not able to be found during compile
time.

This patch fixes up the path issues to the local headers that need
to be included.

CC: "Maciej W. Rozycki" <macro@linux-mips.org>
CC: Christoph Goos <cgoos@syskonnect.de>
CC: <linux@syskonnect.de>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/fddi/skfp/h/cmtdef.h   |    4 ++--
 drivers/net/fddi/skfp/h/hwmtm.h    |    2 +-
 drivers/net/fddi/skfp/h/sba.h      |    4 ++--
 drivers/net/fddi/skfp/h/skfbiinc.h |    2 +-
 drivers/net/fddi/skfp/h/smc.h      |   14 +++++++-------
 drivers/net/fddi/skfp/h/targethw.h |    6 +++---
 drivers/net/fddi/skfp/h/targetos.h |    2 +-
 7 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/fddi/skfp/h/cmtdef.h b/drivers/net/fddi/skfp/h/cmtdef.h
index 5a6c612..f5bc90f 100644
--- a/drivers/net/fddi/skfp/h/cmtdef.h
+++ b/drivers/net/fddi/skfp/h/cmtdef.h
@@ -477,8 +477,8 @@ struct s_plc {
 /*
  * function prototypes
  */
-#include "h/mbuf.h"	/* Type definitions for MBUFs */
-#include "h/smtstate.h"	/* struct smt_state */
+#include "mbuf.h"	/* Type definitions for MBUFs */
+#include "smtstate.h"	/* struct smt_state */
 
 void hwt_restart(struct s_smc *smc);	/* hwt.c */
 SMbuf *smt_build_frame(struct s_smc *smc, int class, int type,
diff --git a/drivers/net/fddi/skfp/h/hwmtm.h b/drivers/net/fddi/skfp/h/hwmtm.h
index e1a7e5f..5924d42 100644
--- a/drivers/net/fddi/skfp/h/hwmtm.h
+++ b/drivers/net/fddi/skfp/h/hwmtm.h
@@ -15,7 +15,7 @@
 #ifndef	_HWM_
 #define	_HWM_
 
-#include "h/mbuf.h"
+#include "mbuf.h"
 
 /*
  * MACRO for DMA synchronization:
diff --git a/drivers/net/fddi/skfp/h/sba.h b/drivers/net/fddi/skfp/h/sba.h
index 638cf02..35ddb44 100644
--- a/drivers/net/fddi/skfp/h/sba.h
+++ b/drivers/net/fddi/skfp/h/sba.h
@@ -19,8 +19,8 @@
 #ifndef _SBA_
 #define _SBA_
 
-#include "h/mbuf.h"
-#include "h/sba_def.h"
+#include "mbuf.h"
+#include "sba_def.h"
 
 #ifdef	SBA
 
diff --git a/drivers/net/fddi/skfp/h/skfbiinc.h b/drivers/net/fddi/skfp/h/skfbiinc.h
index ac2d719..ce72557 100644
--- a/drivers/net/fddi/skfp/h/skfbiinc.h
+++ b/drivers/net/fddi/skfp/h/skfbiinc.h
@@ -15,7 +15,7 @@
 #ifndef	_SKFBIINC_
 #define _SKFBIINC_
 
-#include "h/supern_2.h"
+#include "supern_2.h"
 
 /*
  * special defines for use into .asm files
diff --git a/drivers/net/fddi/skfp/h/smc.h b/drivers/net/fddi/skfp/h/smc.h
index c774a95..3ca308b 100644
--- a/drivers/net/fddi/skfp/h/smc.h
+++ b/drivers/net/fddi/skfp/h/smc.h
@@ -38,18 +38,18 @@
  *	fddi.h
  */
 #ifdef	OSDEF
-#include "h/osdef1st.h"
+#include "osdef1st.h"
 #endif	/* OSDEF */
 #ifdef	OEM_CONCEPT
 #include "oemdef.h"
 #endif	/* OEM_CONCEPT */
-#include "h/smt.h"
-#include "h/cmtdef.h"
-#include "h/fddimib.h"
-#include "h/targethw.h"		/* all target hw dependencies */
-#include "h/targetos.h"		/* all target os dependencies */
+#include "smt.h"
+#include "cmtdef.h"
+#include "fddimib.h"
+#include "targethw.h"		/* all target hw dependencies */
+#include "targetos.h"		/* all target os dependencies */
 #ifdef	ESS
-#include "h/sba.h"
+#include "sba.h"
 #endif
 
 /*
diff --git a/drivers/net/fddi/skfp/h/targethw.h b/drivers/net/fddi/skfp/h/targethw.h
index 626dc72..842a690 100644
--- a/drivers/net/fddi/skfp/h/targethw.h
+++ b/drivers/net/fddi/skfp/h/targethw.h
@@ -25,11 +25,11 @@
 #define SK_ML_ID_2	0x30
 #endif
 
-#include	"h/skfbi.h"
+#include	"skfbi.h"
 #ifndef TAG_MODE	
-#include	"h/fplus.h"
+#include	"fplus.h"
 #else
-#include	"h/fplustm.h"
+#include	"fplustm.h"
 #endif
 
 #ifndef	HW_PTR
diff --git a/drivers/net/fddi/skfp/h/targetos.h b/drivers/net/fddi/skfp/h/targetos.h
index 5d940e7..53bacc1 100644
--- a/drivers/net/fddi/skfp/h/targetos.h
+++ b/drivers/net/fddi/skfp/h/targetos.h
@@ -58,7 +58,7 @@
 #define	ADDR(a) (((a)>>7) ? (outp(smc->hw.iop+B0_RAP,(a)>>7), (smc->hw.iop+( ((a)&0x7F) | ((a)>>7 ? 0x80:0)) )) : (smc->hw.iop+(((a)&0x7F)|((a)>>7 ? 0x80:0))))
 #endif
 
-#include "h/hwmtm.h"
+#include "hwmtm.h"
 
 #define TRUE  1
 #define FALSE 0
-- 
1.7.6
