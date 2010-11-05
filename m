From: Joe Perches <joe@perches.com>
Subject: [PATCH 17/49] drivers/net/cxgb3: Use vzalloc
Date: Thu,  4 Nov 2010 20:07:41 -0700
Message-ID: <86e0ae42a56bc458519fa0a550bc3b1c50cd86bc.1288925424.git.joe@perches.com>
References: <alpine.DEB.2.00.1011031108260.11625@router.home>
Cc: Divy Le Ray <divy@chelsio.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1011031108260.11625@router.home>
In-Reply-To: <cover.1288925424.git.joe@perches.com>
References: <cover.1288925424.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/cxgb3/cxgb3_offload.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
index bcf0753..5e632e2 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -1164,12 +1164,11 @@ static void cxgb_redirect(struct dst_entry *old, struct dst_entry *new)
  */
 void *cxgb_alloc_mem(unsigned long size)
 {
-	void *p = kmalloc(size, GFP_KERNEL);
+	void *p = kzalloc(size, GFP_KERNEL);
 
 	if (!p)
-		p = vmalloc(size);
-	if (p)
-		memset(p, 0, size);
+		p = vzalloc(size);
+
 	return p;
 }
 
-- 
1.7.3.1.g432b3.dirty
