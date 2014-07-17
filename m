From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] iw_cxgb4: fix for 64-bit integer division
Date: Thu, 17 Jul 2014 22:31:03 +0530
Message-ID: <1405616463-23156-1-git-send-email-hariprasad@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Fixed error introduced in commit id 7730b4c (" cxgb4/iw_cxgb4: work request
logging feature") while compiling on 32 bit architecture reported by kbuild.

Signed-off-by: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/infiniband/hw/cxgb4/device.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/device.c b/drivers/infiniband/hw/cxgb4/device.c
index df1f1b5..bb0de61 100644
--- a/drivers/infiniband/hw/cxgb4/device.c
+++ b/drivers/infiniband/hw/cxgb4/device.c
@@ -33,6 +33,7 @@
 #include <linux/moduleparam.h>
 #include <linux/debugfs.h>
 #include <linux/vmalloc.h>
+#include <linux/math64.h>
 
 #include <rdma/ib_verbs.h>
 
@@ -150,7 +151,7 @@ static int wr_log_show(struct seq_file *seq, void *v)
 	int prev_ts_set = 0;
 	int idx, end;
 
-#define ts2ns(ts) ((ts) * dev->rdev.lldi.cclk_ps / 1000)
+#define ts2ns(ts) div64_ul((ts) * dev->rdev.lldi.cclk_ps , 1000)
 
 	idx = atomic_read(&dev->rdev.wr_log_idx) &
 		(dev->rdev.wr_log_size - 1);
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
