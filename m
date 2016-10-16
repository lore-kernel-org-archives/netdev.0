From: Eric Leblond <eric@regit.org>
Subject: [PATCH 8/8] tools lib bpf: install header file
Date: Sun, 16 Oct 2016 23:18:34 +0200
Message-ID: <20161016211834.11732-9-eric@regit.org>
References: <20161016211834.11732-1-eric@regit.org>
Cc: linux-kernel@vger.kernel.org, ast@fb.com,
        Eric Leblond <eric@regit.org>
To: netdev@vger.kernel.org, wangnan0@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from home.regit.org ([37.187.126.138]:45275 "EHLO home.regit.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757243AbcJPVVU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 16 Oct 2016 17:21:20 -0400
In-Reply-To: <20161016211834.11732-1-eric@regit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Makefile was not installing the header file of the library and a
manual copy was needed to have a usable library on the system.

Signed-off-by: Eric Leblond <eric@regit.org>
---
 tools/lib/bpf/Makefile | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/tools/lib/bpf/Makefile b/tools/lib/bpf/Makefile
index 62d89d5..9525956 100644
--- a/tools/lib/bpf/Makefile
+++ b/tools/lib/bpf/Makefile
@@ -47,6 +47,7 @@ endif
 
 prefix ?= /usr/local
 libdir = $(prefix)/$(libdir_relative)
+includedir = $(prefix)/include/bpf
 man_dir = $(prefix)/share/man
 man_dir_SQ = '$(subst ','\'',$(man_dir))'
 
@@ -87,14 +88,16 @@ include $(FEATURES_DUMP)
 endif
 endif
 
-export prefix libdir src obj
+export prefix libdir includedir src obj
 
 # Shell quotes
 libdir_SQ = $(subst ','\'',$(libdir))
 libdir_relative_SQ = $(subst ','\'',$(libdir_relative))
+includedir_SQ = $(subst ','\'',$(includedir))
 plugin_dir_SQ = $(subst ','\'',$(plugin_dir))
 
 LIB_FILE = libbpf.a libbpf.so
+HEADER_FILE = libbpf.h
 
 VERSION		= $(BPF_VERSION)
 PATCHLEVEL	= $(BPF_PATCHLEVEL)
@@ -189,7 +192,11 @@ install_lib: all_cmd
 	$(call QUIET_INSTALL, $(LIB_FILE)) \
 		$(call do_install,$(LIB_FILE),$(libdir_SQ))
 
-install: install_lib
+install_header: all_cmd
+	$(call QUIET_INSTALL, $(HEADER_FILE)) \
+		$(call do_install,$(HEADER_FILE),$(includedir_SQ))
+
+install: install_lib install_header
 
 ### Cleaning rules
 
-- 
2.9.3
