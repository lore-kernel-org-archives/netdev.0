From: Jan Engelhardt <jengelh@inai.de>
Subject: [PATCH] build: resolve compile error due to missing include
Date: Wed, 17 Apr 2013 08:53:34 +0200
Message-ID: <1366181614-19837-1-git-send-email-jengelh@inai.de>
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:34946 "EHLO ares07.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757786Ab3DQGxh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Apr 2013 02:53:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I get a compilation error with linux-glibc-devel-2.6.32 (SLES 11 SP2):

ipnetns.c: In function 'netns_exec':
ipnetns.c:156: error: 'MS_SLAVE' undeclared (first use in this function)
ipnetns.c:156: error: (Each undeclared identifier is reported only once
ipnetns.c:156: error: for each function it appears in.)
ipnetns.c:156: error: 'MS_REC' undeclared (first use in this function)
ipnetns.c: In function 'netns_add':
ipnetns.c:372: error: 'MS_SHARED' undeclared (first use in this function)
ipnetns.c:372: error: 'MS_REC' undeclared (first use in this function)
make[1]: *** [ipnetns.o] Error 1

This patch fixes that.
---
 ip/ipnetns.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index b047b97..48b1ad5 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -14,6 +14,7 @@
 #include <errno.h>
 #include <unistd.h>
 #include <ctype.h>
+#include <linux/fs.h>
 
 #include "utils.h"
 #include "ip_common.h"
-- 
1.8.2
