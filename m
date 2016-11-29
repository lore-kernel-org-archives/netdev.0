From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next] samples/bpf: fix include path
Date: Mon, 28 Nov 2016 22:07:22 -0800
Message-ID: <1480399642-2475887-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:49032 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754281AbcK2GHZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 01:07:25 -0500
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAT658PM005120
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 22:07:24 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 270yr7bcwn-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 22:07:24 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.212.236.87) with ESMTP id
 183585e4b5fa11e68b100002c9521c9e-45bf3a50 for <netdev@vger.kernel.org>;        Mon,
 28 Nov 2016 22:07:23 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the following build error:
HOSTCC  samples/bpf/test_lru_dist.o
../samples/bpf/test_lru_dist.c:25:22: fatal error: bpf_util.h: No such file or directory

This is due to objtree != srctree.
Use srctree, since that's where bpf_util.h is located.

Fixes: e00c7b216f34 ("bpf: fix multiple issues in selftest suite and samples")
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/Makefile | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 22b6407efa4f..3ceb5a9d86df 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -91,7 +91,7 @@ always += trace_event_kern.o
 always += sampleip_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
-HOSTCFLAGS += -I$(objtree)/tools/testing/selftests/bpf/
+HOSTCFLAGS += -I$(srctree)/tools/testing/selftests/bpf/
 
 HOSTCFLAGS_bpf_load.o += -I$(objtree)/usr/include -Wno-unused-variable
 HOSTLOADLIBES_fds_example += -lelf
-- 
2.8.0
