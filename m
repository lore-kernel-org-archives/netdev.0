From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH v3 linux-trace 0/8] tracing: attach eBPF programs to
 tracepoints/syscalls/kprobe
Date: Tue, 10 Feb 2015 09:55:12 -0500
Message-ID: <20150210095512.42d8dede@grimm.local.home>
References: <1423539961-21792-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1423539961-21792-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon,  9 Feb 2015 19:45:53 -0800
Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:

> So the overhead of realistic bpf program is 5.05963/4.80074 = ~5%
> which is faster than perf_event filtering: 5.69732/4.80074 = ~18%
> or ftrace filtering: 6.50091/4.80074 = ~35%

Come to think of it, this is comparing apples to oranges, as you move
the filtering before the recording. It would be interesting to see the
ftrace speed up, if it were to use eBPF instead of its own filtering.
Maybe that 35% is the filter part, and not the discard part.

I just tried the dd test with count==1234 and count!=1234 and the one
that drops events is only slightly slower. In this case it does seem
that the most overhead is in the filter logic.

But by moving it before the recording, we can not use the fields
defined in the format files, as the parameters and the fields do not
match in most trace points. And to use the parameters, as I have
stated, there's no interface to know what those parameters are, then
filtering on them is a one shot deal. Might as well write a module and
hook directly to the tracepoint and do the filtering natively. That
would be faster than BPF too.

My point is, what's the use case? If you filter before recording, you
can not use the fields of the tracepoint. That limits you to filtering
only syscalls, and perhaps kprobes.

-- Steve
