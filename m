From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH v3 linux-trace 1/8] tracing: attach eBPF programs to
 tracepoints and syscalls
Date: Wed, 11 Feb 2015 07:51:42 -0500
Message-ID: <20150211075142.7d0f8ca1@gandalf.local.home>
References: <CAMEtUuxizvHF09y_vU-c+L=n16tqWDqJPTybGB1a_OqN7p+jsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
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
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMEtUuxizvHF09y_vU-c+L=n16tqWDqJPTybGB1a_OqN7p+jsA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 10 Feb 2015 22:33:05 -0800
Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:


> fair enough.
> Something like TRACE_MARKER(arg1, arg2) that prints
> it was hit without accessing the args would be enough.
> Without any args it is indeed a 'fast kprobe' only.
> Debug info would still be needed to access
> function arguments.
> On x64 function entry point and x64 abi make it easy
> to access args, but i386 or kprobe in the middle
> lose visibility when debug info is not available.
> TRACE_MARKER (with few key args that function
> is operating on) is enough to achieve roughly the same
> as kprobe without debug info.

Actually, what about a TRACE_EVENT_DEBUG(), that has a few args and
possibly a full trace event layout.

The difference would be that the trace events do not show up unless you
have "trace_debug" on the command line. This should prevent
applications from depending on them.

I could even do the nasty dmesg output like I do with trace_printk()s,
that would definitely keep a production kernel from adding it by
default.

When trace_debug is not there, the trace points could still be accessed
but perhaps only via bpf, or act like a simple trace marker.

Note, if you need ids, I rather have them in another directory than
tracefs. Make a eventfs perhaps that holds these. I rather keep tracefs
simple.

This is something that needs to probably be discussed at bit.

-- Steve
