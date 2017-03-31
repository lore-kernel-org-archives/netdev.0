From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next 3/6] tools/lib/bpf: expose bpf_program__set_type()
Date: Thu, 30 Mar 2017 21:45:40 -0700
Message-ID: <20170331044543.4075183-4-ast@fb.com>
References: <20170331044543.4075183-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Wang Nan <wangnan0@huawei.com>,
        Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:45669 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752277AbdCaEpt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 00:45:49 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2V4gEtn028116
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 21:45:47 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 29hfusr2u5-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 21:45:47 -0700
Received: from facebook.com (2401:db00:11:d082:face:0:5:0)      by
 mx-out.facebook.com (10.223.100.97) with ESMTP id
 e6e3691015cc11e7afc324be0593f280-6e7e89a0 for <netdev@vger.kernel.org>;        Thu,
 30 Mar 2017 21:45:45 -0700
In-Reply-To: <20170331044543.4075183-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

expose bpf_program__set_type() to set program type

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 tools/lib/bpf/libbpf.c | 3 +--
 tools/lib/bpf/libbpf.h | 2 ++
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
index ac6eb863b2a4..1a2c07eb7795 100644
--- a/tools/lib/bpf/libbpf.c
+++ b/tools/lib/bpf/libbpf.c
@@ -1618,8 +1618,7 @@ int bpf_program__nth_fd(struct bpf_program *prog, int n)
 	return fd;
 }
 
-static void bpf_program__set_type(struct bpf_program *prog,
-				  enum bpf_prog_type type)
+void bpf_program__set_type(struct bpf_program *prog, enum bpf_prog_type type)
 {
 	prog->type = type;
 }
diff --git a/tools/lib/bpf/libbpf.h b/tools/lib/bpf/libbpf.h
index b30394f9947a..32c7252f734e 100644
--- a/tools/lib/bpf/libbpf.h
+++ b/tools/lib/bpf/libbpf.h
@@ -25,6 +25,7 @@
 #include <stdint.h>
 #include <stdbool.h>
 #include <sys/types.h>  // for size_t
+#include <linux/bpf.h>
 
 enum libbpf_errno {
 	__LIBBPF_ERRNO__START = 4000,
@@ -185,6 +186,7 @@ int bpf_program__set_sched_cls(struct bpf_program *prog);
 int bpf_program__set_sched_act(struct bpf_program *prog);
 int bpf_program__set_xdp(struct bpf_program *prog);
 int bpf_program__set_perf_event(struct bpf_program *prog);
+void bpf_program__set_type(struct bpf_program *prog, enum bpf_prog_type type);
 
 bool bpf_program__is_socket_filter(struct bpf_program *prog);
 bool bpf_program__is_tracepoint(struct bpf_program *prog);
-- 
2.9.3
