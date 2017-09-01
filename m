From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 4/6] ipxfrm: Replace STRBUF_CAT macro with strlcat()
Date: Fri,  1 Sep 2017 18:52:54 +0200
Message-ID: <20170901165256.21459-5-phil@nwl.cc>
References: <20170901165256.21459-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:52195 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752148AbdIAQxV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 12:53:21 -0400
In-Reply-To: <20170901165256.21459-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipxfrm.c | 21 +++++----------------
 1 file changed, 5 insertions(+), 16 deletions(-)

diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index d5eb22e25476a..12c2f721571b6 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -40,17 +40,6 @@
 #include "ip_common.h"
 
 #define STRBUF_SIZE	(128)
-#define STRBUF_CAT(buf, str) \
-	do { \
-		int rest = sizeof(buf) - 1 - strlen(buf); \
-		if (rest > 0) { \
-			int len = strlen(str); \
-			if (len > rest) \
-				len = rest; \
-			strncat(buf, str, len); \
-			buf[sizeof(buf) - 1] = '\0'; \
-		} \
-	} while (0);
 
 struct xfrm_filter filter;
 
@@ -902,8 +891,8 @@ void xfrm_state_info_print(struct xfrm_usersa_info *xsinfo,
 			   prefix, title);
 
 	if (prefix)
-		STRBUF_CAT(buf, prefix);
-	STRBUF_CAT(buf, "\t");
+		strlcat(buf, prefix, sizeof(buf));
+	strlcat(buf, "\t", sizeof(buf));
 
 	fputs(buf, fp);
 	fprintf(fp, "replay-window %u ", xsinfo->replay_window);
@@ -944,7 +933,7 @@ void xfrm_state_info_print(struct xfrm_usersa_info *xsinfo,
 		char sbuf[STRBUF_SIZE];
 
 		memcpy(sbuf, buf, sizeof(sbuf));
-		STRBUF_CAT(sbuf, "sel ");
+		strlcat(sbuf, "sel ", sizeof(sbuf));
 
 		xfrm_selector_print(&xsinfo->sel, xsinfo->family, fp, sbuf);
 	}
@@ -992,8 +981,8 @@ void xfrm_policy_info_print(struct xfrm_userpolicy_info *xpinfo,
 	}
 
 	if (prefix)
-		STRBUF_CAT(buf, prefix);
-	STRBUF_CAT(buf, "\t");
+		strlcat(buf, prefix, sizeof(buf));
+	strlcat(buf, "\t", sizeof(buf));
 
 	fputs(buf, fp);
 	if (xpinfo->dir >= XFRM_POLICY_MAX) {
-- 
2.13.1
