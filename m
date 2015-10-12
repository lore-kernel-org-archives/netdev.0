From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH v2] mISDN: use kstrdup() in dsp_pipeline_build
Date: Mon, 12 Oct 2015 01:19:07 -0700
Message-ID: <01134401b5d955b4dd794562d85608db4fb8ba21.1444666330.git.geliangtang@163.com>
References: <1444504930.8012.19.camel@perches.com>
Cc: Geliang Tang <geliangtang@163.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>, Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444504930.8012.19.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use kstrdup instead of strlen-kmalloc-strcpy. Remove unneeded NULL
test, it will be tested inside kstrdup. Remove 0 length string test,
it has been tested in the caller of dsp_pipeline_build.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
Changes in v2:
  - Remove unneeded NULL test.
---
 drivers/isdn/mISDN/dsp_pipeline.c | 12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/drivers/isdn/mISDN/dsp_pipeline.c b/drivers/isdn/mISDN/dsp_pipeline.c
index 8b1a66c..e72b4e7 100644
--- a/drivers/isdn/mISDN/dsp_pipeline.c
+++ b/drivers/isdn/mISDN/dsp_pipeline.c
@@ -235,7 +235,7 @@ void dsp_pipeline_destroy(struct dsp_pipeline *pipeline)
 
 int dsp_pipeline_build(struct dsp_pipeline *pipeline, const char *cfg)
 {
-	int len, incomplete = 0, found = 0;
+	int incomplete = 0, found = 0;
 	char *dup, *tok, *name, *args;
 	struct dsp_element_entry *entry, *n;
 	struct dsp_pipeline_entry *pipeline_entry;
@@ -247,17 +247,9 @@ int dsp_pipeline_build(struct dsp_pipeline *pipeline, const char *cfg)
 	if (!list_empty(&pipeline->list))
 		_dsp_pipeline_destroy(pipeline);
 
-	if (!cfg)
-		return 0;
-
-	len = strlen(cfg);
-	if (!len)
-		return 0;
-
-	dup = kmalloc(len + 1, GFP_ATOMIC);
+	dup = kstrdup(cfg, GFP_ATOMIC);
 	if (!dup)
 		return 0;
-	strcpy(dup, cfg);
 	while ((tok = strsep(&dup, "|"))) {
 		if (!strlen(tok))
 			continue;
-- 
1.9.1
