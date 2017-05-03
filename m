From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next] selftests/bpf: get rid of -D__x86_64__
Date: Tue, 2 May 2017 21:14:43 -0700
Message-ID: <20170503041443.3125777-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:57060 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750737AbdECEOq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 00:14:46 -0400
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v43483vY019808
        for <netdev@vger.kernel.org>; Tue, 2 May 2017 21:14:46 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2a72ng8q0f-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 21:14:46 -0700
Received: from facebook.com (2401:db00:11:d082:face:0:5:0)      by
 mx-out.facebook.com (10.212.236.89) with ESMTP id
 098c4e102fb711e787480002c95209d8-d41f79a0 for <netdev@vger.kernel.org>;        Tue,
 02 May 2017 21:14:44 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-D__x86_64__ workaround was used to make /usr/include/features.h
to follow expected path through the system include headers.
This is not portable.
Instead define dummy stubs.h which is used by 'clang -target bpf'

Fixes: 6882804c916b ("selftests/bpf: add a test for overlapping packet range checks")
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 tools/testing/selftests/bpf/Makefile    | 4 ++--
 tools/testing/selftests/bpf/gnu/stubs.h | 1 +
 2 files changed, 3 insertions(+), 2 deletions(-)
 create mode 100644 tools/testing/selftests/bpf/gnu/stubs.h

diff --git a/tools/testing/selftests/bpf/Makefile b/tools/testing/selftests/bpf/Makefile
index f4341e160de6..91edd0566237 100644
--- a/tools/testing/selftests/bpf/Makefile
+++ b/tools/testing/selftests/bpf/Makefile
@@ -34,6 +34,6 @@ $(BPFOBJ): force
 CLANG ?= clang
 
 %.o: %.c
-	$(CLANG) -I../../../include/uapi -I../../../../samples/bpf/ \
-		-D__x86_64__ -Wno-compare-distinct-pointer-types \
+	$(CLANG) -I. -I../../../include/uapi -I../../../../samples/bpf/ \
+		-Wno-compare-distinct-pointer-types \
 		-O2 -target bpf -c $< -o $@
diff --git a/tools/testing/selftests/bpf/gnu/stubs.h b/tools/testing/selftests/bpf/gnu/stubs.h
new file mode 100644
index 000000000000..719225b16626
--- /dev/null
+++ b/tools/testing/selftests/bpf/gnu/stubs.h
@@ -0,0 +1 @@
+/* dummy .h to trick /usr/include/features.h to work with 'clang -target bpf' */
-- 
2.9.3
