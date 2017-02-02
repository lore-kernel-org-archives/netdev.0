From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] trace: rename trace_print_hex_seq arg and add kdoc
Date: Thu,  2 Feb 2017 17:09:54 +0100
Message-ID: <fefa5048a9834e7857fa399dc800054d4cebdd31.1486050724.git.daniel@iogearbox.net>
Cc: rostedt@goodmis.org, ast@kernel.org, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36244 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751730AbdBBQJ6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 11:09:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steven suggested to improve trace_print_hex_seq() a bit after commit
2acae0d5b0f7 ("trace: add variant without spacing in trace_print_hex_seq")
in two ways: i) by adding a kdoc comment for the helper function
itself and ii) by renaming 'spacing' argument into 'concatenate'
to better denote that we don't add spaces between each hex bytes.

Suggested-by: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 [ Sending as follow-up as original one is in net-next. ]

 include/linux/trace_events.h |  2 +-
 include/trace/trace_events.h |  4 ++--
 kernel/trace/trace_output.c  | 15 +++++++++++++--
 3 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/include/linux/trace_events.h b/include/linux/trace_events.h
index cfa475a..0f16550 100644
--- a/include/linux/trace_events.h
+++ b/include/linux/trace_events.h
@@ -34,7 +34,7 @@ const char *trace_print_bitmask_seq(struct trace_seq *p, void *bitmask_ptr,
 
 const char *trace_print_hex_seq(struct trace_seq *p,
 				const unsigned char *buf, int len,
-				bool spacing);
+				bool concatenate);
 
 const char *trace_print_array_seq(struct trace_seq *p,
 				   const void *buf, int count,
diff --git a/include/trace/trace_events.h b/include/trace/trace_events.h
index 9f68462..5c06f4a 100644
--- a/include/trace/trace_events.h
+++ b/include/trace/trace_events.h
@@ -298,11 +298,11 @@
 
 #undef __print_hex
 #define __print_hex(buf, buf_len)					\
-	trace_print_hex_seq(p, buf, buf_len, true)
+	trace_print_hex_seq(p, buf, buf_len, false)
 
 #undef __print_hex_str
 #define __print_hex_str(buf, buf_len)					\
-	trace_print_hex_seq(p, buf, buf_len, false)
+	trace_print_hex_seq(p, buf, buf_len, true)
 
 #undef __print_array
 #define __print_array(array, count, el_size)				\
diff --git a/kernel/trace/trace_output.c b/kernel/trace/trace_output.c
index 30a144b1..aea6a12 100644
--- a/kernel/trace/trace_output.c
+++ b/kernel/trace/trace_output.c
@@ -162,15 +162,26 @@ enum print_line_t trace_print_printk_msg_only(struct trace_iterator *iter)
 }
 EXPORT_SYMBOL_GPL(trace_print_bitmask_seq);
 
+/**
+ * trace_print_hex_seq - print buffer as hex sequence
+ * @p: trace seq struct to write to
+ * @buf: The buffer to print
+ * @buf_len: Length of @buf in bytes
+ * @concatenate: Print @buf as single hex string or with spacing
+ *
+ * Prints the passed buffer as a hex sequence either as a whole,
+ * single hex string if @concatenate is true or with spacing after
+ * each byte in case @concatenate is false.
+ */
 const char *
 trace_print_hex_seq(struct trace_seq *p, const unsigned char *buf, int buf_len,
-		    bool spacing)
+		    bool concatenate)
 {
 	int i;
 	const char *ret = trace_seq_buffer_ptr(p);
 
 	for (i = 0; i < buf_len; i++)
-		trace_seq_printf(p, "%s%2.2x", !spacing || i == 0 ? "" : " ",
+		trace_seq_printf(p, "%s%2.2x", concatenate || i == 0 ? "" : " ",
 				 buf[i]);
 	trace_seq_putc(p, 0);
 
-- 
1.9.3
