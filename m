From: Haggai Abramovsky <haggaia.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net] net/mlx4: Avoid wrong virtual mappings
Date: Wed, 27 Apr 2016 11:21:06 +0300
Message-ID: <CANO=VFF=qLiUV9jtX-gD4PAfheMp0WCV2E+_Ta=77awB4WFzjg@mail.gmail.com>
References: <1461591287-11595-1-git-send-email-hagaya@mellanox.com>
	<20160427071920.GA26712@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Haggai Abramovsky <hagaya-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Sinan Kaya <okaya-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Timur Tabi <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Eran Ben Elisha <eranbe-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160427071920.GA26712-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 27, 2016 at 10:19 AM, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org> wrote:
> Hi Haggai,
>
> I've taken a very quick look because I'm a little too busy this week,
> but I failed to grasp the patch, as it seems to do a few too many
> things.  E.g. the whole wqe_shrink thing doesn't correspond to anything
> in the description.

when creating QP from mlx4_ib kernel verbs,  we decide  if we are
going to work using shrinked wqe or regular wqe (not something i
added).
shrinked wqe  means that WQE can be more than one WQE BB (basic block),
regular wqe - means that every WQE is exact one WQE BB,


> How about you split it into easily understanable chunks?

We had internal discussion about this issue.
we decided not to split the patch because it can break kernel
apps/ulps running over the  infiniband driver.
e.g once we removing vmap and not adjust the infiniband driver to work
with fragmented memory,
we can fail when trying to allocate contiguous memory using
dma_zalloc_coherent() while succeeding if trying to allocate
fragmented memory.

> Also now that you split the few places that actually split
> the allocation into chunks to be handled special I think the whole
> mlx4_buf abstraction should go away, as it just obsfucates
> how different the different use cases are.

we still need this mlx4_buf abstraction to store the info on whether
we are working with fragmented memory (can be in IB driver) or direct
memory.

> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
