From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 net-next 1/3] perf, bpf: Add BPF support to all
 perf_event types
Date: Tue, 30 May 2017 21:03:39 +0200
Message-ID: <20170530190339.svpp53bggfznc476@hirez.programming.kicks-ass.net>
References: <20170526055549.557818-1-ast@fb.com>
 <20170526055549.557818-2-ast@fb.com>
 <20170529091253.lopsd33qticsbgii@hirez.programming.kicks-ass.net>
 <20170529093918.xmbijgozjrfi22ru@hirez.programming.kicks-ass.net>
 <a6bf362c-9df9-f387-bac3-ab5516e4cb68@fb.com>
 <20170530165102.kvcutyfp6i2in2zx@hirez.programming.kicks-ass.net>
 <132719d0-a18c-d4a0-8e72-56658c0c344f@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Teng Qin <qinteng@fb.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <132719d0-a18c-d4a0-8e72-56658c0c344f@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 30, 2017 at 10:37:46AM -0700, Alexei Starovoitov wrote:
> On 5/30/17 9:51 AM, Peter Zijlstra wrote:

> > I'm not entirely sure I see how that is required. Should per task not
> > already work? The WARN that's there will only trigger if you call them
> > on the wrong task, which is something you shouldn't do anyway.
> 
> The kernel WARN is considered to be a bug of bpf infra. That's the
> reason we do all these checks at map update time and at run-time.
> The bpf program authors should be able to do all possible experiments
> until their scripts work. Dealing with kernel warns and reboots is not
> something user space folks like to do.
> Today bpf_perf_event_read() for per-task events isn't really
> working due to event->oncpu != cpu runtime check in there.
> If we convert warns to returns the existing scripts will continue
> to work as-is and per-task will be possible.

Ah yes.. I always forget that side of things (not ever having seen a
bpf thing working doesn't help either of course).

Let me consider that for a bit..
