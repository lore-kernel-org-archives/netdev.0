From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH v3 linux-trace 1/8] tracing: attach eBPF programs to
 tracepoints and syscalls
Date: Wed, 11 Feb 2015 11:28:52 +0100
Message-ID: <20150211102852.GQ23123@twins.programming.kicks-ass.net>
References: <CAMEtUuwAf4AFeWVEdJB4VQz_=2fWY=q8=rbkFg38rtVtNVCHxg@mail.gmail.com>
 <20150210165359.34cc53d9@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
To: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20150210165359.34cc53d9-f9ZlEuEWxVcJvu8Pb33WZ0EMvNT87kid@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 10, 2015 at 04:53:59PM -0500, Steven Rostedt wrote:
> > >> In the future we might add a tracepoint and pass a single
> > >> pointer to interesting data struct to it. bpf programs will walk
> > >> data structures 'as safe modules' via bpf_fetch*() methods
> > >> without exposing it as ABI.
> > >
> > > Will this work if that structure changes? When the field we are looking
> > > for no longer exists?
> > 
> > bpf_fetch*() is the same mechanism as perf probe.
> > If there is a mistake by user space tools, the program
> > will be reading some junk, but it won't be crashing.
> 
> But what if the userspace tool depends on that value returning
> something meaningful. If it was meaningful in the past, it will have to
> be meaningful in the future, even if the internals of the kernel make
> it otherwise.

We're compiling the BPF stuff against the 'current' kernel headers
right? So would enforcing module versioning not be sufficient?

We already break out-of-tree modules without a second thought, the
module interface is not guaranteed. They just need to cope with it.

Anything using the kernel headers to look into the kernel guts should be
bound to the same rules.

So if we think of BFP stuff as out-of-tree modules, and treat them the
same, I see no problem.

I'm sure some BFP 'scripts' will turn in the same right mess that
out-of-tree modules are, with endless #ifdef version checks, but hey,
not my problem ;-)
