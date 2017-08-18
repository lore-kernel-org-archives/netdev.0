From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next] bpf: Fix map-in-map checking in the verifier
Date: Thu, 17 Aug 2017 18:14:43 -0700
Message-ID: <20170818011443.562793-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>,
        John Fastabend <john.fastabend@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:46031 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753515AbdHRBOp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 21:14:45 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7I1DjXh029545
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 18:14:45 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2cdjr2gsv7-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 18:14:45 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.212.232.59) with ESMTP id
 9e183dd883b211e7a2960002c991e86a-d829d150 for <netdev@vger.kernel.org>;        Thu,
 17 Aug 2017 18:14:43 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In check_map_func_compatibility(), a 'break' has been accidentally
removed for the BPF_MAP_TYPE_ARRAY_OF_MAPS and BPF_MAP_TYPE_HASH_OF_MAPS
cases.  This patch adds it back.

Fixes: 174a79ff9515 ("bpf: sockmap with sk redirect support")
Cc: John Fastabend <john.fastabend@gmail.com>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 kernel/bpf/verifier.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 40f669ddb571..4f6e7eb42ba0 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1523,6 +1523,7 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
 	case BPF_MAP_TYPE_HASH_OF_MAPS:
 		if (func_id != BPF_FUNC_map_lookup_elem)
 			goto error;
+		break;
 	case BPF_MAP_TYPE_SOCKMAP:
 		if (func_id != BPF_FUNC_sk_redirect_map &&
 		    func_id != BPF_FUNC_sock_map_update &&
-- 
2.9.5
