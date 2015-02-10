From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH v3 linux-trace 4/8] samples: bpf: simple tracing example
 in C
Date: Tue, 10 Feb 2015 07:24:12 -0500
Message-ID: <20150210072412.3ee73362@grimm.local.home>
References: <1423539961-21792-1-git-send-email-ast@plumgrid.com>
	<1423539961-21792-5-git-send-email-ast@plumgrid.com>
	<20150209230836.7f913c60@grimm.local.home>
	<20150210001608.157a9190@grimm.local.home>
	<CAMEtUuzon5LfG7PS9YmuW+0GzYMKehz1Ddk+6tXogZOZYdpb3g@mail.gmail.com>
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
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMEtUuzon5LfG7PS9YmuW+0GzYMKehz1Ddk+6tXogZOZYdpb3g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Added Linus because he's the one that would revert changes on breakage.

On Mon, 9 Feb 2015 21:45:21 -0800
Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:

> On Mon, Feb 9, 2015 at 9:16 PM, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org> wrote:
> > On Mon, 9 Feb 2015 23:08:36 -0500
> > Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org> wrote:
> >
> >> I don't want to get stuck with pinned kernel data structures again. We
> >> had 4 blank bytes of data for every event, because latency top hard
> >> coded the field. Luckily, the 64 bit / 32 bit interface caused latency
> >> top to have to use the event_parse code to work, and we were able to
> >> remove that field after it was converted.
> 
> I think your main point boils down to:
> 
> > But I still do not want any hard coded event structures. All access to
> > data from the binary code must be parsed by looking at the event/format
> > files. Otherwise you will lock internals of the kernel as userspace
> > ABI, because eBPF programs will break if those internals change, and
> > that could severely limit progress in the future.
> 
> and I completely agree.
> 
> the patch 4 is an example. It doesn't mean in any way
> that structs defined here is an ABI.
> To be compatible across kernels the user space must read
> format file as you mentioned in your other reply.

The thing is, this is a sample. Which means it will be cut and pasted
into other programs. If the sample does not follow the way we want
users to use this, then how can we complain if they hard code it as
well?

> 
> > I'm wondering if we should label eBPF programs as "modules". That is,
> > they have no guarantee of working from one kernel to the next. They
> > execute in the kernel, thus they are very similar to modules.
> >
> > If we can get Linus to say that eBPF programs are not user space, and
> > that they are treated the same as modules (no internal ABI), then I
> > think we can be a bit more free at what we allow.
> 
> I thought we already stated that.
> Here is the quote from perf_event.h:
>          *      # The RAW record below is opaque data wrt the ABI
>          *      #
>          *      # That is, the ABI doesn't make any promises wrt to
>          *      # the stability of its content, it may vary depending
>          *      # on event, hardware, kernel version and phase of
>          *      # the moon.
>          *      #
>          *      # In other words, PERF_SAMPLE_RAW contents are not an ABI.
> 
> and this example is reading PERF_SAMPLE_RAW events and
> uses locally defined structs to print them for simplicity.

As we found out the hard way with latencytop, comments like this does
not matter. If an application does something like this, it's our fault
if it breaks later. We can't say "hey you were suppose to do it this
way". That argument breaks down even more if our own examples do not
follow the way we want others to do things.

-- Steve
