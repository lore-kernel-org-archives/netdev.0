From: John Stultz <john.stultz@linaro.org>
Subject: Re: [PATCH 1/4] [RFC] net: Explicitly initialize u64_stats_sync structures
 for lockdep
Date: Wed, 23 Oct 2013 11:23:03 -0700
Message-ID: <52681407.8060804@linaro.org>
References: <1381186321-4906-1-git-send-email-john.stultz@linaro.org> <1381186321-4906-2-git-send-email-john.stultz@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Mirko Lindner <mlindner@marvell.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Roger Luethi <rl@hellgate.ch>,
	Patrick McHardy <kaber@trash.net>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>, Jesse Gross <jesse@nicira.com>,
	Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: John Stultz <john.stultz@linaro.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1381186321-4906-2-git-send-email-john.stultz@linaro.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/07/2013 03:51 PM, John Stultz wrote:
> In order to enable lockdep on seqcount/seqlock structures, we
> must explicitly initialize any locks.
>
> The u64_stats_sync structure, uses a seqcount, and thus we need
> to introduce a u64_stats_init() function and use it to initialize
> the structure.
>
> This unfortunately adds a lot of fairly trivial initialization code
> to a number of drivers. But the benefit of ensuring correctness makes
> this worth while.
>
> Because these changes are required for lockdep to be enabled, and the
> changes are quite trivial, I've not yet split this patch out into 30-some
> separate patches, as I figured it would be better to get the various
> maintainers thoughts on how to best merge this change along with
> the seqcount lockdep enablement.

Just wanted to ping folks on this patch, as I haven't gotten any feedback.

As its a prereq for the seqcount lockdep support, I'd like to get it
queued/merged, but I'm not sure what the right maintainer path or
approach should be.

1) Do folks prefer to see this patch split up into 30-some separate
trivial clenaup patches, or have it go in all as one logical change?

2) Would folks want this patch (in whichever form) to be merged
separately via the networking maintainers, or can it be merged via -tip
as part of the seqcount lockdep series?

thanks
-john
