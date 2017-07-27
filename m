From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf: don't indicate success when copy_from_user fails
Date: Thu, 27 Jul 2017 21:02:46 +0200
Message-ID: <af76c90679bef1488ffb97b9b80f250b6738db57.1501182003.git.daniel@iogearbox.net>
Cc: kafai@fb.com, alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34152 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751648AbdG0TC5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 15:02:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

err in bpf_prog_get_info_by_fd() still holds 0 at that time from prior
check_uarg_tail_zero() check. Explicitly return -EFAULT instead, so
user space can be notified of buggy behavior.

Fixes: 1e2709769086 ("bpf: Add BPF_OBJ_GET_INFO_BY_FD")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/syscall.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 045646d..84bb399 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -1289,7 +1289,7 @@ static int bpf_prog_get_info_by_fd(struct bpf_prog *prog,
 	info_len = min_t(u32, sizeof(info), info_len);
 
 	if (copy_from_user(&info, uinfo, info_len))
-		return err;
+		return -EFAULT;
 
 	info.type = prog->type;
 	info.id = prog->aux->id;
-- 
1.9.3
