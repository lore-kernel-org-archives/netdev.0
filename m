From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next] bpf: fix to bpf_setsockops
Date: Sun, 2 Jul 2017 09:14:28 -0700
Message-ID: <20170702161428.3133994-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:51020 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751764AbdGBQOd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Jul 2017 12:14:33 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v62GCJ5u017117
        for <netdev@vger.kernel.org>; Sun, 2 Jul 2017 09:14:32 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 2be7dfjnxu-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sun, 02 Jul 2017 09:14:32 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (10.212.232.63) with ESMTP id
 86ce48a65f4111e7bbc00002c992ebde-30f408f0 for <netdev@vger.kernel.org>;        Sun,
 02 Jul 2017 09:14:29 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed build error due to misplaced "#ifdef CONFIG_INET" (moved 1
statement up).

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
---
 net/core/filter.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 523b91d..e5c280a 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2717,9 +2717,9 @@ BPF_CALL_5(bpf_setsockopt, struct bpf_sock_ops_kern *, bpf_sock,
 		default:
 			ret = -EINVAL;
 		}
+#ifdef CONFIG_INET
 	} else if (level == SOL_TCP &&
 		   sk->sk_prot->setsockopt == tcp_setsockopt) {
-#ifdef CONFIG_INET
 		if (optname == TCP_CONGESTION) {
 			char name[TCP_CA_NAME_MAX];
 
@@ -2757,7 +2757,6 @@ BPF_CALL_5(bpf_setsockopt, struct bpf_sock_ops_kern *, bpf_sock,
 				ret = -EINVAL;
 			}
 		}
-#else
 		ret = -EINVAL;
 #endif
 	} else {
-- 
2.9.3
