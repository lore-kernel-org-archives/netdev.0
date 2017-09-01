From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 6/6] lnstat_util: Make sure buffer is NUL-terminated
Date: Fri,  1 Sep 2017 18:52:56 +0200
Message-ID: <20170901165256.21459-7-phil@nwl.cc>
References: <20170901165256.21459-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:36895 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752148AbdIAQxe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 12:53:34 -0400
In-Reply-To: <20170901165256.21459-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Can't use strlcpy() here since lnstat is not linked against libutil.

While being at it, fix coding style in that chunk as well.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/lnstat_util.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/misc/lnstat_util.c b/misc/lnstat_util.c
index ec19238c24b94..c2dc42ec1ff12 100644
--- a/misc/lnstat_util.c
+++ b/misc/lnstat_util.c
@@ -150,7 +150,8 @@ static int lnstat_scan_compat_rtstat_fields(struct lnstat_file *lf)
 {
 	char buf[FGETS_BUF_SIZE];
 
-	strncpy(buf, RTSTAT_COMPAT_LINE, sizeof(buf)-1);
+	strncpy(buf, RTSTAT_COMPAT_LINE, sizeof(buf) - 1);
+	buf[sizeof(buf) - 1] = '\0';
 
 	return __lnstat_scan_fields(lf, buf);
 }
-- 
2.13.1
