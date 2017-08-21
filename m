From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2] lib/bpf: Don't leak fp in bpf_find_mntpt()
Date: Mon, 21 Aug 2017 16:46:51 +0200
Message-ID: <20170821144651.5379-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:44319 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751738AbdHUOrD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 10:47:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If fopen() succeeded but len != PATH_MAX, the function leaks the open
FILE pointer. Fix this by checking len value before calling fopen().

Signed-off-by: Phil Sutter <phil@nwl.cc>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
No change since v1, just resubmitting - I forgot to add it to the
relevant patch chunk when splitting the big series up. Added Daniel's
ACK from his v1 review.
---
 lib/bpf.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/lib/bpf.c b/lib/bpf.c
index 4f52ad4a8f023..1dcb261dc915f 100644
--- a/lib/bpf.c
+++ b/lib/bpf.c
@@ -537,8 +537,11 @@ static const char *bpf_find_mntpt(const char *fstype, unsigned long magic,
 		}
 	}
 
+	if (len != PATH_MAX)
+		return NULL;
+
 	fp = fopen("/proc/mounts", "r");
-	if (fp == NULL || len != PATH_MAX)
+	if (fp == NULL)
 		return NULL;
 
 	while (fscanf(fp, "%*s %" textify(PATH_MAX) "s %99s %*s %*d %*d\n",
-- 
2.13.1
