From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH [iputils] 4/5] fix handling of CFLAGS
Date: Sat, 19 Apr 2014 10:43:16 -0400
Message-ID: <1397918597-8680-4-git-send-email-vapier@gentoo.org>
References: <1397918597-8680-1-git-send-email-vapier@gentoo.org>
Cc: netdev@vger.kernel.org,
	David Heidelberger <david.heidelberger@ixit.cz>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:48268 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751452AbaDSOnT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Apr 2014 10:43:19 -0400
In-Reply-To: <1397918597-8680-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This defaults CFLAGS to -O3 without clobbering settings people have set
up in the environment already.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 Makefile | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/Makefile b/Makefile
index 2c49940..ecabac3 100644
--- a/Makefile
+++ b/Makefile
@@ -2,8 +2,6 @@
 # Configuration
 #
 
-# CC
-CC=gcc
 # Path to parent kernel include files directory
 LIBC_INCLUDE=/usr/include
 # Libraries
@@ -48,11 +46,10 @@ ENABLE_RDISC_SERVER=no
 
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
@@ -113,7 +110,6 @@ IPV4_TARGETS=tracepath ping clockdiff rdisc arping tftpd rarpd
 IPV6_TARGETS=tracepath6 traceroute6 ping6
 TARGETS=$(IPV4_TARGETS) $(IPV6_TARGETS)
 
-CFLAGS=$(CCOPTOPT) $(CCOPT) $(GLIBCFIX) $(DEFINES)
 LDLIBS=$(LDLIB) $(ADDLIB)
 
 UNAME_N:=$(shell uname -n)
@@ -132,6 +128,7 @@ all: $(TARGETS)
 	$(COMPILE.c) $< $(DEF_$(patsubst %.o,%,$@)) -S -o $@
 %.o: %.c
 	$(COMPILE.c) $< $(DEF_$(patsubst %.o,%,$@)) -o $@
+LINK.o += $(CFLAGS)
 $(TARGETS): %: %.o
 	$(LINK.o) $^ $(LIB_$@) $(LDLIBS) -o $@
 
-- 
1.9.2
