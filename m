From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net-next] net: reorder struct netns_ct for better
 cache-line usage
Date: Fri, 15 Nov 2013 08:17:21 -0800
Message-ID: <1384532241.28716.66.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131115145459.17641.35021.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20131115145459.17641.35021.stgit@dragon>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-11-15 at 15:57 +0100, Jesper Dangaard Brouer wrote:
> Reorder struct netns_ct so that atomic_t "count" changes don't
> slowdown users of read mostly fields.
> 
> This is based on Eric Dumazet's proposed patch:
>  "netfilter: conntrack: remove the central spinlock"
>  http://thread.gmane.org/gmane.linux.network/268758/focus=47306
> 
> The tricky part of cache-aligning this structure, that it is getting
> inlined in struct net (include/net/net_namespace.h), thus changes to
> other netns_xxx structures affects our alignment.
> 
> Eric's original patch contained an ambiguity on 32-bit regarding
> alignment in struct net.  This patch also takes 32-bit into account,
> and in case of changed (struct net) alignment sysctl_xxx entries have
> been ordered according to how often they are accessed.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Reviewed-by: Jiri Benc <jbenc@redhat.com>
> ---
> Yes, I know it's not the time to submit this patch, but
> I just want to let Eric know that I'm planning on extracting
> part of his proposed patch, which have been stalled for months.
> I'll resubmit once net-next/nf-next opens for changes again.

I have no plan working on conntrack in the near future.

I cannot really cope with a 3 months response time to a patch.

Feel free to grab and continue the work, thanks !



