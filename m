From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v5 tip 0/7] tracing: attach eBPF programs to kprobes
Date: Sat, 07 Mar 2015 16:21:19 -0800
Message-ID: <54FB95FF.3060502@plumgrid.com>
References: <1425252465-27527-1-git-send-email-ast@plumgrid.com>	<CAMEtUuzOQqyXgZaytwOPxAfn5ucu08HjAMrFUgeSaLRVg9E0rg@mail.gmail.com>	<20150304203316.GA7142@gmail.com>	<20150304154824.5f165c6d@gandalf.local.home> <20150306200938.6a6387c0@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150306200938.6a6387c0@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/6/15 5:09 PM, Steven Rostedt wrote:
> On Wed, 4 Mar 2015 15:48:24 -0500
> Steven Rostedt <rostedt@goodmis.org> wrote:
>
>> On Wed, 4 Mar 2015 21:33:16 +0100
>> Ingo Molnar <mingo@kernel.org> wrote:
>>
>>>
>>> * Alexei Starovoitov <ast@plumgrid.com> wrote:
>>>
>>>> On Sun, Mar 1, 2015 at 3:27 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>>>>> Peter, Steven,
>>>>> I think this set addresses everything we've discussed.
>>>>> Please review/ack. Thanks!
>>>>
>>>> icmp echo request
>>>
>>> I'd really like to have an Acked-by from Steve (propagated into the
>>> changelogs) before looking at applying these patches.
>>
>> I'll have to look at this tomorrow. I'm a bit swamped with other things
>> at the moment :-/
>>
>
> Just an update. I started looking at it but then was pulled off to do
> other things. I'll make this a priority next week. Sorry for the delay.

There is no rush. Please let me know if I need to clarify anything.
One thing I just caught which I'm planning to address in the follow on
patch is missing 'recursion check'. Since attaching programs to kprobes
means that root may create loops by adding a kprobe somewhere in
the call chain invoked from bpf program. So far I'm thinking to do
simple stack_trace_call()-like check. I don't think it's a blocker
for this set, but if I'm done coding recursion soon, I'll just
roll it in and respin this set :)
