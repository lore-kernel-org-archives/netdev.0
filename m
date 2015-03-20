From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH v8 tip 2/9] tracing: add kprobe flag
Date: Thu, 19 Mar 2015 18:59:40 -0700
Message-ID: <1426816787-5001-3-git-send-email-ast@plumgrid.com>
References: <1426816787-5001-1-git-send-email-ast@plumgrid.com>
Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1426816787-5001-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

add TRACE_EVENT_FL_KPROBE flag to differentiate kprobe type of tracepoints,
since bpf programs can only be attached to kprobe type of
PERF_TYPE_TRACEPOINT perf events.

Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
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
