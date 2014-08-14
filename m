From: Brendan Gregg <brendan.d.gregg@gmail.com>
Subject: Re: [PATCH RFC v4 net-next 25/26] samples: bpf: counting eBPF example
 in C
Date: Thu, 14 Aug 2014 15:13:53 -0700
Message-ID: <CAE40pdcdgRASVEWCrUjHUH3eHp2ohTrK27FCv=Ji62sKNcKggQ@mail.gmail.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
	<1407916658-8731-26-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407916658-8731-26-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 13, 2014 at 12:57 AM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> this example has two probes in C that use two different maps.
>
> 1st probe is the similar to dropmon.c. It attaches to kfree_skb tracepoint and
> count number of packet drops at different locations
>
> 2nd probe attaches to kprobe/sys_write and computes a histogram of different
> write sizes
>
> Usage:
> $ sudo ex2
>
> Should see:
> writing bpf-5 -> /sys/kernel/debug/tracing/events/skb/kfree_skb/filter
> writing bpf-8 -> /sys/kernel/debug/tracing/events/kprobes/sys_write/filter
> location 0xffffffff816efc67 count 1
>
> location 0xffffffff815d8030 count 1
> location 0xffffffff816efc67 count 3
>
> location 0xffffffff815d8030 count 4
> location 0xffffffff816efc67 count 9
>
>            syscall write() stats
>      byte_size       : count     distribution
>        1 -> 1        : 3141     |****                                  |
>        2 -> 3        : 2        |                                      |
>        4 -> 7        : 14       |                                      |
>        8 -> 15       : 3268     |*****                                 |
>       16 -> 31       : 732      |                                      |
>       32 -> 63       : 20042    |************************************* |
>       64 -> 127      : 12154    |**********************                |
>      128 -> 255      : 2215     |***                                   |
>      256 -> 511      : 9        |                                      |
>      512 -> 1023     : 0        |                                      |
>     1024 -> 2047     : 1        |                                      |

This is pretty awesome.

Given that this is tracing two tracepoints at once, I'd like to see a
similar example where time is stored on the first tracepoint,
retrieved on the second for a delta calculation, then presented with a
similar histogram as seen above.

Brendan
