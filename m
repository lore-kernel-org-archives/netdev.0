From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 1/3] perf: generalize perf_callchain
Date: Thu, 25 Feb 2016 17:47:29 +0100
Message-ID: <20160225164729.GS6356@twins.programming.kicks-ass.net>
References: <1455767939-2700534-1-git-send-email-ast@fb.com>
 <1455767939-2700534-2-git-send-email-ast@fb.com>
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
In-Reply-To: <1455767939-2700534-2-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 17, 2016 at 07:58:57PM -0800, Alexei Starovoitov wrote:
> +static inline int perf_callchain_store(struct perf_callchain_entry *entry, u64 ip)
>  {
> +	if (entry->nr < PERF_MAX_STACK_DEPTH) {
>  		entry->ip[entry->nr++] = ip;
> +		return 0;
> +	} else {
> +		return -1; /* no more room, stop walking the stack */
> +	}
>  }

Why 0 and -1 ?

What's wrong with something like:

static inline bool perf_callchain_store(struct perf_callchain_entry *entry, u64 ip)
{
	if (entry->nr < PERF_MAX_STACK_DEPTH) {
		entry->ip[entry->nr++] = ip;
		return true;
	}
	return false;
}
