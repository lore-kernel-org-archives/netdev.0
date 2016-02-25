From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 2/3] bpf: introduce BPF_MAP_TYPE_STACK_TRACE
Date: Thu, 25 Feb 2016 17:50:05 +0100
Message-ID: <20160225165005.GU6356@twins.programming.kicks-ass.net>
References: <1455767939-2700534-1-git-send-email-ast@fb.com>
 <1455767939-2700534-3-git-send-email-ast@fb.com>
 <20160225142328.GN6357@twins.programming.kicks-ass.net>
 <56CF2F00.2020608@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Wang Nan <wangnan0@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56CF2F00.2020608@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 25, 2016 at 08:42:40AM -0800, Alexei Starovoitov wrote:
> On 2/25/16 6:23 AM, Peter Zijlstra wrote:
> >>+	id = hash & (smap->n_buckets - 1);
> >Its not at all clear where the corresponding rcu_read_lock() is at.
> >
> >>>+	bucket = rcu_dereference(smap->buckets[id]);
> 
> bpf programs of all types are always executing under rcu_read_lock().
> This is fundamental for maps and majority of the helpers
> that's why there is no WARN_ON(rcu_read_lock_held) in this helper,
> since we already have it in many other places.
> The rcu_read_lock() for kprobe type is in trace_call_bpf().

OK, just not clear from reading this patch in isolation I suppose.
