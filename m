From: Masami Hiramatsu <mhiramat@kernel.org>
Subject: [RFC PATCH tip/master 3/3] kprobes: Limit kretprobe maximum instances
Date: Wed, 29 Mar 2017 14:24:23 +0900
Message-ID: <149076505311.24574.3646383930433662308.stgit@devbox>
References: <149076484118.24574.7083269903420611708.stgit@devbox>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Alban Crequy <alban.crequy@gmail.com>,
        Alban Crequy <alban@kinvolk.io>,
        Alexei Starovoitov <ast@kernel.org>,
        Jonathan Corbet <corbet@lwn.net>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Omar Sandoval <osandov@fb.com>, linux-doc@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        iago@kinvolk.io, michael@kinvolk.io,
        Dorau Lukasz <lukasz.dorau@intel.com>, systemtap@sourceware.org
To: Steven Rostedt <rostedt@goodmis.org>,
        Ingo Molnar <mingo@redhat.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <149076484118.24574.7083269903420611708.stgit@devbox>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Limit kretprobe maximum instance up to MAXACTIVE_ALLOC.
Without this limit, kretprobe user can specify huge number
(e.g. forget to zero-fill struct kretprobe) to maxactive
and may cause out-of-memory.

Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
---
 kernel/kprobes.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/kernel/kprobes.c b/kernel/kprobes.c
index 75c5390..f1bebcf 100644
--- a/kernel/kprobes.c
+++ b/kernel/kprobes.c
@@ -1942,6 +1942,9 @@ int register_kretprobe(struct kretprobe *rp)
 	rp->kp.break_handler = NULL;
 
 	/* Pre-allocate memory for max kretprobe instances */
+	if (rp->maxactive > KRETPROBE_MAXACTIVE_ALLOC)
+		return -E2BIG;
+
 	if (rp->maxactive <= 0) {
 #ifdef CONFIG_PREEMPT
 		rp->maxactive = max_t(unsigned int, 10, 2*num_possible_cpus());

