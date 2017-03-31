From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 4/6] tools/lib/bpf: expose bpf_program__set_type()
Date: Thu, 30 Mar 2017 18:31:55 -0700
Message-ID: <20170331013157.3298003-5-ast@fb.com>
References: <20170331013157.3298003-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Wang Nan <wangnan0@huawei.com>,
        Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:57258 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934681AbdCaBcC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 21:32:02 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2V1U2PA003333
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 18:32:01 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 29h9ubgp9h-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 18:32:01 -0700
Received: from facebook.com (2401:db00:11:d082:face:0:5:0)      by
 mx-out.facebook.com (10.223.100.99) with ESMTP id
 d53fc57a15b111e799ea24be05956610-574fa9a0 for <netdev@vger.kernel.org>;        Thu,
 30 Mar 2017 18:31:59 -0700
In-Reply-To: <20170331013157.3298003-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

expose bpf_program__set_type() to set program type

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 tools/lib/bpf/libbpf.c | 3 +--
 tools/lib/bpf/libbpf.h | 1 +
 2 files changed, 2 insertions(+), 2 deletions(-)

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
index b30394f9947a..82adde30b696 100644
--- a/tools/lib/bpf/libbpf.h
+++ b/tools/lib/bpf/libbpf.h
@@ -185,6 +185,7 @@ int bpf_program__set_sched_cls(struct bpf_program *prog);
 int bpf_program__set_sched_act(struct bpf_program *prog);
 int bpf_program__set_xdp(struct bpf_program *prog);
 int bpf_program__set_perf_event(struct bpf_program *prog);
+void bpf_program__set_type(struct bpf_program *prog, enum bpf_prog_type type);
 
 bool bpf_program__is_socket_filter(struct bpf_program *prog);
 bool bpf_program__is_tracepoint(struct bpf_program *prog);
-- 
2.9.3
