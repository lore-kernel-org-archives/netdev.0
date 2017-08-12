From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 26/51] lnstat_util: Simplify alloc_and_open() a bit
Date: Sat, 12 Aug 2017 14:04:45 +0200
Message-ID: <20170812120510.28750-27-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:44083 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751977AbdHLMGc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:06:32 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Relying upon callers and using unsafe strcpy() is probably not the best
idea. Aside from that, using snprintf() allows to format the string for
lf->path in one go.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/lnstat_util.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/misc/lnstat_util.c b/misc/lnstat_util.c
index cc54598fe1bef..ec19238c24b94 100644
--- a/misc/lnstat_util.c
+++ b/misc/lnstat_util.c
@@ -180,11 +180,8 @@ static struct lnstat_file *alloc_and_open(const char *path, const char *file)
 	}
 
 	/* initialize */
-	/* de->d_name is guaranteed to be <= NAME_MAX */
-	strcpy(lf->basename, file);
-	strcpy(lf->path, path);
-	strcat(lf->path, "/");
-	strcat(lf->path, lf->basename);
+	snprintf(lf->basename, sizeof(lf->basename), "%s", file);
+	snprintf(lf->path, sizeof(lf->path), "%s/%s", path, file);
 
 	/* initialize to default */
 	lf->interval.tv_sec = 1;
-- 
2.13.1
