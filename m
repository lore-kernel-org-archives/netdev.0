From: Yonghong Song <yhs@fb.com>
Subject: [PATCH net-next v3 1/3] bpf: use the same condition in perf event set/free bpf handler
Date: Mon, 23 Oct 2017 23:53:07 -0700
Message-ID: <20171024065309.2401893-2-yhs@fb.com>
References: <20171024065309.2401893-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <peterz@infradead.org>, <rostedt@goodmis.org>, <ast@fb.com>,
        <daniel@iogearbox.net>, <kafai@fb.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:49294 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751470AbdJXGx0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 02:53:26 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9O6nSJi018134
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 23:53:26 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2dswr18dtu-4
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 23:53:26 -0700
In-Reply-To: <20171024065309.2401893-1-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a cleanup such that doing the same check in
perf_event_free_bpf_prog as we already do in
perf_event_set_bpf_prog step.

Signed-off-by: Yonghong Song <yhs@fb.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 kernel/events/core.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/kernel/events/core.c b/kernel/events/core.c
index 31ee304..9f78a682 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -8191,10 +8191,10 @@ static void perf_event_free_bpf_prog(struct perf_event *event)
 {
 	struct bpf_prog *prog;
 
-	perf_event_free_bpf_handler(event);
-
-	if (!event->tp_event)
+	if (event->attr.type != PERF_TYPE_TRACEPOINT) {
+		perf_event_free_bpf_handler(event);
 		return;
+	}
 
 	prog = event->tp_event->prog;
 	if (prog && event->tp_event->bpf_prog_owner == event) {
-- 
2.9.5
