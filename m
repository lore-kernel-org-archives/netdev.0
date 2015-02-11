From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v3 linux-trace 1/8] tracing: attach eBPF programs to
 tracepoints and syscalls
Date: Wed, 11 Feb 2015 10:33:08 +0100
Message-ID: <20150211093308.GN23123@twins.programming.kicks-ass.net>
References: <CAMEtUuzY_Po=WtFEFg1aqzJ8dEF4rHGcWDsaS44KYgACMNPPgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@kernel.org>,
	Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMEtUuzY_Po=WtFEFg1aqzJ8dEF4rHGcWDsaS44KYgACMNPPgA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 10, 2015 at 04:22:50PM -0800, Alexei Starovoitov wrote:
> >> not all tools use libtraceevent.
> >> gdb calls perf_event_open directly:
> >> https://sourceware.org/git/gitweb.cgi?p=binutils-gdb.git;a=blob;f=gdb/nat/linux-btrace.c
> >> and parses PERF_RECORD_SAMPLE as a binary.
> >> In this case it's branch records, but I think we never said anywhere
> >> that PERF_SAMPLE_IP | PERF_SAMPLE_ADDR should come
> >> in this particular order.
> >
> > What particular order? Note, that's a hardware event, not a software
> > one.
> 
> yes, but gdb assumes that 'u64 ip' precedes, 'u64 addr'
> when attr.sample_type = IP | ADDR whereas this is an
> internal order of 'if' statements inside perf_output_sample()...

This is indeed promised in the data layout description in
include/uapi/linux/perf_event.h.

There is no other way to find where fields are; perf relies on
predetermined order of fields coupled with the requested field bitmask.

So we promise the order: id, ip, pid, tid, time, addr,.. etc.

So if you request IP and ADDR but none of the other fields, then you
know your sample will start with IP and then contain ADDR.

The traceevent thing has a debug/trace-fs format description of fields
that is supposed to be used.
