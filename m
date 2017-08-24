From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v3 4/6] lib/bpf: Check return value of write()
Date: Thu, 24 Aug 2017 11:41:29 +0200
Message-ID: <20170824094131.2963-5-phil@nwl.cc>
References: <20170824094131.2963-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:50611 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751447AbdHXJmV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Aug 2017 05:42:21 -0400
In-Reply-To: <20170824094131.2963-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is merely to silence the compiler warning. If write to stderr
failed, assume that printing an error message will fail as well so don't
even try.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 lib/bpf.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/lib/bpf.c b/lib/bpf.c
index 1dcb261dc915f..825e071cea572 100644
--- a/lib/bpf.c
+++ b/lib/bpf.c
@@ -591,7 +591,8 @@ int bpf_trace_pipe(void)
 
 		ret = read(fd, buff, sizeof(buff) - 1);
 		if (ret > 0) {
-			write(2, buff, ret);
+			if (write(STDERR_FILENO, buff, ret) != ret)
+				return -1;
 			fflush(stderr);
 		}
 	}
-- 
2.13.1
