From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch v2 1/3] mm: remove GFP_THISNODE
Date: Fri, 27 Feb 2015 16:53:16 -0600 (CST)
Message-ID: <alpine.DEB.2.11.1502271649060.20876@gentwo.org>
References: <alpine.DEB.2.10.1502251621010.10303@chino.kir.corp.google.com> <alpine.DEB.2.10.1502271415510.7225@chino.kir.corp.google.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>,
    Vlastimil Babka <vbabka@suse.cz>, Pekka Enberg <penberg@kernel.org>,
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>,
    Mel Gorman <mgorman@suse.de>, Pravin Shelar <pshelar@nicira.com>,
    Jarno Rajahalme <jrajahalme@nicira.com>, Li Zefan <lizefan@huawei.com>,
    Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org,
    linux-mm@kvack.org, netdev@vger.kernel.org, cgroups@vger.kernel.org,
    dev@openvswitch.org
To: David Rientjes <rientjes@google.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <alpine.DEB.2.10.1502271415510.7225@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Fri, 27 Feb 2015, David Rientjes wrote:

> +/*
> + * Construct gfp mask to allocate from a specific node but do not invoke reclaim
> + * or warn about failures.
> + */

We should be triggering reclaim from slab allocations. Why would we not do
this?

Otherwise we will be going uselessly off node for slab allocations.

> +static inline gfp_t gfp_exact_node(gfp_t flags)
> +{
> +	return (flags | __GFP_THISNODE | __GFP_NOWARN) & ~__GFP_WAIT;
> +}
>  #endif

Reclaim needs to be triggered. In particular zone reclaim was made to be
triggered from slab allocations to create more room if needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
