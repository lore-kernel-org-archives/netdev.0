From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 5/5] iw_cxgb4: Don't limit TPTE count to 32KB
Date: Mon, 21 Jul 2014 20:55:16 +0530
Message-ID: <1405956316-13591-6-git-send-email-hariprasad@chelsio.com>
References: <1405956316-13591-1-git-send-email-hariprasad@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1405956316-13591-1-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Use the size advertised by FW

Signed-off-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Signed-off-by: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h |    2 +-
 drivers/infiniband/hw/cxgb4/t4.h       |    1 -
 2 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
index 69f047c..c378fd2 100644
--- a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
+++ b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
@@ -193,7 +193,7 @@ static inline int c4iw_fatal_error(struct c4iw_rdev *rdev)
 
 static inline int c4iw_num_stags(struct c4iw_rdev *rdev)
 {
-	return min((int)T4_MAX_NUM_STAG, (int)(rdev->lldi.vr->stag.size >> 5));
+	return (int)(rdev->lldi.vr->stag.size >> 5);
 }
 
 #define C4IW_WR_TO (30*HZ)
diff --git a/drivers/infiniband/hw/cxgb4/t4.h b/drivers/infiniband/hw/cxgb4/t4.h
index 641ab55..df5edfa 100644
--- a/drivers/infiniband/hw/cxgb4/t4.h
+++ b/drivers/infiniband/hw/cxgb4/t4.h
@@ -37,7 +37,6 @@
 #include "t4fw_ri_api.h"
 
 #define T4_MAX_NUM_PD 65536
-#define T4_MAX_NUM_STAG (1<<15)
 #define T4_MAX_MR_SIZE (~0ULL)
 #define T4_PAGESIZE_MASK 0xffff000  /* 4KB-128MB */
 #define T4_STAG_UNSET 0xffffffff
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
