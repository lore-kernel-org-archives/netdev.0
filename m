From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH [iputils] 6/6] fix handling of CFLAGS
Date: Fri, 25 Jan 2013 00:24:15 -0500
Message-ID: <1359091455-25380-6-git-send-email-vapier@gentoo.org>
References: <1359091455-25380-1-git-send-email-vapier@gentoo.org>
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:38489 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751372Ab3AYFYQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 00:24:16 -0500
In-Reply-To: <1359091455-25380-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This defaults CFLAGS to -O3 without clobbering settings people have set
up in the environment already.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 Makefile | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/Makefile b/Makefile
index 2c49940..dc317b1 100644
--- a/Makefile
+++ b/Makefile
@@ -48,11 +48,10 @@ ENABLE_RDISC_SERVER=no
 
 # -------------------------------------
 # What a pity, all new gccs are buggy and -Werror does not work. Sigh.
-# CCOPT=-fno-strict-aliasing -Wstrict-prototypes -Wall -Werror -g
-CCOPT=-fno-strict-aliasing -Wstrict-prototypes -Wall -g
-CCOPTOPT=-O3
-GLIBCFIX=-D_GNU_SOURCE
-DEFINES=
+# CFLAGS+=-fno-strict-aliasing -Wstrict-prototypes -Wall -Werror -g
+CFLAGS?=-O3 -g
+CFLAGS+=-fno-strict-aliasing -Wstrict-prototypes -Wall
+CPPFLAGS+=-D_GNU_SOURCE
 LDLIB=
 
 FUNC_LIB = $(if $(filter static,$(1)),$(LDFLAG_STATIC) $(2) $(LDFLAG_DYNAMIC),$(2))
@@ -113,7 +112,6 @@ IPV4_TARGETS=tracepath ping clockdiff rdisc arping tftpd rarpd
 IPV6_TARGETS=tracepath6 traceroute6 ping6
 TARGETS=$(IPV4_TARGETS) $(IPV6_TARGETS)
 
-CFLAGS=$(CCOPTOPT) $(CCOPT) $(GLIBCFIX) $(DEFINES)
 LDLIBS=$(LDLIB) $(ADDLIB)
 
 UNAME_N:=$(shell uname -n)
-- 
1.8.0.2
