From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH V1 0/3] net: enable use of
 kmem_cache_alloc_bulk in network stack
Date: Fri, 20 May 2016 10:14:46 +0200
Message-ID: <20160520101446.64416d2b@redhat.com>
References: <20160509134352.3573.37044.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, gerlitz.or@gmail.com, eugenia@mellanox.com,
	Alexander Duyck <alexander.duyck@gmail.com>, brouer@redhat.com
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57393 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932381AbcETIOw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 May 2016 04:14:52 -0400
In-Reply-To: <20160509134352.3573.37044.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 09 May 2016 15:44:24 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> This patchset enables use of the slab/kmem_cache bulk alloc API, and
> completes the use the slab/kmem_cache bulking API in the network stack.
> 
> I've not included the patches that introduce a SKB bulk hint, which
> would beneficial for drivers like mlx5.  Lets see if we can agree on
> this patchset first.

Conclusion: Guess we could not agree on this patchset.

The main problem seems to be that the patch always bulk allocated 8
SKBs, without knowing if we actually need them.  My earlier patchset
also included a "hint" interface, as mlx5 driver knows after processing
the RX queue, how many SKBs it needs, thus it can request to bulk alloc
the needed amount. (The only problem with mlx5 is that preallocating
SKBs into it's RX ring is a broken scheme).

A better scheme would be, if the driver on RX knows how many packets
are available in the RX queue.  Then we can bulk alloc the needed
amount of SKBs.  Thus, we can circle back to this once the driver can
provide this information. (This goes nicely hand-in-hand with my idea
of pulling out avail RX packet-pages from the RX ring, and start
prefetch'es to hide the cache-misses).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
