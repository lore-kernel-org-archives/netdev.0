From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v2 11/11] [EXPERIMENTAL] Kbuild: enable -Wmissing-include-dirs by default
Date: Wed, 15 Jun 2016 17:45:53 +0200
Message-ID: <20160615154553.3177021-12-arnd@arndb.de>
References: <20160615154553.3177021-1-arnd@arndb.de>
Cc: linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	dri-devel@lists.freedesktop.org, Arnd Bergmann <arnd@arndb.de>
To: Michal Marek <mmarek@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:60807 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933302AbcFOPpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 11:45:13 -0400
In-Reply-To: <20160615154553.3177021-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have fixed up all -Wmissing-include-dirs on ARM randconfig builds,
so we could make this the default, but I have not tested this at all
on other architectures.

This enables it anyway, just to see what other warnings we get
when the build bot analyses the branch.

Don't apply (yet).

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 Makefile | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/Makefile b/Makefile
index 969924783543..2305cbd61e60 100644
--- a/Makefile
+++ b/Makefile
@@ -781,6 +781,9 @@ endif
 NOSTDINC_FLAGS += -nostdinc -isystem $(shell $(CC) -print-file-name=include)
 CHECKFLAGS     += $(NOSTDINC_FLAGS)
 
+# warn about incorrect -I include paths
+KBUILD_CFLAGS += -Wmissing-include-dirs
+
 # warn about C99 declaration after statement
 KBUILD_CFLAGS += $(call cc-option,-Wdeclaration-after-statement,)
 
-- 
2.9.0
