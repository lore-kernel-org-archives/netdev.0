From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v3 linux-trace 1/8] tracing: attach eBPF programs to
 tracepoints and syscalls
Date: Mon, 23 Feb 2015 13:55:12 -0500
Message-ID: <CAMEtUuwqhUpxVrKn_Km_JE76hco+y7Ev4ESzvbmAERBTuidY=A@mail.gmail.com>
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
To: He Kuang <hekuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 16, 2015 at 6:26 AM, He Kuang <hekuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org> wrote:
> Hi, Alexei
>
> Another suggestion on bpf syscall interface. Currently, BPF +
> syscalls/kprobes depends on CONFIG_BPF_SYSCALL. In kernel used on
> commercial products, CONFIG_BPF_SYSCALL is probably disabled, in this
> case, bpf bytecode cannot be loaded to the kernel.

I'm seeing a flurry of use cases for bpf in ovs, tc, tracing, etc
When it's all ready, we can turn that config on by default.

> If we turn the functionality of BPF_SYSCALL into a loadable module, then
> we can use it without any dependencies on the kernel. What about change
> bpf syscall to a /dev node or /sys file which can be exported by a
> kernel module?

I don't think we will allow extending bpf by modules.
'bpf in modules' is an interface that is too easy to abuse.
So all of bpf core, helper functions and program types will be builtin.

As far as bpf+tracing the plan is to do bpf+kprobe and bpf+syscalls
first. Then add right set of helpers to make sure that use cases
like 'tcp stack instrumentation' are fully addressed.
Then there were few great ideas of accelerating kprobes
with trace markers and debug tracepoints that we can do later.
