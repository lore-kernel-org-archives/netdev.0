From: Masami Hiramatsu <mhiramat@kernel.org>
Subject: [RFC PATCH tip/master 1/3] trace: kprobes: Show sum of probe/retprobe nmissed count
Date: Wed, 29 Mar 2017 14:22:02 +0900
Message-ID: <149076491191.24574.9187877160820798843.stgit@devbox>
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

Show sum of probe and retprobe nmissed count in
kprobe_profile, since retprobe can be missed even
if the kprobe itself succeeeded.
This explains user why their return probe didn't hit
sometimes.

Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
---
 kernel/trace/trace_kprobe.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/trace/trace_kprobe.c b/kernel/trace/trace_kprobe.c
index 013f4e7..bbdc3de 100644
--- a/kernel/trace/trace_kprobe.c
+++ b/kernel/trace/trace_kprobe.c
@@ -896,7 +896,7 @@ static int probes_profile_seq_show(struct seq_file *m, void *v)
 	seq_printf(m, "  %-44s %15lu %15lu\n",
 		   trace_event_name(&tk->tp.call),
 		   trace_kprobe_nhit(tk),
-		   tk->rp.kp.nmissed);
+		   tk->rp.kp.nmissed + tk->rp.nmissed);
 
 	return 0;
 }

