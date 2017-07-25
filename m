From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2] bpf: install libbpf headers on 'make install'
Date: Tue, 25 Jul 2017 11:17:11 -0700
Message-ID: <20170725181711.21236-1-jakub.kicinski@netronome.com>
References: <20170724212236.21903-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org, daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33345 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750732AbdGYSRQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 14:17:16 -0400
Received: by mail-pf0-f170.google.com with SMTP id s70so61370223pfs.0
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 11:17:16 -0700 (PDT)
In-Reply-To: <20170724212236.21903-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new target to install the bpf.h header to $(prefix)/include/bpf/ 
directory.  This is necessary to build standalone applications using 
libbpf, without the need to clone the kernel sources and point to them.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
v2:
 - make the header installation similar to tools/lib/traceevent (Daniel).

The functional change is that the header will not be installed as part
of make install, one has to make install_headers, which seems OK.

Out of curiosity - why are only "force elfdep bpfdep" added to the PHONY
target?  Is there some Makefile magic that makes adding install* targets
there unnecessary?  Or does the PHONY target just not matter in practice
so it's not updated?

 tools/lib/bpf/Makefile | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/tools/lib/bpf/Makefile b/tools/lib/bpf/Makefile
index 1f5300e56b44..445289555487 100644
--- a/tools/lib/bpf/Makefile
+++ b/tools/lib/bpf/Makefile
@@ -189,6 +189,10 @@ install_lib: all_cmd
 	$(call QUIET_INSTALL, $(LIB_FILE)) \
 		$(call do_install,$(LIB_FILE),$(libdir_SQ))
 
+install_headers:
+	$(call QUIET_INSTALL, headers) \
+		$(call do_install,bpf.h,$(prefix)/include/bpf,644)
+
 install: install_lib
 
 ### Cleaning rules
-- 
2.11.0
