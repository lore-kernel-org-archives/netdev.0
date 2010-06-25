From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH 3/9] cxgb4vf: Add new macros and definitions for hardware constants
Date: Fri, 25 Jun 2010 15:11:05 -0700
Message-ID: <201006251511.06025.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:15146 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756403Ab0FYWLG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 18:11:06 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o5PMB7vk019391
	for <netdev@vger.kernel.org>; Fri, 25 Jun 2010 15:11:07 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add new macros and definitions for hardware constants.

Signed-off-by: Casey Leedom
---
 drivers/net/cxgb4/t4_hw.h   |   39 +++++++++++++++++++++++++++++++++++++++
 drivers/net/cxgb4/t4_regs.h |    3 +++
 2 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb4/t4_hw.h b/drivers/net/cxgb4/t4_hw.h
index 98c02be..e875d09 100644
--- a/drivers/net/cxgb4/t4_hw.h
+++ b/drivers/net/cxgb4/t4_hw.h
@@ -67,6 +67,45 @@ enum {
 	SGE_MAX_WR_LEN = 512,     /* max WR size in bytes */
 	SGE_NTIMERS = 6,          /* # of interrupt holdoff timer values */
 	SGE_NCOUNTERS = 4,        /* # of interrupt packet counter values */
+
+	SGE_TIMER_RSTRT_CNTR = 6, /* restart RX packet threshold counter */
+	SGE_TIMER_UPD_CIDX = 7,   /* update cidx only */
+
+	SGE_EQ_IDXSIZE = 64,      /* egress queue pidx/cidx unit size */
+
+	SGE_INTRDST_PCI = 0,      /* interrupt destination is PCI-E */
+	SGE_INTRDST_IQ = 1,       /*   destination is an ingress queue */
+
+	SGE_UPDATEDEL_NONE = 0,   /* ingress queue pidx update delivery */
+	SGE_UPDATEDEL_INTR = 1,   /*   interrupt */
+	SGE_UPDATEDEL_STPG = 2,   /*   status page */
+	SGE_UPDATEDEL_BOTH = 3,   /*   interrupt and status page */
+
+	SGE_HOSTFCMODE_NONE = 0,  /* egress queue cidx updates */
+	SGE_HOSTFCMODE_IQ = 1,    /*   sent to ingress queue */
+	SGE_HOSTFCMODE_STPG = 2,  /*   sent to status page */
+	SGE_HOSTFCMODE_BOTH = 3,  /*   ingress queue and status page */
+
+	SGE_FETCHBURSTMIN_16B = 0,/* egress queue descriptor fetch minimum */
+	SGE_FETCHBURSTMIN_32B = 1,
+	SGE_FETCHBURSTMIN_64B = 2,
+	SGE_FETCHBURSTMIN_128B = 3,
+
+	SGE_FETCHBURSTMAX_64B = 0,/* egress queue descriptor fetch maximum */
+	SGE_FETCHBURSTMAX_128B = 1,
+	SGE_FETCHBURSTMAX_256B = 2,
+	SGE_FETCHBURSTMAX_512B = 3,
+
+	SGE_CIDXFLUSHTHRESH_1 = 0,/* egress queue cidx flush threshold */
+	SGE_CIDXFLUSHTHRESH_2 = 1,
+	SGE_CIDXFLUSHTHRESH_4 = 2,
+	SGE_CIDXFLUSHTHRESH_8 = 3,
+	SGE_CIDXFLUSHTHRESH_16 = 4,
+	SGE_CIDXFLUSHTHRESH_32 = 5,
+	SGE_CIDXFLUSHTHRESH_64 = 6,
+	SGE_CIDXFLUSHTHRESH_128 = 7,
+
+	SGE_INGPADBOUNDARY_SHIFT = 5,/* ingress queue pad boundary */
 };
 
 struct sge_qstat {                /* data written to SGE queue status entries 
*/
diff --git a/drivers/net/cxgb4/t4_regs.h b/drivers/net/cxgb4/t4_regs.h
index 8fed46d..bf21c14 100644
--- a/drivers/net/cxgb4/t4_regs.h
+++ b/drivers/net/cxgb4/t4_regs.h
@@ -93,12 +93,15 @@
 #define  PKTSHIFT_MASK          0x00001c00U
 #define  PKTSHIFT_SHIFT         10
 #define  PKTSHIFT(x)            ((x) << PKTSHIFT_SHIFT)
+#define  PKTSHIFT_GET(x)	(((x) & PKTSHIFT_MASK) >> PKTSHIFT_SHIFT)
 #define  INGPCIEBOUNDARY_MASK   0x00000380U
 #define  INGPCIEBOUNDARY_SHIFT  7
 #define  INGPCIEBOUNDARY(x)     ((x) << INGPCIEBOUNDARY_SHIFT)
 #define  INGPADBOUNDARY_MASK    0x00000070U
 #define  INGPADBOUNDARY_SHIFT   4
 #define  INGPADBOUNDARY(x)      ((x) << INGPADBOUNDARY_SHIFT)
+#define  INGPADBOUNDARY_GET(x)	(((x) & INGPADBOUNDARY_MASK) \
+				 >> INGPADBOUNDARY_SHIFT)
 #define  EGRPCIEBOUNDARY_MASK   0x0000000eU
 #define  EGRPCIEBOUNDARY_SHIFT  1
 #define  EGRPCIEBOUNDARY(x)     ((x) << EGRPCIEBOUNDARY_SHIFT)
