From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 6/7] slub: improve bulk alloc strategy
Date: Mon, 15 Jun 2015 11:36:40 -0500 (CDT)
Message-ID: <alpine.DEB.2.11.1506151135130.20358@east.gentwo.org>
References: <20150615155053.18824.617.stgit@devil> <20150615155246.18824.3788.stgit@devil>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
    netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20150615155246.18824.3788.stgit@devil>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, 15 Jun 2015, Jesper Dangaard Brouer wrote:

> -			break;
> +		if (unlikely(!object)) {
> +			c->tid = next_tid(c->tid);

tid increment is not needed here since the per cpu information is not
modified.

> +			local_irq_enable();
> +
> +			/* Invoke slow path one time, then retry fastpath
> +			 * as side-effect have updated c->freelist
> +			 */
> +			p[i] = __slab_alloc(s, flags, NUMA_NO_NODE,
> +					    _RET_IP_, c);
> +			if (unlikely(!p[i])) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
