From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bpf_trace: Make dependent on PERF_EVENTS
Date: Tue, 10 Nov 2015 15:40:35 -0500 (EST)
Message-ID: <20151110.154035.1545699029296918207.davem@davemloft.net>
References: <20151110152817.144195a0@gandalf.local.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, arnd@arndb.de, mingo@redhat.com,
	ast@kernel.org, daniel@iogearbox.net, xiakaixu@huawei.com,
	hannes@stressinduktion.org, wangnan0@huawei.com,
	netdev@vger.kernel.org, acme@kernel.org,
	linux-arm-kernel@lists.infradead.org, peterz@infradead.org
To: rostedt@goodmis.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151110152817.144195a0@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steven Rostedt <rostedt@goodmis.org>
Date: Tue, 10 Nov 2015 15:28:17 -0500

> 
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

I'll apply this, thanks Steven et al.
