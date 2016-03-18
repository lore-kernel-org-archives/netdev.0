From: Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>
Subject: Re: [RFD] workqueue: WQ_MEM_RECLAIM usage in network drivers
Date: Thu, 17 Mar 2016 21:32:16 -0400
Message-ID: <20160317213216.731d1fcc@synchrony.poochiereds.net>
References: <20160317164546.GT21104@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Amitoj Kaur Chawla <amitoj1606-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	kernel-team-b10kYP2dOMg@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Eva Rachel Retuya <eraretuya-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Bhaktipriya Shridhar <bhaktipriya96-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160317164546.GT21104-qYNAdHglDFBN0TnZuCh8vA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 17 Mar 2016 09:45:46 -0700
Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:

> Hello,
> 
> Years ago, workqueue got reimplemented to use common worker pools
> across different workqueues and a new set of more expressive workqueue
> creation APIs, alloc_*workqueue() were introduced.  The old
> create_*workqueue() became simple wrappers around alloc_*workqueue()
> with the most conservative parameters.  The plan has always been to
> examine each usage and convert to the new interface with parameters
> actually required for the use case.
> 
> One important flag to decide upon is WQ_MEM_RECLAIM, which declares
> that the workqueue may be depended upon during memory reclaim and thus
> must be able to make forward-progress even when further memory can't
> be allocated without reclaiming some.  Of the network drivers which
> already use alloc_*workqueue() interface, some specify this flag and
> I'm wondering what the guidelines should be here.
> 
> * Are network devices expected to be able to serve as a part of
>   storage stack which is depended upon for memory reclamation?
> 

I think they should be. Cached NFS pages can consume a lot of memory,
and flushing them generally takes network device access.

> * If so, are all the pieces in place for that to work for all (or at
>   least most) network devices?  If it's only for a subset of NICs, how
>   can one tell whether a given driver needs forward progress guarantee
>   or not?
> 
> * I assume that wireless drivers aren't and can't be used in this
>   fashion.  Is that a correction assumption?
> 

People do mount NFS over wireless interfaces. It's not terribly common
though, in my experience.

-- 
Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
