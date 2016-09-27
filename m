From: Shaohua Li <shli@fb.com>
Subject: [PATCH trival -resend 1/2] bpf: clean up put_cpu_var usage
Date: Tue, 27 Sep 2016 08:42:41 -0700
Message-ID: <7ffd1960225e024a738e4c372f091bb49096e294.1474990741.git.shli@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S . Miller" <davem@davemloft.net>,
        <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>,
        Alexei Starovoitov <ast@kernel.org>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:59415 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933632AbcI0Pmo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 11:42:44 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8RFdduu006992
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 08:42:44 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 25qpgua0gm-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 08:42:44 -0700
Received: from facebook.com (2401:db00:11:d0a2:face:0:39:0)     by
 mx-out.facebook.com (10.212.232.63) with ESMTP id
 076026be84c911e6a55c0002c992ebde-33af6a50 for <netdev@vger.kernel.org>;        Tue,
 27 Sep 2016 08:42:42 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

put_cpu_var takes the percpu data, not the data returned from
get_cpu_var.

This doesn't change the behavior.

Cc: Tejun Heo <tj@kernel.org>
Cc: Alexei Starovoitov <ast@kernel.org>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 kernel/bpf/core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 7b7baae..aa6d981 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -1031,7 +1031,7 @@ BPF_CALL_0(bpf_user_rnd_u32)
 
 	state = &get_cpu_var(bpf_user_rnd_state);
 	res = prandom_u32_state(state);
-	put_cpu_var(state);
+	put_cpu_var(bpf_user_rnd_state);
 
 	return res;
 }
-- 
2.9.3
