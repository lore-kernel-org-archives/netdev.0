From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v11 tip 2/9] tracing: add kprobe flag
Date: Wed, 25 Mar 2015 12:49:19 -0700
Message-ID: <1427312966-8434-3-git-send-email-ast@plumgrid.com>
References: <1427312966-8434-1-git-send-email-ast@plumgrid.com>
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33764 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753574AbbCYTtc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 15:49:32 -0400
Received: by pabxg6 with SMTP id xg6so39123452pab.0
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 12:49:31 -0700 (PDT)
In-Reply-To: <1427312966-8434-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add TRACE_EVENT_FL_KPROBE flag to differentiate kprobe type of tracepoints,
since bpf programs can only be attached to kprobe type of
PERF_TYPE_TRACEPOINT perf events.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
Reviewed-by: Steven Rostedt <rostedt@goodmis.org>
Reviewed-by: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
---
 include/linux/ftrace_event.h |    3 +++
 kernel/trace/trace_kprobe.c  |    2 +-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/linux/ftrace_event.h b/include/linux/ftrace_event.h
index c674ee8f7fca..77325e1a1816 100644
--- a/include/linux/ftrace_event.h
+++ b/include/linux/ftrace_event.h
@@ -252,6 +252,7 @@ enum {
 	TRACE_EVENT_FL_WAS_ENABLED_BIT,
 	TRACE_EVENT_FL_USE_CALL_FILTER_BIT,
 	TRACE_EVENT_FL_TRACEPOINT_BIT,
+	TRACE_EVENT_FL_KPROBE_BIT,
 };
 
 /*
@@ -265,6 +266,7 @@ enum {
  *                     it is best to clear the buffers that used it).
  *  USE_CALL_FILTER - For ftrace internal events, don't use file filter
  *  TRACEPOINT    - Event is a tracepoint
+ *  KPROBE        - Event is a kprobe
  */
 enum {
 	TRACE_EVENT_FL_FILTERED		= (1 << TRACE_EVENT_FL_FILTERED_BIT),
@@ -274,6 +276,7 @@ enum {
 	TRACE_EVENT_FL_WAS_ENABLED	= (1 << TRACE_EVENT_FL_WAS_ENABLED_BIT),
 	TRACE_EVENT_FL_USE_CALL_FILTER	= (1 << TRACE_EVENT_FL_USE_CALL_FILTER_BIT),
 	TRACE_EVENT_FL_TRACEPOINT	= (1 << TRACE_EVENT_FL_TRACEPOINT_BIT),
+	TRACE_EVENT_FL_KPROBE		= (1 << TRACE_EVENT_FL_KPROBE_BIT),
 };
 
 struct ftrace_event_call {
diff --git a/kernel/trace/trace_kprobe.c b/kernel/trace/trace_kprobe.c
index d73f565b4e06..8fa549f6f528 100644
--- a/kernel/trace/trace_kprobe.c
+++ b/kernel/trace/trace_kprobe.c
@@ -1286,7 +1286,7 @@ static int register_kprobe_event(struct trace_kprobe *tk)
 		kfree(call->print_fmt);
 		return -ENODEV;
 	}
-	call->flags = 0;
+	call->flags = TRACE_EVENT_FL_KPROBE;
 	call->class->reg = kprobe_register;
 	call->data = tk;
 	ret = trace_add_event_call(call);
-- 
1.7.9.5
