From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v3 3/7] lib/fs: Fix format string in find_fs_mount()
Date: Mon, 21 Aug 2017 15:23:37 +0200
Message-ID: <20170821132341.23118-4-phil@nwl.cc>
References: <20170821132341.23118-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:35659 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753904AbdHUNYh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 09:24:37 -0400
In-Reply-To: <20170821132341.23118-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A field width of 4096 allows fscanf() to store that amount of characters
into the given buffer, though that doesn't include the terminating NULL
byte. Decrease the value by one to leave space for it.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 lib/fs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/fs.c b/lib/fs.c
index c59ac564581d0..1ff881ecfcd8c 100644
--- a/lib/fs.c
+++ b/lib/fs.c
@@ -45,7 +45,7 @@ static char *find_fs_mount(const char *fs_to_find)
 		return NULL;
 	}
 
-	while (fscanf(fp, "%*s %4096s %127s %*s %*d %*d\n",
+	while (fscanf(fp, "%*s %4095s %127s %*s %*d %*d\n",
 		      path, fstype) == 2) {
 		if (strcmp(fstype, fs_to_find) == 0) {
 			mnt = strdup(path);
-- 
2.13.1
