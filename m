From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 linux-trace 1/8] tracing: attach eBPF programs to
 tracepoints and syscalls
Date: Thu, 29 Jan 2015 10:55:07 -0800
Message-ID: <CAMEtUuxHqpz0ERaKbdciX5p7xwoBrpUK0dFRCHxF_o1PfgKh+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Namhyung Kim <namhyung@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 29, 2015 at 4:35 AM, Namhyung Kim <namhyung@kernel.org> wrote:
>>> Right.  I think bpf programs belong to a user process but events are
>>> global resource.  Maybe you also need to consider attaching bpf
>>> program via perf (ioctl?) interface..
>>
>> yes. I did. Please see my reply to Masami.
>> ioctl only works for tracepoints.
>
> What was the problem of kprobes then? :)

Looks like I misread the logic of attaching a filter via perf ioctl.
Looking at it again it seems to be a major change in design:
Instead of adding into ftrace_raw_* helpers, I would add
to perf_trace_* helpers which are very stack heavy
because of 'pt_regs'
Ex: perf_trace_kfree_skb() is using 224 bytes of stack
whereas ftrace_raw_event_kfree_skb() only 80.
which doesn't help in my quest for lowest overhead.
And the discussion about soft- and auto- enable/disable
becomes meaningless, since there is no such things
when it goes through perf events.
I guess it means no hooks through tracefs...
Anyway, I'll hook it up and see which way is cleaner.
