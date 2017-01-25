From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf: use prefix_len in test_tag when reading fdinfo
Date: Thu, 26 Jan 2017 00:42:49 +0100
Message-ID: <a4146cba5583102419763e59d8feff5e91802525.1485387682.git.daniel@iogearbox.net>
Cc: ast@kernel.org, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56722 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750803AbdAYXnF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 18:43:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently used len instead of prefix_len for the strncmp() in
fdinfo on the prog_tag. It still worked as we matched on the correct
output line also with first 8 instead of 10 chars, but lets fix it
properly to use the intended length.

Fixes: 62b64660262a ("bpf: add prog tag test case to bpf selftests")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 tools/testing/selftests/bpf/test_tag.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/testing/selftests/bpf/test_tag.c b/tools/testing/selftests/bpf/test_tag.c
index 6ab4793..5f7c602 100644
--- a/tools/testing/selftests/bpf/test_tag.c
+++ b/tools/testing/selftests/bpf/test_tag.c
@@ -99,7 +99,7 @@ static void tag_from_fdinfo(int fd_prog, uint8_t *tag, uint32_t len)
 	assert(fp);
 
 	while (fgets(buff, sizeof(buff), fp)) {
-		if (strncmp(buff, "prog_tag:\t", len))
+		if (strncmp(buff, "prog_tag:\t", prefix_len))
 			continue;
 		ret = hex2bin(tag, buff + prefix_len, len);
 		break;
-- 
1.9.3
