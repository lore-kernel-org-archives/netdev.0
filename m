From: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
Subject: [PATCH 1/2] trace_events: fix napi's tracepoint
Date: Tue, 25 Aug 2009 14:49:03 +0800
Message-ID: <4A93895F.4010708@cn.fujitsu.com>
References: <4A937EF5.4040505@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754618AbZHYGtf@vger.kernel.org>
In-Reply-To: <4A937EF5.4040505@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, the napi's tracepoint works will is depend on
"DECLARE_TRACE" definiens in include/trace/define_trace.h,
like below:

#include <trace/events/skb.h>    // include define_trace.h
#include <trace/events/napi.h>

there have error, if we remove "#include <trace/events/skb.h>"
or include napi.h in the front of include skb.h, It should
depend on the definiens in include/linux/tracepoint.h and we
can remove the "DECLARE_TRACE" definiens in
include/trace/define_trace.h, because "TRACE_EVENT" not use it

Signed-off-by: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
---
 include/trace/define_trace.h |    4 ----
 net/core/net-traces.c        |    4 +++-
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/include/trace/define_trace.h b/include/trace/define_trace.h
index f7a7ae1..76e93bf 100644
--- a/include/trace/define_trace.h
+++ b/include/trace/define_trace.h
@@ -26,10 +26,6 @@
 #define TRACE_EVENT(name, proto, args, tstruct, assign, print)	\
 	DEFINE_TRACE(name)
 
-#undef DECLARE_TRACE
-#define DECLARE_TRACE(name, proto, args)	\
-	DEFINE_TRACE(name)
-
 #undef TRACE_INCLUDE
 #undef __TRACE_INCLUDE
 
diff --git a/net/core/net-traces.c b/net/core/net-traces.c
index f1e982c..42bda72 100644
--- a/net/core/net-traces.c
+++ b/net/core/net-traces.c
@@ -19,13 +19,15 @@
 #include <linux/workqueue.h>
 #include <linux/netlink.h>
 #include <linux/net_dropmon.h>
+#include <linux/tracepoint.h>
 
 #include <asm/unaligned.h>
 #include <asm/bitops.h>
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/skb.h>
-#include <trace/events/napi.h>
+
+DEFINE_TRACE(napi_poll);
 
 EXPORT_TRACEPOINT_SYMBOL_GPL(kfree_skb);
 
-- 
1.6.1.2
