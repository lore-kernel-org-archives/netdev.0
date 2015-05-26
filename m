From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH iproute2] enable transparent LFS
Date: Tue, 26 May 2015 02:51:30 -0400
Message-ID: <1432623090-2264-1-git-send-email-vapier@gentoo.org>
To: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:58344 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751486AbbEZGvj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 May 2015 02:51:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@chromium.org>

Make sure we use 64-bit filesystem functions everywhere.  This applies not
only to being able to read large files (which generally doesn't apply to
us), but also being able to simply stat them (as they might be using large
inodes).

Signed-off-by: Mike Frysinger <vapier@chromium.org>
---
 Makefile | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/Makefile b/Makefile
index 35cacc4..9d35ef1 100644
--- a/Makefile
+++ b/Makefile
@@ -32,6 +32,8 @@ ADDLIB+=mpls_ntop.o mpls_pton.o
 CC = gcc
 HOSTCC = gcc
 DEFINES += -D_GNU_SOURCE
+# Turn on transparent support for LFS
+DEFINES += -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE
 CCOPTS = -O2
 WFLAGS := -Wall -Wstrict-prototypes  -Wmissing-prototypes
 WFLAGS += -Wmissing-declarations -Wold-style-definition -Wformat=2
-- 
2.4.1
