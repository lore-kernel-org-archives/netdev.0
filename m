From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] softirq: reduce latencies
Date: Thu, 3 Jan 2013 22:08:00 +0000
Message-ID: <1357250880.2685.29.camel@bwh-desktop.uk.solarflarecom.com>
References: <1357216132.21409.24107.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1357216132.21409.24107.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-01-03 at 04:28 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> In various network workloads, __do_softirq() latencies can be up
> to 20 ms if HZ=1000, and 200 ms if HZ=100.
> 
> This is because we iterate 10 times in the softirq dispatcher,
> and some actions can consume a lot of cycles.
> 
> This patch changes the fallback to ksoftirqd condition to :
> 
> - A time limit of 2 ms.
> - need_resched() being set on current task
[...]
> --- a/kernel/softirq.c
> +++ b/kernel/softirq.c
[...]
> -#define MAX_SOFTIRQ_RESTART 10
> +#define MAX_SOFTIRQ_TIME  min(1, (2*HZ/1000))
[...]

Really?  Never iterate if HZ < 500?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
