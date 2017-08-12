From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 18/51] lib/fs: Fix format string in find_fs_mount()
Date: Sat, 12 Aug 2017 14:04:37 +0200
Message-ID: <20170812120510.28750-19-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:36721 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752629AbdHLMIu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:08:50 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
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
