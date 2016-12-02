From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next] samples/bpf: silence compiler warnings
Date: Thu, 1 Dec 2016 18:31:12 -0800
Message-ID: <1480645872-999847-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:35141 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752257AbcLBCbP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 21:31:15 -0500
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.17/8.16.0.17) with SMTP id uB22Qx1c020762
        for <netdev@vger.kernel.org>; Thu, 1 Dec 2016 18:31:14 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 27302r03yy-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 18:31:14 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.212.232.63) with ESMTP id
 644b8f7ab83711e6afea0002c992ebde-62dfba50 for <netdev@vger.kernel.org>;        Thu,
 01 Dec 2016 18:31:12 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

silence some of the clang compiler warnings like:
include/linux/fs.h:2693:9: warning: comparison of unsigned enum expression < 0 is always false
arch/x86/include/asm/processor.h:491:30: warning: taking address of packed member 'sp0' of class or structure 'x86_hw_tss' may result in an unaligned pointer value
include/linux/cgroup-defs.h:326:16: warning: field 'cgrp' with variable sized type 'struct cgroup' not at the end of a struct or class is a GNU extension
since they add too much noise to samples/bpf/ build.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/Makefile | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 3ceb5a9d86df..270e2fd7337a 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -158,4 +158,6 @@ $(obj)/%.o: $(src)/%.c
 	$(CLANG) $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
 		-D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
 		-Wno-compare-distinct-pointer-types \
+		-Wno-gnu-variable-sized-type-not-at-end \
+		-Wno-address-of-packed-member -Wno-tautological-compare \
 		-O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=obj -o $@
-- 
2.8.0
