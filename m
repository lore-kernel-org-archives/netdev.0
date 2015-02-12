From: Hekuang <hekuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v3 linux-trace 1/8] tracing: attach eBPF programs to tracepoints
 and syscalls
Date: Thu, 12 Feb 2015 12:58:27 +0800
Message-ID: <54DC32F3.7040403@huawei.com>
References: <CAMEtUuzY_Po=WtFEFg1aqzJ8dEF4rHGcWDsaS44KYgACMNPPgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, <wangnan0-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMEtUuzY_Po=WtFEFg1aqzJ8dEF4rHGcWDsaS44KYgACMNPPgA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


>> eBPF is very flexible, which means it is bound to have someone use it
>> in a way you never dreamed of, and that will be what bites you in the
>> end (pun intended).
> understood :)
> let's start slow then with bpf+syscall and bpf+kprobe only.


I think BPF + system calls/kprobes can meet our use case
(https://lkml.org/lkml/2015/2/6/44), but there're some issues to be
improved.

I suggest that you can improve bpf+kprobes when attached to function
headers(or TRACE_MARKERS), make it converts pt-regs to bpf_ctx->arg1,
arg2.., then top models and architectures can be separated by bpf.

BPF bytecode is cross-platform, but what we can get by using bpf+kprobes
is a 'regs->rdx' kind of information, such information is both
architecture and kernel version related.

We hope to establish some models for describing kernel procedures such
as IO and network, which requires that it does not rely on architecture
and does not rely to a specific kernel version as much as possible.
