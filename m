From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next 02/10] perf: remove unused __addr variable
Date: Wed, 6 Apr 2016 18:43:23 -0700
Message-ID: <1459993411-2754735-3-git-send-email-ast@fb.com>
References: <1459993411-2754735-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <peterz@infradead.org>,
	"David S . Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Wang Nan <wangnan0@huawei.com>, Josef Bacik <jbacik@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:65310 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752848AbcDGBnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 21:43:41 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u371heUq027716
	for <netdev@vger.kernel.org>; Wed, 6 Apr 2016 18:43:40 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 225a0392d3-2
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 18:43:40 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 235d25befc6211e599f924be0593f280-2aae83f0 for <netdev@vger.kernel.org>;	Wed,
 06 Apr 2016 18:43:33 -0700
In-Reply-To: <1459993411-2754735-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

now all calls to perf_trace_buf_submit() pass 0 as 4th
argument which will be repurposed in the next patch which will
change the meaning of 1st arg of perf_tp_event() to event_type

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 include/trace/perf.h         | 7 ++-----
 include/trace/trace_events.h | 3 ---
 2 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/include/trace/perf.h b/include/trace/perf.h
index 26486fcd74ce..6f7e37869065 100644
--- a/include/trace/perf.h
+++ b/include/trace/perf.h
@@ -20,9 +20,6 @@
 #undef __get_bitmask
 #define __get_bitmask(field) (char *)__get_dynamic_array(field)
 
-#undef __perf_addr
-#define __perf_addr(a)	(__addr = (a))
-
 #undef __perf_count
 #define __perf_count(c)	(__count = (c))
 
@@ -38,7 +35,7 @@ perf_trace_##call(void *__data, proto)					\
 	struct trace_event_data_offsets_##call __maybe_unused __data_offsets;\
 	struct trace_event_raw_##call *entry;				\
 	struct pt_regs *__regs;						\
-	u64 __addr = 0, __count = 1;					\
+	u64 __count = 1;						\
 	struct task_struct *__task = NULL;				\
 	struct hlist_head *head;					\
 	int __entry_size;						\
@@ -67,7 +64,7 @@ perf_trace_##call(void *__data, proto)					\
 									\
 	{ assign; }							\
 									\
-	perf_trace_buf_submit(entry, __entry_size, rctx, __addr,	\
+	perf_trace_buf_submit(entry, __entry_size, rctx, 0,		\
 		__count, __regs, head, __task);				\
 }
 
diff --git a/include/trace/trace_events.h b/include/trace/trace_events.h
index 170c93bbdbb7..80679a9fae65 100644
--- a/include/trace/trace_events.h
+++ b/include/trace/trace_events.h
@@ -652,9 +652,6 @@ static inline notrace int trace_event_get_offsets_##call(		\
 #undef TP_fast_assign
 #define TP_fast_assign(args...) args
 
-#undef __perf_addr
-#define __perf_addr(a)	(a)
-
 #undef __perf_count
 #define __perf_count(c)	(c)
 
-- 
2.8.0
