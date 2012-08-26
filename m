From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [REVIEW][PATCH 11/15] userns: Teach trace to use from_kuid
Date: Sat, 25 Aug 2012 17:04:08 -0700
Message-ID: <87wr0mecxz.fsf@xmission.com>
References: <87lih2h6i4.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	David Miller <davem@davemloft.net>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Ingo Molnar <mingo@redhat.com>
In-Reply-To: <87lih2h6i4.fsf@xmission.com> (Eric W. Biederman's message of
	"Sat, 25 Aug 2012 16:54:59 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


- When tracing capture the kuid.
- When displaying the data to user space convert the kuid into the
  user namespace of the process that opened the report file.

Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Ingo Molnar <mingo@redhat.com>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 init/Kconfig         |    1 -
 kernel/trace/trace.c |    3 ++-
 kernel/trace/trace.h |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index af41fa7..d849ba2 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -927,7 +927,6 @@ config UIDGID_CONVERTED
 	# Features
 	depends on IMA = n
 	depends on EVM = n
-	depends on TRACING = n
 	depends on FS_POSIX_ACL = n
 	depends on QUOTA = n
 	depends on QUOTACTL = n
diff --git a/kernel/trace/trace.c b/kernel/trace/trace.c
index 5c38c81..c9ace83 100644
--- a/kernel/trace/trace.c
+++ b/kernel/trace/trace.c
@@ -2060,7 +2060,8 @@ print_trace_header(struct seq_file *m, struct trace_iterator *iter)
 	seq_puts(m, "#    -----------------\n");
 	seq_printf(m, "#    | task: %.16s-%d "
 		   "(uid:%d nice:%ld policy:%ld rt_prio:%ld)\n",
-		   data->comm, data->pid, data->uid, data->nice,
+		   data->comm, data->pid,
+		   from_kuid_munged(seq_user_ns(m), data->uid), data->nice,
 		   data->policy, data->rt_priority);
 	seq_puts(m, "#    -----------------\n");
 
diff --git a/kernel/trace/trace.h b/kernel/trace/trace.h
index 55e1f7f..40a6f30 100644
--- a/kernel/trace/trace.h
+++ b/kernel/trace/trace.h
@@ -147,7 +147,7 @@ struct trace_array_cpu {
 	unsigned long		skipped_entries;
 	cycle_t			preempt_timestamp;
 	pid_t			pid;
-	uid_t			uid;
+	kuid_t			uid;
 	char			comm[TASK_COMM_LEN];
 };
 
-- 
1.7.5.4
