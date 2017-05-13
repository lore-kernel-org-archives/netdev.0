From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -master 2/2] bpf: dump error to the user when retrieving pinned prog fails
Date: Sat, 13 May 2017 02:32:35 +0200
Message-ID: <8a55c1bf1c2114141c621954d8a1cd55d60bfd59.1494635217.git.daniel@iogearbox.net>
References: <cover.1494635217.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42834 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756974AbdEMAcs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 20:32:48 -0400
In-Reply-To: <cover.1494635217.git.daniel@iogearbox.net>
In-Reply-To: <cover.1494635217.git.daniel@iogearbox.net>
References: <cover.1494635217.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I noticed we currently don't dump an error message when a pinned
program couldn't be retrieved, thus add a hint to the user.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 lib/bpf.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/lib/bpf.c b/lib/bpf.c
index 04ee1ab..ae4d97d 100644
--- a/lib/bpf.c
+++ b/lib/bpf.c
@@ -648,6 +648,16 @@ static int bpf_obj_get(const char *pathname, enum bpf_prog_type type)
 	return bpf(BPF_OBJ_GET, &attr, sizeof(attr));
 }
 
+static int bpf_obj_pinned(const char *pathname, enum bpf_prog_type type)
+{
+	int prog_fd = bpf_obj_get(pathname, type);
+
+	if (prog_fd < 0)
+		fprintf(stderr, "Couldn\'t retrieve pinned program \'%s\': %s\n",
+			pathname, strerror(errno));
+	return prog_fd;
+}
+
 enum bpf_mode {
 	CBPF_BYTECODE,
 	CBPF_FILE,
@@ -750,7 +760,7 @@ static int bpf_parse(enum bpf_prog_type *type, enum bpf_mode *mode,
 	else if (*mode == EBPF_OBJECT)
 		ret = bpf_obj_open(file, *type, section, verbose);
 	else if (*mode == EBPF_PINNED)
-		ret = bpf_obj_get(file, *type);
+		ret = bpf_obj_pinned(file, *type);
 	else
 		return -1;
 
-- 
1.9.3
