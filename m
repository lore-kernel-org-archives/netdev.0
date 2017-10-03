From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next 4/8] libbpf: introduce bpf_prog_detach2()
Date: Mon, 2 Oct 2017 22:50:24 -0700
Message-ID: <20171003055028.1294791-5-ast@fb.com>
References: <20171003055028.1294791-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, Tejun Heo <tj@kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:41141 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750838AbdJCFuc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 01:50:32 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v935nTgZ008510
        for <netdev@vger.kernel.org>; Mon, 2 Oct 2017 22:50:31 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2dbwmpabw5-9
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 22:50:31 -0700
In-Reply-To: <20171003055028.1294791-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

introduce bpf_prog_detach2() that takes one more argument prog_fd
vs bpf_prog_detach() that takes only attach_fd and type.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 tools/lib/bpf/bpf.c | 12 ++++++++++++
 tools/lib/bpf/bpf.h |  1 +
 2 files changed, 13 insertions(+)

diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
index daf624e4c720..d4b6ba8292ee 100644
--- a/tools/lib/bpf/bpf.c
+++ b/tools/lib/bpf/bpf.c
@@ -291,6 +291,18 @@ int bpf_prog_detach(int target_fd, enum bpf_attach_type type)
 	return sys_bpf(BPF_PROG_DETACH, &attr, sizeof(attr));
 }
 
+int bpf_prog_detach2(int prog_fd, int target_fd, enum bpf_attach_type type)
+{
+	union bpf_attr attr;
+
+	bzero(&attr, sizeof(attr));
+	attr.target_fd	 = target_fd;
+	attr.attach_bpf_fd = prog_fd;
+	attr.attach_type = type;
+
+	return sys_bpf(BPF_PROG_DETACH, &attr, sizeof(attr));
+}
+
 int bpf_prog_test_run(int prog_fd, int repeat, void *data, __u32 size,
 		      void *data_out, __u32 *size_out, __u32 *retval,
 		      __u32 *duration)
diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
index 118d00535a0d..afd64727c9cf 100644
--- a/tools/lib/bpf/bpf.h
+++ b/tools/lib/bpf/bpf.h
@@ -66,6 +66,7 @@ int bpf_obj_get(const char *pathname);
 int bpf_prog_attach(int prog_fd, int attachable_fd, enum bpf_attach_type type,
 		    unsigned int flags);
 int bpf_prog_detach(int attachable_fd, enum bpf_attach_type type);
+int bpf_prog_detach2(int prog_fd, int attachable_fd, enum bpf_attach_type type);
 int bpf_prog_test_run(int prog_fd, int repeat, void *data, __u32 size,
 		      void *data_out, __u32 *size_out, __u32 *retval,
 		      __u32 *duration);
-- 
2.9.5
