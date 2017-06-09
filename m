From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 2/2] bpf: Fix test_obj_id.c for llvm 5.0
Date: Thu, 8 Jun 2017 22:30:17 -0700
Message-ID: <20170609053017.2909855-2-kafai@fb.com>
References: <20170609053017.2909855-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Yonghong Song <yhs@fb.com>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:34740 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751573AbdFIFaU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 01:30:20 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v595QVSt010761
        for <netdev@vger.kernel.org>; Thu, 8 Jun 2017 22:30:20 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 2ay3q2avbh-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 22:30:20 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.212.232.63) with ESMTP id
 b92a9aa44cd411e794110002c992ebde-775378f0 for <netdev@vger.kernel.org>;        Thu,
 08 Jun 2017 22:30:18 -0700
In-Reply-To: <20170609053017.2909855-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

llvm 5.0 does not like the section name and the function name
to be the same:

clang -I. -I./include/uapi -I../../../include/uapi \
	-I../../../../samples/bpf/ \
	-Wno-compare-distinct-pointer-types \
	-O2 -target bpf -c \
	linux/tools/testing/selftests/bpf/test_obj_id.c -o \
	linux/tools/testing/selftests/bpf/test_obj_id.o
fatal error: error in backend: 'test_prog_id' label emitted multiple times to
assembly file
clang-5.0: error: clang frontend command failed with exit code 70 (use -v to
see invocation)
clang version 5.0.0 (trunk 304326) (llvm/trunk 304329)

This patch makes changes to the section name and the function name.

Fixes: 95b9afd3987f ("bpf: Test for bpf ID")
Reported-by: Alexei Starovoitov <ast@fb.com>
Reported-by: Yonghong Song <yhs@fb.com>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 tools/testing/selftests/bpf/test_obj_id.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/testing/selftests/bpf/test_obj_id.c b/tools/testing/selftests/bpf/test_obj_id.c
index d8723aaf827a..880d2963b472 100644
--- a/tools/testing/selftests/bpf/test_obj_id.c
+++ b/tools/testing/selftests/bpf/test_obj_id.c
@@ -23,8 +23,8 @@ struct bpf_map_def SEC("maps") test_map_id = {
 	.max_entries = 1,
 };
 
-SEC("test_prog_id")
-int test_prog_id(struct __sk_buff *skb)
+SEC("test_obj_id_dummy")
+int test_obj_id(struct __sk_buff *skb)
 {
 	__u32 key = 0;
 	__u64 *value;
-- 
2.9.3
