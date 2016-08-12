From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 3/3] bpf: allow bpf_get_prandom_u32() to be used in tracing
Date: Thu, 11 Aug 2016 18:17:18 -0700
Message-ID: <1470964638-1313057-4-git-send-email-ast@fb.com>
References: <1470964638-1313057-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
	<kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:34943 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751207AbcHLBRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 21:17:21 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7C1HE4k015937
	for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 18:17:20 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 24s0h1s9kp-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 18:17:20 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 83411d2e602a11e692700002c992ebde-5bfcaa0 for <netdev@vger.kernel.org>;	Thu,
 11 Aug 2016 18:17:19 -0700
In-Reply-To: <1470964638-1313057-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bpf_get_prandom_u32() was initially introduced for socket filters
and later requested numberous times to be added to tracing bpf programs
for the same reason as in socket filters: to be able to randomly
select incoming events.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/trace/bpf_trace.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index b20438fdb029..96a3e3bbbe9e 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -407,6 +407,8 @@ static const struct bpf_func_proto *tracing_func_proto(enum bpf_func_id func_id)
 		return &bpf_perf_event_read_proto;
 	case BPF_FUNC_probe_write_user:
 		return bpf_get_probe_write_proto();
+	case BPF_FUNC_get_prandom_u32:
+		return &bpf_get_prandom_u32_proto;
 	default:
 		return NULL;
 	}
-- 
2.8.0
