From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] bpf_trace: Make dependent on PERF_EVENTS
Date: Tue, 10 Nov 2015 21:39:54 +0100
Message-ID: <48940555.m1MPQSFTCK@wuerfel>
References: <20151110152817.144195a0@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Wang Nan <wangnan0@huawei.com>, Kaixu Xia <xiakaixu@huawei.com>,
 Daniel Borkmann <daniel@iogearbox.net>, Peter Zijlstra <peterz@infradead.org>,
 netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
 Steven Rostedt <rostedt@goodmis.org>, Alexei Starovoitov <ast@kernel.org>,
 Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@kernel.org>,
 Hannes Frederic Sowa <hannes@stressinduktion.org>,
 "David S. Miller" <davem@davemloft.net>
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20151110152817.144195a0@gandalf.local.home>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Tuesday 10 November 2015 15:28:17 Steven Rostedt wrote:
> Arnd Bergmann reported:
> 
>   In my ARM randconfig tests, I'm getting a build error for
>   newly added code in bpf_perf_event_read and bpf_perf_event_output
>   whenever CONFIG_PERF_EVENTS is disabled:
> 
>   kernel/trace/bpf_trace.c: In function 'bpf_perf_event_read':
>   kernel/trace/bpf_trace.c:203:11: error: 'struct perf_event' has no member named 'oncpu'
>   if (event->oncpu != smp_processor_id() ||
>            ^
>   kernel/trace/bpf_trace.c:204:11: error: 'struct perf_event' has no member named 'pmu'
>         event->pmu->count)
> 
>   This can happen when UPROBE_EVENT is enabled but KPROBE_EVENT
>   is disabled. I'm not sure if that is a configuration we care
>   about, otherwise we could prevent this case from occuring by
>   adding Kconfig dependencies.
> 
> Looking at this further, it's really that UPROBE_EVENT enables PERF_EVENTS.
> By just having BPF_EVENTS depend on PERF_EVENTS, then all is fine.
> 
> Link: http://lkml.kernel.org/r/4525348.Aq9YoXkChv@wuerfel
> Reported-by: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: Steven Rostedt <rostedt@goodmis.org>
> 

Ok, sounds good.

Acked-by: Arnd Bergmann <arnd@arndb.de>
