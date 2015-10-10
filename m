From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH] mISDN: use kstrdup() in dsp_pipeline_build
Date: Sat, 10 Oct 2015 02:32:15 -0700
Message-ID: <1efbeaf13aca3797e7d7f899ca00b27e37bbde9d.1444498002.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-16.163.com ([220.181.12.16]:44305 "EHLO m12-16.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751337AbbJJJd2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Oct 2015 05:33:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use kstrdup instead of strlen-kmalloc-strcpy.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 drivers/isdn/mISDN/dsp_pipeline.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/isdn/mISDN/dsp_pipeline.c b/drivers/isdn/mISDN/dsp_pipeline.c
index 8b1a66c..c60722d 100644
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
@@ -250,14 +250,9 @@ int dsp_pipeline_build(struct dsp_pipeline *pipeline, const char *cfg)
 	if (!cfg)
 		return 0;
 
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
