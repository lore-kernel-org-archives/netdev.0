From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH RFC v4 net-next 25/26] samples: bpf: counting eBPF example
 in C
Date: Thu, 14 Aug 2014 23:19:57 -0700
Message-ID: <CAMEtUuxFmGz7hEYf+_Kux5ir28ehJjTPFPfc0k4xfSZ6RcbM+g@mail.gmail.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
	<1407916658-8731-26-git-send-email-ast@plumgrid.com>
	<CAE40pdcdgRASVEWCrUjHUH3eHp2ohTrK27FCv=Ji62sKNcKggQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Brendan Gregg <brendan.d.gregg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAE40pdcdgRASVEWCrUjHUH3eHp2ohTrK27FCv=Ji62sKNcKggQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 14, 2014 at 3:13 PM, Brendan Gregg
<brendan.d.gregg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Wed, Aug 13, 2014 at 12:57 AM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>> this example has two probes in C that use two different maps.
>>
>> 1st probe is the similar to dropmon.c. It attaches to kfree_skb tracepoint and
>> count number of packet drops at different locations
>>
>> 2nd probe attaches to kprobe/sys_write and computes a histogram of different
>> write sizes
>>
>> Usage:
>> $ sudo ex2
>>
>> Should see:
>> writing bpf-5 -> /sys/kernel/debug/tracing/events/skb/kfree_skb/filter
>> writing bpf-8 -> /sys/kernel/debug/tracing/events/kprobes/sys_write/filter
>> location 0xffffffff816efc67 count 1
>>
>> location 0xffffffff815d8030 count 1
>> location 0xffffffff816efc67 count 3
>>
>> location 0xffffffff815d8030 count 4
>> location 0xffffffff816efc67 count 9
>>
>>            syscall write() stats
>>      byte_size       : count     distribution
>>        1 -> 1        : 3141     |****                                  |
>>        2 -> 3        : 2        |                                      |
>>        4 -> 7        : 14       |                                      |
>>        8 -> 15       : 3268     |*****                                 |
>>       16 -> 31       : 732      |                                      |
>>       32 -> 63       : 20042    |************************************* |
>>       64 -> 127      : 12154    |**********************                |
>>      128 -> 255      : 2215     |***                                   |
>>      256 -> 511      : 9        |                                      |
>>      512 -> 1023     : 0        |                                      |
>>     1024 -> 2047     : 1        |                                      |
>
> This is pretty awesome.
>
> Given that this is tracing two tracepoints at once, I'd like to see a
> similar example where time is stored on the first tracepoint,
> retrieved on the second for a delta calculation, then presented with a
> similar histogram as seen above.

Very good point. The time related helpers are missing. In V5 I'm
thinking to add something like bpf_ktime_get_ns().
To associate begin and end events I think bpf_gettid() would be
needed, but that doesn't feel generic enough for helper function,
so I'm leaning toward 'bpf_get_current()' helper that will return
'current' task pointer. eBPF program can use this pointer for
correlation of events or can go exploring task fields with
bpf_fetch_() helpers...

Thank you very much for trying things out and for your feedback!
