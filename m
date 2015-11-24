From: Vladimir Davydov <vdavydov-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
Subject: Re: [PATCH 09/14] net: tcp_memcontrol: simplify linkage between
 socket and page counter
Date: Tue, 24 Nov 2015 16:43:27 +0300
Message-ID: <20151124134327.GH29014@esperanza>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-10-git-send-email-hannes@cmpxchg.org>
 <20151120124216.GD31308@esperanza>
 <20151120185648.GC5623@cmpxchg.org>
 <20151123093646.GA29014@esperanza>
 <20151123182037.GE13000@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>,
	<cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<kernel-team-b10kYP2dOMg@public.gmane.org>
To: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20151123182037.GE13000-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 23, 2015 at 01:20:37PM -0500, Johannes Weiner wrote:
> On Mon, Nov 23, 2015 at 12:36:46PM +0300, Vladimir Davydov wrote:
> > On Fri, Nov 20, 2015 at 01:56:48PM -0500, Johannes Weiner wrote:
> > > I actually had all this at first, but then wondered if it makes more
> > > sense to keep the legacy code in isolation. Don't you think it would
> > > be easier to keep track of what's v1 and what's v2 if we keep the
> > > legacy stuff physically separate as much as possible? In particular I
> > > found that 'tcp_mem.' marker really useful while working on the code.
> > > 
> > > In the same vein, tcp_memcontrol.c doesn't really hurt anybody and I'd
> > > expect it to remain mostly unopened and unchanged in the future. But
> > > if we merge it into memcontrol.c, that code will likely be in the way
> > > and we'd have to make it explicit somehow that this is not actually
> > > part of the new memory controller anymore.
> > > 
> > > What do you think?
> > 
> > There isn't much code left in tcp_memcontrol.c, and not all of it is
> > legacy. We still want to call tcp_init_cgroup and tcp_destroy_cgroup
> > from memcontrol.c - in fact, it's the only call site, so I think we'd
> > better keep these functions there. Apart from init/destroy, there is
> > only stuff for handling legacy files, which is relatively small and
> > isolated. We can just put it along with memsw and kmem legacy files in
> > the end of memcontrol.c adding a comment that it's legacy. Personally,
> > I'd find the code easier to follow then, because currently the logic
> > behind the ACTIVE flag as well as memcg->tcp_mem init/use/destroy turns
> > out to be scattered between two files in different subsystems for no
> > apparent reason now, as it does not need tcp_prot any more. Besides,
> > this would allow us to accurately reuse the ACTIVE flag in init/destroy
> > for inc/dec static branch and probably in sock_update_memcg instead of
> > sprinkling cgroup_subsys_on_dfl all over the place, which would make the
> > code a bit cleaner IMO (in fact, that's why I proposed to drop ACTIVATED
> > bit and replace cg_proto->flags with ->active bool).
> 
> As far as I can see, all of tcp_memcontrol.c is legacy, including the
> init and destroy functions. We only call them to set up the legacy
> tcp_mem state and do legacy jump-label maintenance. Delete it all and
> the unified hierarchy controller would still work. So I don't really
> see the benefits of consolidating it, and more risk of convoluting.
> 
> That being said, if you care strongly about it and see opportunities
> to cut down code and make things more readable, please feel free to
> turn the flags -> bool patch into a followup series and I'll be happy
> to review it.

OK, I'll look into that.

Regarding this patch, I don't have any questions left,

Reviewed-by: Vladimir Davydov <vdavydov-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>

Thanks,
Vladimir
