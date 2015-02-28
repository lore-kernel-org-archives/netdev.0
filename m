From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v4 tip 3/7] tracing: allow BPF programs to call ktime_get_ns()
Date: Sat, 28 Feb 2015 09:21:20 -0800
Message-ID: <CAMEtUux5qv=b8HM1_p_WV5_HWzgmJhSq+AHSGQ4Ag9c-QLr81A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 28, 2015 at 2:20 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>>
>> +static u64 bpf_ktime_get_ns(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
>> +{
>> +     return ktime_get_ns();
>> +}
>
> Please use ktime_get_mono_fast_ns() instead. If you ever want to allow
> running BPF stuff from general tracepoints and the like you need to
> be NMI safe.

good point. will do.
Currently in trace_call_bpf() I have:
if (in_nmi()) /* not supported yet */
  return 1;
to tackle nmi after all pieces are in place.
Likely nmi-safe programs will have access to reduced set
of helper functions.
