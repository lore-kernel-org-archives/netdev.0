From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v3 linux-trace 1/8] tracing: attach eBPF programs to
 tracepoints and syscalls
Date: Sat, 14 Feb 2015 18:02:41 -0500
Message-ID: <CAMEtUuy42YvUVpecTcJpmqgmRQ=fpR3C+pTD0ij+R_5COYg6zQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, wangnan0-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: Hekuang <hekuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 11, 2015 at 11:58 PM, Hekuang <hekuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org> wrote:
>
>>> eBPF is very flexible, which means it is bound to have someone use it
>>> in a way you never dreamed of, and that will be what bites you in the
>>> end (pun intended).
>>
>> understood :)
>> let's start slow then with bpf+syscall and bpf+kprobe only.
>
>
> I think BPF + system calls/kprobes can meet our use case
> (https://lkml.org/lkml/2015/2/6/44), but there're some issues to be
> improved.
>
> I suggest that you can improve bpf+kprobes when attached to function
> headers(or TRACE_MARKERS), make it converts pt-regs to bpf_ctx->arg1,
> arg2.., then top models and architectures can be separated by bpf.
>
> BPF bytecode is cross-platform, but what we can get by using bpf+kprobes
> is a 'regs->rdx' kind of information, such information is both
> architecture and kernel version related.

for kprobes in the middle of the function, kernel cannot
convert pt_regs into argN. Placement was decided by compiler
and can only be found in debug info.
I think bpf+kprobe will be using it when it is available.
When there is no debug info, kprobes will be limited
to function entry and mapping of regs/stack into
argN can be done by user space depending on architecture.
So user tracing scripts in some higher level language
can be kernel/arch independent when 'perf probe+bpf'
is loading them on the fly on the given machine.

> We hope to establish some models for describing kernel procedures such
> as IO and network, which requires that it does not rely on architecture
> and does not rely to a specific kernel version as much as possible.

That's obviously a goal, but it requires a new approach to tracepoints.
I think a lot of great ideas were discussed in this thread, so I'm
hopeful that we'll come up with solution that will satisfy even
strictest Peter's requirements :)
