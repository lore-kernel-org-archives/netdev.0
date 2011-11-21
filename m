From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netfilter: use jump_label for nf_hooks
Date: Mon, 21 Nov 2011 16:39:03 -0500 (EST)
Message-ID: <20111121.163903.1188643166689254222.davem@davemloft.net>
References: <1321673566.3157.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	kaber@trash.net, pablo@netfilter.org
To: eric.dumazet@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1321673566.3157.14.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 19 Nov 2011 04:32:46 +0100

> On configs where CONFIG_JUMP_LABEL=y, we can replace in fast path a
> load/compare/conditional jump by a single jump with no dcache reference.
> 
> Jump target is modified as soon as nf_hooks[pf][hook] switches from
> empty state to non empty states. jump_label state is kept outside of
> nf_hooks array so has no cost on cpu caches.
> 
> This patch removes the test on CONFIG_NETFILTER_DEBUG : No need to call
> nf_hook_slow() at all if nf_hooks[pf][hook] is empty, this didnt give
> useful information, but slowed down things a lot.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Patrick McHardy <kaber@trash.net>
> CC: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
> This is obviously a netfilter patch, but since David committed two other
> jump_label patches lately, maybe its better he takes this patch as well
> directly ? Thanks !

I've applied this.

Originally I was at first concerned because you changed the logic that
forced nf_hook_slow() to be invoked when NETFILTER_DEBUG is enabled but
these days that has no real purpose so that part of the change is fine.

Someone might want to double-check this ;-)
