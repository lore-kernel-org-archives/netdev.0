From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [RFD] workqueue: WQ_MEM_RECLAIM usage in network drivers
Date: Fri, 18 Mar 2016 17:24:05 -0400
Message-ID: <20160318212405.GA5192@fieldses.org>
References: <20160317164546.GT21104@mtj.duckdns.org>
 <20160317213216.731d1fcc@synchrony.poochiereds.net>
 <20160318204623.GM20028@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
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
Content-Disposition: inline
In-Reply-To: <20160318204623.GM20028-qYNAdHglDFBN0TnZuCh8vA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 18, 2016 at 04:46:23PM -0400, Tejun Heo wrote:
> Hello, Jeff.
> 
> On Thu, Mar 17, 2016 at 09:32:16PM -0400, Jeff Layton wrote:
> > > * Are network devices expected to be able to serve as a part of
> > >   storage stack which is depended upon for memory reclamation?
> > 
> > I think they should be. Cached NFS pages can consume a lot of memory,
> > and flushing them generally takes network device access.
> 
> But does that actually work?  It's pointless to add WQ_MEM_RECLAIM to
> workqueues unless all other things are also guaranteed to make forward
> progress regardless of memory pressure.

It's supposed to work.

Also note there was a bunch of work done to allow swap on NFS: see
a564b8f0 "nfs: enable swap on NFS".

> 
> > > * If so, are all the pieces in place for that to work for all (or at
> > >   least most) network devices?  If it's only for a subset of NICs, how
> > >   can one tell whether a given driver needs forward progress guarantee
> > >   or not?
> > > 
> > > * I assume that wireless drivers aren't and can't be used in this
> > >   fashion.  Is that a correction assumption?
> > > 
> > 
> > People do mount NFS over wireless interfaces. It's not terribly common
> > though, in my experience.
> 
> Ditto, I'm very skeptical that this actually works in practice and
> people expect and depend on it.  I don't follow wireless development
> closely but haven't heard anyone talking about reserving memory pools
> or people complaining about wireless being the cause of OOM.
> 
> So, I really want to avoid spraying WQ_MEM_RECLAIM if it doesn't serve
> actual purposes.  It's wasteful, sets bad precedences and confuses
> future readers.

I use NFS mounts over wifi at home.  I may just be odd.  I seem to
recall some bug reports about suspend vs. NFS--were those also on
laptops using NFS?

I wonder if home media centers might do writes over wifi to network
storage?

Googling for "nfs wifi" turns up lots of individuals doing this.

My first impulse is to say that it's probably not perfect but that we
shouldn't make it worse.

But, I don't claim to understand the WQ_MEM_RECLAIM-proliferation issue
you're seeing....

--b.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
