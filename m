From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH iputils 6/6] ping: fix -i number parsing in locales
Date: Tue, 31 May 2016 23:48:25 -0400
Message-ID: <1464752905-10347-6-git-send-email-vapier@gentoo.org>
References: <1464752905-10347-1-git-send-email-vapier@gentoo.org>
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:58832 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756726AbcFADsb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 May 2016 23:48:31 -0400
In-Reply-To: <1464752905-10347-1-git-send-email-vapier@gentoo.org>
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
2.8.2
