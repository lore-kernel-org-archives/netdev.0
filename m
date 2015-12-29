From: Insu Yun <wuninsu@gmail.com>
Subject: [PATCH] cxgb4: correctly handling failed allocation
Date: Tue, 29 Dec 2015 17:20:11 -0500
Message-ID: <1451427611-32338-1-git-send-email-wuninsu@gmail.com>
Cc: taesoo@gatech.edu, yeongjin.jang@gatech.edu, insu@gatech.edu,
	changwoo@gatech.edu, Insu Yun <wuninsu@gmail.com>
To: hariprasad@chelsio.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since t4_alloc_mem can be failed in memory pressure,
if not properly handled, NULL dereference could be happened.

Signed-off-by: Insu Yun <wuninsu@gmail.com>
---
 drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c b/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c
index c308429..11dd91e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c
@@ -295,6 +295,10 @@ struct clip_tbl *t4_init_clip_tbl(unsigned int clipt_start,
 		INIT_LIST_HEAD(&ctbl->hash_list[i]);
 
 	cl_list = t4_alloc_mem(clipt_size*sizeof(struct clip_entry));
+	if (!cl_list) {
+		t4_free_mem(ctbl);
+		return NULL;
+	}
 	ctbl->cl_list = (void *)cl_list;
 
 	for (i = 0; i < clipt_size; i++) {
-- 
1.9.1
