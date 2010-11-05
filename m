From: Joe Perches <joe@perches.com>
Subject: [PATCH 18/49] drivers/net/cxgb4: Use vzalloc
Date: Thu,  4 Nov 2010 20:07:42 -0700
Message-ID: <e208320e90dc0d7e77686cf8bf8131553f7a7b6e.1288925424.git.joe@perches.com>
References: <alpine.DEB.2.00.1011031108260.11625@router.home>
Cc: Dimitris Michailidis <dm@chelsio.com>, netdev@vger.kernel.org,
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
 drivers/net/cxgb4/cxgb4_main.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index f17703f..b7758ce 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -868,12 +868,11 @@ out:	release_firmware(fw);
  */
 void *t4_alloc_mem(size_t size)
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
