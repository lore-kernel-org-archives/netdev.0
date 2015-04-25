From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH iputils] ping: fix -i number parsing in locales
Date: Fri, 24 Apr 2015 20:45:42 -0400
Message-ID: <1429922742-14285-1-git-send-email-vapier@gentoo.org>
Cc: netdev@vger.kernel.org,
	David Heidelberger <david.heidelberger@ixit.cz>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:49387 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755714AbbDYApt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Apr 2015 20:45:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Always use #.# format for the -i flag even when the current locale uses
a different separator.  Locale de_DE which uses #,# normally.

Simple testcase:
$ make USE_IDN=1
$ LANG=de_DE.UTF8 ./ping -i 0.5 localhost

Reported-by: Sergey Fionov <fionov@gmail.com>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 ping_common.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/ping_common.c b/ping_common.c
index 62f53a6..0a37e09 100644
--- a/ping_common.c
+++ b/ping_common.c
@@ -269,9 +269,17 @@ void common_options(int ch)
 		double dbl;
 		char *ep;
 
+#ifdef USE_IDN
+		setlocale(LC_ALL, "C");
+#endif
+
 		errno = 0;
 		dbl = strtod(optarg, &ep);
 
+#ifdef USE_IDN
+		setlocale(LC_ALL, "");
+#endif
+
 		if (errno || *ep != '\0' ||
 		    !finite(dbl) || dbl < 0.0 || dbl >= (double)INT_MAX / 1000 - 1.0) {
 			fprintf(stderr, "ping: bad timing interval\n");
-- 
2.3.5
