From: Yonghong Song <yhs@fb.com>
Subject: [PATCH] samples/bpf: fix a build problem
Date: Wed, 21 Jun 2017 13:48:27 -0700
Message-ID: <20170621204827.3259191-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <ast@fb.com>, <daniel@iogearbox.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:52295 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751028AbdFUUsa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 16:48:30 -0400
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5LKiZFx011566
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 13:48:29 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2b7xbcrevm-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 13:48:29 -0700
Received: from facebook.com (2401:db00:11:d0af:face:0:2d:0)     by
 mx-out.facebook.com (10.212.232.63) with ESMTP id
 fa49c7ec56c211e7bbd60002c992ebde-c9b338f0 for <netdev@vger.kernel.org>;        Wed,
 21 Jun 2017 13:48:28 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tracex5_kern.c build failed with the following error message:
  ../samples/bpf/tracex5_kern.c:12:10: fatal error: 'syscall_nrs.h' file not found
  #include "syscall_nrs.h"
The generated file syscall_nrs.h is put in build/samples/bpf directory,
but this directory is not in include path, hence build failed.

The fix is to add $(obj) into the clang compilation path.

Signed-off-by: Yonghong Song <yhs@fb.com>
---
 samples/bpf/Makefile | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index a0561dc..e7ec9b8 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -197,7 +197,7 @@ $(obj)/tracex5_kern.o: $(obj)/syscall_nrs.h
 # But, there is no easy way to fix it, so just exclude it since it is
 # useless for BPF samples.
 $(obj)/%.o: $(src)/%.c
-	$(CLANG) $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
+	$(CLANG) $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) -I$(obj) \
 		-D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
 		-Wno-compare-distinct-pointer-types \
 		-Wno-gnu-variable-sized-type-not-at-end \
-- 
2.9.3
