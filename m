From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH, net-next] perf, bpf: fix conditional call to
 bpf_overflow_handler
Date: Thu, 8 Sep 2016 08:30:52 +0200
Message-ID: <20160908063052.GA24253@gmail.com>
References: <20160906131033.1784262-1-arnd@arndb.de>
 <20160906153349.GA38225@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Alexei Starovoitov <ast@kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Ingo Molnar <mingo@redhat.com>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Alexander Shishkin <alexander.shishkin@linux.intel.com>,
        Alexei Starovoitov <ast@fb.com>, linux-kernel@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160906153349.GA38225@ast-mbp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> On Tue, Sep 06, 2016 at 03:10:22PM +0200, Arnd Bergmann wrote:
> > The newly added bpf_overflow_handler function is only built of both
> > CONFIG_EVENT_TRACING and CONFIG_BPF_SYSCALL are enabled, but the caller
> > only checks the latter:
> > 
> > kernel/events/core.c: In function 'perf_event_alloc':
> > kernel/events/core.c:9106:27: error: 'bpf_overflow_handler' undeclared (first use in this function)
> > 
> > This changes the caller so we also skip this call if CONFIG_EVENT_TRACING
> > is disabled entirely.
> > 
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > Fixes: aa6a5f3cb2b2 ("perf, bpf: add perf events core support for BPF_PROG_TYPE_PERF_EVENT programs")
> > ---
> >  kernel/events/core.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > I'm not entirely sure if this is the correct solution, please check before applying
> 
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> 
> Thanks for the fix. Just saw build bot complaining last night and
> by the morning your fix is already here. Thanks!

Guys, this is the first time I saw this patch (and presumably there's some other 
patch as well?) - could you please submit it properly for review and get an 
Acked-by from one of the perf maintainers before appying it?

Thanks,

	Ingo
