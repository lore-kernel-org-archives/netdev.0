From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH, REPORT] bpf_trace: build error without PERF_EVENTS
Date: Tue, 10 Nov 2015 09:14:22 -0800
Message-ID: <20151110171421.GA21650@ast-mbp.thefacebook.com>
References: <4525348.Aq9YoXkChv@wuerfel>
 <5641F1BA.6040701@iogearbox.net>
 <20151110092501.0bc676c9@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Kaixu Xia <xiakaixu@huawei.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	linux-arm-kernel@lists.infradead.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151110092501.0bc676c9@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 10, 2015 at 09:25:01AM -0500, Steven Rostedt wrote:
> On Tue, 10 Nov 2015 14:31:38 +0100
> Daniel Borkmann <daniel@iogearbox.net> wrote:
> 
> > On 11/10/2015 01:55 PM, Arnd Bergmann wrote:
> > > In my ARM randconfig tests, I'm getting a build error for
> > > newly added code in bpf_perf_event_read and bpf_perf_event_output
> > > whenever CONFIG_PERF_EVENTS is disabled:
> > >
> > > kernel/trace/bpf_trace.c: In function 'bpf_perf_event_read':
> > > kernel/trace/bpf_trace.c:203:11: error: 'struct perf_event' has no member named 'oncpu'
> > > if (event->oncpu != smp_processor_id() ||
> > >           ^
> > > kernel/trace/bpf_trace.c:204:11: error: 'struct perf_event' has no member named 'pmu'
> > >        event->pmu->count)
> > >
> > > This can happen when UPROBE_EVENT is enabled but KPROBE_EVENT
> > > is disabled. I'm not sure if that is a configuration we care
> > > about, otherwise we could prevent this case from occuring by
> > > adding Kconfig dependencies.  
> > 
> > I think that seems better than spreading #if IS_ENABLEDs into the code.
> > Probably enough to add a 'depends on PERF_EVENTS' to config BPF_EVENTS,
> > so it's also explicitly documented.
> > 
> 
> So just do the following then?
> 
> -- Steve
> 
> diff --git a/kernel/trace/Kconfig b/kernel/trace/Kconfig
> index 8d6363f42169..f5aecff2d243 100644
> --- a/kernel/trace/Kconfig
> +++ b/kernel/trace/Kconfig
> @@ -434,7 +434,7 @@ config UPROBE_EVENT
>  
>  config BPF_EVENTS
>  	depends on BPF_SYSCALL
> -	depends on KPROBE_EVENT || UPROBE_EVENT
> +	depends on KPROBE_EVENT && UPROBE_EVENT

yeah that's definitely cleaner and avoids ifdef creep in the future.
