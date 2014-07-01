From: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC net-next 11/14] tracing: allow eBPF programs to be
 attached to events
Date: Tue, 01 Jul 2014 10:30:56 +0200
Message-ID: <53B271C0.5090008@redhat.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com> <1403913966-4927-12-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1403913966-4927-12-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 06/28/2014 02:06 AM, Alexei Starovoitov wrote:
> User interface:
> cat bpf_123 > /sys/kernel/debug/tracing/__event__/filter
>
> where 123 is an id of the eBPF program priorly loaded.
> __event__ is static tracepoint event.
> (kprobe events will be supported in the future patches)
>
> eBPF programs can call in-kernel helper functions to:
> - lookup/update/delete elements in maps
> - memcmp
> - trace_printk
> - load_pointer
> - dump_stack

Are there plans to let eBPF replace the generic event
filtering framework in tracing?

> Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
> ---
>   include/linux/ftrace_event.h       |    5 +
>   include/trace/bpf_trace.h          |   29 +++++
>   include/trace/ftrace.h             |   10 ++
>   include/uapi/linux/bpf.h           |    5 +
>   kernel/trace/Kconfig               |    1 +
>   kernel/trace/Makefile              |    1 +
>   kernel/trace/bpf_trace.c           |  217 ++++++++++++++++++++++++++++++++++++
>   kernel/trace/trace.h               |    3 +
>   kernel/trace/trace_events.c        |    7 ++
>   kernel/trace/trace_events_filter.c |   72 +++++++++++-
>   10 files changed, 349 insertions(+), 1 deletion(-)
>   create mode 100644 include/trace/bpf_trace.h
>   create mode 100644 kernel/trace/bpf_trace.c
