From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next] samples/bpf: fix bpf_perf_event_output prototype
Date: Wed, 10 Aug 2016 09:45:39 -0700
Message-ID: <1470847539-2048114-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, Adam Barth <arb@fb.com>,
	<netdev@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:31099 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932272AbcHJSCb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 14:02:31 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7AGiSMC014608
	for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 09:45:41 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 24qebeenvp-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 09:45:41 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.103.99.97) with ESMTP	id
 de76a1da5f1911e69deb0002c9931860-489d8af0 for <netdev@vger.kernel.org>;	Wed,
 10 Aug 2016 09:45:39 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adam Barth <arb@fb.com>

The commit 555c8a8623a3 ("bpf: avoid stack copy and use skb ctx for event output")
started using 20 of initially reserved upper 32-bits of 'flags' argument
in bpf_perf_event_output(). Adjust corresponding prototype in samples/bpf/bpf_helpers.h

Signed-off-by: Adam Barth <arb@fb.com>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 samples/bpf/bpf_helpers.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 217c8d507f2e..cbc52df165b4 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -37,7 +37,9 @@ static int (*bpf_clone_redirect)(void *ctx, int ifindex, int flags) =
 	(void *) BPF_FUNC_clone_redirect;
 static int (*bpf_redirect)(int ifindex, int flags) =
 	(void *) BPF_FUNC_redirect;
-static int (*bpf_perf_event_output)(void *ctx, void *map, int index, void *data, int size) =
+static int (*bpf_perf_event_output)(void *ctx, void *map,
+				    unsigned long long flags, void *data,
+				    int size) =
 	(void *) BPF_FUNC_perf_event_output;
 static int (*bpf_get_stackid)(void *ctx, void *map, int flags) =
 	(void *) BPF_FUNC_get_stackid;
-- 
2.8.0
