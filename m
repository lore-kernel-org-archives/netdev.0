From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -next] bpf: minor fix in api and bpf_dump_error() usage
Date: Mon, 14 Dec 2015 16:57:32 +0100
Message-ID: <6598a3bfadced14239ea333155eb7fb9aaceccda.1450108152.git.daniel@iogearbox.net>
Cc: ast@kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:51880 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751654AbbLNP5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 10:57:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a whitespace in bpf_dump_error() usage, and also a missing closing
bracket in ntohl() macro for eBPF programs.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/bpf_api.h | 2 +-
 tc/tc_bpf.c       | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/bpf_api.h b/include/bpf_api.h
index 8503b9a..0666a31 100644
--- a/include/bpf_api.h
+++ b/include/bpf_api.h
@@ -53,7 +53,7 @@
 #endif
 
 #ifndef ntohl
-# define ntohl(X)		__constant_ntohl((X)
+# define ntohl(X)		__constant_ntohl((X))
 #endif
 
 /** Section helper macros. */
diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
index beb74be..f9b2b00 100644
--- a/tc/tc_bpf.c
+++ b/tc/tc_bpf.c
@@ -1042,7 +1042,7 @@ static int bpf_prog_attach(const char *section,
 			       "license:\'%s\') %s%s (%d)!\n\n",
 			       section, prog->type,
 			       prog->size / sizeof(struct bpf_insn),
-			       prog->license, fd < 0 ? "rejected :" :
+			       prog->license, fd < 0 ? "rejected: " :
 			       "loaded", fd < 0 ? strerror(errno) : "",
 			       fd < 0 ? errno : fd);
 	}
-- 
1.9.3
