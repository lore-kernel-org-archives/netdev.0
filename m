From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next] bpf: install libbpf headers on 'make install'
Date: Mon, 24 Jul 2017 14:22:35 -0700
Message-ID: <20170724212236.21903-1-jakub.kicinski@netronome.com>
Cc: daniel@iogearbox.net, alexei.starovoitov@gmail.com,
        oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:32876 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755978AbdGXVWt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 17:22:49 -0400
Received: by mail-pg0-f50.google.com with SMTP id g14so13356182pgu.0
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 14:22:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Install the bpf.h header to $(prefix)/include/bpf/ directory.
This is necessary to build standalone applications using libbpf,
without the need to clone the kernel sources and point to them.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
I'm not 100% sure if it's OK to export the header file and which
directory it should end up in (bpf/? libbpf/?).

 tools/lib/bpf/Makefile | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/tools/lib/bpf/Makefile b/tools/lib/bpf/Makefile
index 1f5300e56b44..22dad416e0bd 100644
--- a/tools/lib/bpf/Makefile
+++ b/tools/lib/bpf/Makefile
@@ -46,6 +46,7 @@ else
 endif
 
 prefix ?= /usr/local
+headerdir = $(prefix)/include/bpf/
 libdir = $(prefix)/$(libdir_relative)
 man_dir = $(prefix)/share/man
 man_dir_SQ = '$(subst ','\'',$(man_dir))'
@@ -90,11 +91,13 @@ endif
 export prefix libdir src obj
 
 # Shell quotes
+headerdir_SQ = $(subst ','\'',$(headerdir))
 libdir_SQ = $(subst ','\'',$(libdir))
 libdir_relative_SQ = $(subst ','\'',$(libdir_relative))
 plugin_dir_SQ = $(subst ','\'',$(plugin_dir))
 
 LIB_FILE = libbpf.a libbpf.so
+HEADER_FILE = bpf.h
 
 VERSION		= $(BPF_VERSION)
 PATCHLEVEL	= $(BPF_PATCHLEVEL)
@@ -189,7 +192,11 @@ install_lib: all_cmd
 	$(call QUIET_INSTALL, $(LIB_FILE)) \
 		$(call do_install,$(LIB_FILE),$(libdir_SQ))
 
-install: install_lib
+install_hdr: all_cmd
+	$(call QUIET_INSTALL, $(HEADER_FILE)) \
+		$(call do_install,$(HEADER_FILE),$(headerdir_SQ))
+
+install: install_lib install_hdr
 
 ### Cleaning rules
 
-- 
2.11.0
