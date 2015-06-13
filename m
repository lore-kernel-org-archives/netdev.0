From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH v2 net-next 0/3] bpf: share helpers between tracing and networking
Date: Fri, 12 Jun 2015 19:39:11 -0700
Message-ID: <1434163154-5218-1-git-send-email-ast@plumgrid.com>
Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Wang Nan <wangnan0-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

v1->v2: switched to init_user_ns from current_user_ns as suggested by Andy

Introduce new helpers to access 'struct task_struct'->pid, tgid, uid, gid, comm
fields in tracing and networking.

Share bpf_trace_printk() and bpf_get_smp_processor_id() helpers between
tracing and networking.

Alexei Starovoitov (3):
  bpf: introduce current->pid, tgid, uid, gid, comm accessors
  bpf: allow networking programs to use bpf_trace_printk() for
    debugging
  bpf: let kprobe programs use bpf_get_smp_processor_id() helper

 include/linux/bpf.h        |    4 +++
 include/uapi/linux/bpf.h   |   19 +++++++++++++
 kernel/bpf/core.c          |    7 +++++
 kernel/bpf/helpers.c       |   58 ++++++++++++++++++++++++++++++++++++++
 kernel/trace/bpf_trace.c   |   28 ++++++++++++------
 net/core/filter.c          |    8 ++++++
 samples/bpf/bpf_helpers.h  |    6 ++++
 samples/bpf/tracex2_kern.c |   24 ++++++++++++----
 samples/bpf/tracex2_user.c |   67 ++++++++++++++++++++++++++++++++++++++------
 9 files changed, 199 insertions(+), 22 deletions(-)

-- 
1.7.9.5
