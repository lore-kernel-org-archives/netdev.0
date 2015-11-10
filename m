From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH, REPORT] bpf_trace: build error without PERF_EVENTS
Date: Tue, 10 Nov 2015 14:31:38 +0100
Message-ID: <5641F1BA.6040701@iogearbox.net>
References: <4525348.Aq9YoXkChv@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Kaixu Xia <xiakaixu@huawei.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	linux-arm-kernel@lists.infradead.org
To: Arnd Bergmann <arnd@arndb.de>, Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4525348.Aq9YoXkChv@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/10/2015 01:55 PM, Arnd Bergmann wrote:
> In my ARM randconfig tests, I'm getting a build error for
> newly added code in bpf_perf_event_read and bpf_perf_event_output
> whenever CONFIG_PERF_EVENTS is disabled:
>
> kernel/trace/bpf_trace.c: In function 'bpf_perf_event_read':
> kernel/trace/bpf_trace.c:203:11: error: 'struct perf_event' has no member named 'oncpu'
> if (event->oncpu != smp_processor_id() ||
>           ^
> kernel/trace/bpf_trace.c:204:11: error: 'struct perf_event' has no member named 'pmu'
>        event->pmu->count)
>
> This can happen when UPROBE_EVENT is enabled but KPROBE_EVENT
> is disabled. I'm not sure if that is a configuration we care
> about, otherwise we could prevent this case from occuring by
> adding Kconfig dependencies.

I think that seems better than spreading #if IS_ENABLEDs into the code.
Probably enough to add a 'depends on PERF_EVENTS' to config BPF_EVENTS,
so it's also explicitly documented.

> Simply hiding the broken code inside #ifdef CONFIG_PERF_EVENTS
> as this patch does seems to reliably fix the error as well,
> I have built thousands of randconfig kernels since I started
> seeing this and added the workaround.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 62544ce8e01c ("bpf: fix bpf_perf_event_read() helper")
> Fixes: a43eec304259 ("bpf: introduce bpf_perf_event_output() helper")

Thanks,
Daniel
