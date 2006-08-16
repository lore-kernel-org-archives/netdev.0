From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 12/13] ixgb: fix cache miss due to miscalculation
Date: Wed, 16 Aug 2006 14:56:42 -0700
Message-ID: <20060816215642.27080.63751.stgit@gitlost.site>
References: <20060816215336.27080.56147.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:2058 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932262AbWHPVsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 17:48:54 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060816215336.27080.56147.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Reduce writeback threshold by 1. We were instructing the hardware to
wait until the 17th descriptor which went over the cache line limit.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke.jan.h.kok@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 7bbd447..770eef2 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -140,12 +140,12 @@ module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
 /* some defines for controlling descriptor fetches in h/w */
-#define RXDCTL_WTHRESH_DEFAULT 16	/* chip writes back at this many or RXT0 */
-#define RXDCTL_PTHRESH_DEFAULT 0		/* chip considers prefech below
-						 * this */
-#define RXDCTL_HTHRESH_DEFAULT 0		/* chip will only prefetch if tail
-						 * is pushed this many descriptors
-						 * from head */
+#define RXDCTL_WTHRESH_DEFAULT 15  /* chip writes back at this many or RXT0 */
+#define RXDCTL_PTHRESH_DEFAULT 0   /* chip considers prefech below
+                                    * this */
+#define RXDCTL_HTHRESH_DEFAULT 0   /* chip will only prefetch if tail
+                                    * is pushed this many descriptors
+                                    * from head */
 
 /**
  * ixgb_init_module - Driver Registration Routine



--
Auke Kok <auke-jan.h.kok@intel.com>
