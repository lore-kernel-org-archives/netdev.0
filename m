From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v3 linux-trace 4/8] samples: bpf: simple tracing example
 in C
Date: Mon, 9 Feb 2015 21:45:21 -0800
Message-ID: <CAMEtUuzon5LfG7PS9YmuW+0GzYMKehz1Ddk+6tXogZOZYdpb3g@mail.gmail.com>
References: <1423539961-21792-1-git-send-email-ast@plumgrid.com>
 <1423539961-21792-5-git-send-email-ast@plumgrid.com> <20150209230836.7f913c60@grimm.local.home>
 <20150210001608.157a9190@grimm.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ingo Molnar <mingo@kernel.org>, Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150210001608.157a9190@grimm.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 9, 2015 at 9:16 PM, Steven Rostedt <rostedt@goodmis.org> wrote:
> On Mon, 9 Feb 2015 23:08:36 -0500
> Steven Rostedt <rostedt@goodmis.org> wrote:
>
>> I don't want to get stuck with pinned kernel data structures again. We
>> had 4 blank bytes of data for every event, because latency top hard
>> coded the field. Luckily, the 64 bit / 32 bit interface caused latency
>> top to have to use the event_parse code to work, and we were able to
>> remove that field after it was converted.

I think your main point boils down to:

> But I still do not want any hard coded event structures. All access to
> data from the binary code must be parsed by looking at the event/format
> files. Otherwise you will lock internals of the kernel as userspace
> ABI, because eBPF programs will break if those internals change, and
> that could severely limit progress in the future.

and I completely agree.

the patch 4 is an example. It doesn't mean in any way
that structs defined here is an ABI.
To be compatible across kernels the user space must read
format file as you mentioned in your other reply.

> I'm wondering if we should label eBPF programs as "modules". That is,
> they have no guarantee of working from one kernel to the next. They
> execute in the kernel, thus they are very similar to modules.
>
> If we can get Linus to say that eBPF programs are not user space, and
> that they are treated the same as modules (no internal ABI), then I
> think we can be a bit more free at what we allow.

I thought we already stated that.
Here is the quote from perf_event.h:
         *      # The RAW record below is opaque data wrt the ABI
         *      #
         *      # That is, the ABI doesn't make any promises wrt to
         *      # the stability of its content, it may vary depending
         *      # on event, hardware, kernel version and phase of
         *      # the moon.
         *      #
         *      # In other words, PERF_SAMPLE_RAW contents are not an ABI.

and this example is reading PERF_SAMPLE_RAW events and
uses locally defined structs to print them for simplicity.
