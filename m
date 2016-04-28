From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net 3/3] samples/bpf: fix trace_output example
Date: Wed, 27 Apr 2016 18:56:22 -0700
Message-ID: <1461808582-1452466-4-git-send-email-ast@fb.com>
References: <1461808582-1452466-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Jann Horn <jannh@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	<netdev@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:19811 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752385AbcD1B42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 21:56:28 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u3S1tkmq014372
	for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 18:56:27 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 22k7x5rb79-2
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 18:56:27 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 68f39a300ce411e6ad640002c95209d8-7addc50 for <netdev@vger.kernel.org>;	Wed,
 27 Apr 2016 18:56:23 -0700
In-Reply-To: <1461808582-1452466-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

llvm cannot always recognize memset as builtin function and optimize
it away, so just delete it. It was a leftover from testing
of bpf_perf_event_output() with large data structures.

Fixes: 39111695b1b8 ("samples: bpf: add bpf_perf_event_output example")
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/trace_output_kern.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/samples/bpf/trace_output_kern.c b/samples/bpf/trace_output_kern.c
index 8d8d1ec429eb..9b96f4fb8cea 100644
--- a/samples/bpf/trace_output_kern.c
+++ b/samples/bpf/trace_output_kern.c
@@ -18,7 +18,6 @@ int bpf_prog1(struct pt_regs *ctx)
 		u64 cookie;
 	} data;
 
-	memset(&data, 0, sizeof(data));
 	data.pid = bpf_get_current_pid_tgid();
 	data.cookie = 0x12345678;
 
-- 
2.8.0
