From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 master] bpf: test for valid type in bpf_get_work_dir
Date: Mon,  6 Mar 2017 13:06:00 +0100
Message-ID: <31298439f86c34288a26fd4c3d2bcac262d37565.1488801657.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, janerik@rediger.net,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41678 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932080AbdCFMGW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 07:06:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan-Erik reported an assertion in bpf_prog_to_subdir() failed where
type was BPF_PROG_TYPE_UNSPEC, which is only used in bpf_init_env()
to auto-mount and cache the bpf fs mount point.

Therefore, make sure when bpf_init_env() is called multiple times
(f.e. eBPF classifier with eBPF action attached) and bpf_mnt_cached
is set already that the type is also valid. In bpf_init_env(), we're
only interested in the mount point and not a type-specific subdir.

Fixes: e42256699cac ("bpf: make tc's bpf loader generic and move into lib")
Reported-by: Jan-Erik Rediger <janerik@rediger.net>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 lib/bpf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/bpf.c b/lib/bpf.c
index 211c3d1..04ee1ab 100644
--- a/lib/bpf.c
+++ b/lib/bpf.c
@@ -596,7 +596,7 @@ static const char *bpf_get_work_dir(enum bpf_prog_type type)
 	if (bpf_mnt_cached) {
 		const char *out = mnt;
 
-		if (out) {
+		if (out && type) {
 			snprintf(bpf_tmp, sizeof(bpf_tmp), "%s%s/",
 				 out, bpf_prog_to_subdir(type));
 			out = bpf_tmp;
-- 
1.9.3
