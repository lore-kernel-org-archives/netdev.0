From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next] bpf: Fix compiler warning on info.map_ids for 32bit platform
Date: Fri, 29 Sep 2017 10:52:17 -0700
Message-ID: <20170929175217.437830-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:46092 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752120AbdI2RwT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 13:52:19 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8THmhxK001409
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2017 10:52:18 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2d9rq60kt9-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2017 10:52:18 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch uses u64_to_user_ptr() to cast info.map_ids to a userspace ptr.
It also tags the user_map_ids with '__user' for sparse check.

Fixes: cb4d2b3f03d8 ("bpf: Add name, load_time, uid and map_ids to bpf_prog_info")
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 kernel/bpf/syscall.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 11a7f82a55d1..b927da66f653 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -1405,7 +1405,7 @@ static int bpf_prog_get_info_by_fd(struct bpf_prog *prog,
 	info.nr_map_ids = prog->aux->used_map_cnt;
 	ulen = min_t(u32, info.nr_map_ids, ulen);
 	if (ulen) {
-		u32 *user_map_ids = (u32 *)info.map_ids;
+		u32 __user *user_map_ids = u64_to_user_ptr(info.map_ids);
 		u32 i;
 
 		for (i = 0; i < ulen; i++)
-- 
2.9.5
