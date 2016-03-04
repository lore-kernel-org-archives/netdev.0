From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH 0/7] net: bulk alloc side and more bulk free
 drivers
Date: Fri, 4 Mar 2016 08:36:44 -0800
Message-ID: <20160304163641.GA52086@ast-mbp.thefacebook.com>
References: <20160304130054.32651.51776.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	eugenia@mellanox.com, Alexander Duyck <alexander.duyck@gmail.com>,
	saeedm@mellanox.com, gerlitz.or@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36468 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754763AbcCDQgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 11:36:53 -0500
Received: by mail-pa0-f47.google.com with SMTP id fi3so35469804pac.3
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2016 08:36:53 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160304130054.32651.51776.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 04, 2016 at 02:01:14PM +0100, Jesper Dangaard Brouer wrote:
> This patchset use the bulk ALLOC side of the kmem_cache bulk APIs, for
> SKB allocations.  The bulk free side got enabled in merge commit
> 3134b9f019f2 ("net: mitigating kmem_cache free slowpath").
> 
> The first two patches is a followup on the free-side, which enables
> bulk-free in the drivers mlx4 and mlx5 (dev_kfree_skb -> napi_consume_skb).
> 
> Rest of patchset is focused on bulk alloc-side.  We start with a
> conservative bulk alloc of 8 SKB, which all drivers using the
> napi_alloc_skb() call will benefit from.  Then the API is extended to,
> allow driver hinting on needed SKBs (only some drivers know this
> size), and mlx5 driver is the first user of hinting.

patches 1-5 look very good to me. Should help all cases afaik.
As far as 6-7 about hints I have a question. Does this hint
actually makes the difference? The fixed bulk alloc of 8 probably
easier for the main slub, but when mlx5 starts doing 'work_done' as
a hint there will be more 'random' bulking going on.
Was wondering whether you have the perf numbers to back up 6/7
