From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 17/51] lib/bpf: Don't leak fp in bpf_find_mntpt()
Date: Sat, 12 Aug 2017 14:04:36 +0200
Message-ID: <20170812120510.28750-18-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:37477 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752617AbdHLMJq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:09:46 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If fopen() succeeded but len != PATH_MAX, the function leaks the open
FILE pointer. Fix this by checking len value before calling fopen().

Signed-off-by: Phil Sutter <phil@nwl.cc>
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
