From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 2/6] ring_buffer: Export for_each_buffer_cpu()
Date: Sun, 22 Jan 2012 22:56:17 +0100
Message-ID: <1327269381-20748-3-git-send-email-richard@nod.at>
References: <1327269381-20748-1-git-send-email-richard@nod.at>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com, jengelh@medozas.de,
	Richard Weinberger <richard@nod.at>
To: netfilter-devel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327269381-20748-1-git-send-email-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In order to make ring_buffer usable to other modules
for_each_buffer_cpu() needs to be exported.

Signed-off-by: Richard Weinberger <richard@nod.at>
Acked-by: Steven Rostedt <rostedt@goodmis.org>
---
 include/linux/ring_buffer.h |    5 +++++
 kernel/trace/ring_buffer.c  |    7 +++++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/include/linux/ring_buffer.h b/include/linux/ring_buffer.h
index 67be037..5c1c29f 100644
--- a/include/linux/ring_buffer.h
+++ b/include/linux/ring_buffer.h
@@ -185,4 +185,9 @@ enum ring_buffer_flags {
 	RB_FL_OVERWRITE		= 1 << 0,
 };
 
+cpumask_var_t *ring_buffer_mask(struct ring_buffer *buffer);
+
+#define for_each_buffer_cpu(buffer, cpu) \
+	for_each_cpu(cpu, *(ring_buffer_mask(buffer)))
+
 #endif /* _LINUX_RING_BUFFER_H */
diff --git a/kernel/trace/ring_buffer.c b/kernel/trace/ring_buffer.c
index f5b7b5c..a4117c5 100644
--- a/kernel/trace/ring_buffer.c
+++ b/kernel/trace/ring_buffer.c
@@ -348,6 +348,7 @@ void *ring_buffer_event_data(struct ring_buffer_event *event)
 }
 EXPORT_SYMBOL_GPL(ring_buffer_event_data);
 
+#undef for_each_buffer_cpu
 #define for_each_buffer_cpu(buffer, cpu)		\
 	for_each_cpu(cpu, buffer->cpumask)
 
@@ -4139,3 +4140,9 @@ static int rb_cpu_notify(struct notifier_block *self,
 	return NOTIFY_OK;
 }
 #endif
+
+cpumask_var_t *ring_buffer_mask(struct ring_buffer *buffer)
+{
+	return &buffer->cpumask;
+}
+EXPORT_SYMBOL_GPL(ring_buffer_mask);
-- 
1.7.7
