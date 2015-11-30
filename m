From: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH 09/13] mm: memcontrol: generalize the socket accounting
 jump label
Date: Mon, 30 Nov 2015 17:46:34 -0500
Message-ID: <20151130224634.GA19849@cmpxchg.org>
References: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
 <1448401925-22501-10-git-send-email-hannes@cmpxchg.org>
 <565CBAC2.3080804@akamai.com>
 <20151130215007.GA31903@cmpxchg.org>
 <565CCDA1.905@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Vladimir Davydov <vdavydov-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>,
	Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-team-b10kYP2dOMg@public.gmane.org,
	"peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org" <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
To: Jason Baron <jbaron-JqFfY2XvxFXQT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <565CCDA1.905-JqFfY2XvxFXQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 30, 2015 at 05:28:49PM -0500, Jason Baron wrote:
> On 11/30/2015 04:50 PM, Johannes Weiner wrote:
> > On Mon, Nov 30, 2015 at 04:08:18PM -0500, Jason Baron wrote:
> >> We're trying to move to the updated API, so this should be:
> >> static_branch_unlikely(&memcg_sockets_enabled_key)
> >>
> >> see: include/linux/jump_label.h for details.
> > 
> > Good point. There is another struct static_key in there as well. How
> > about the following on top of this series?
> > 
> 
> Looks fine - you may be able to make use of
> 'static_branch_enable()/disable()' instead of the inc()/dec() to simply
> set the branch direction, if you think its more readable. Although I
> didn't look to see if it would be racy here.

Thanks!

We actually need the reference counting semantics for both these keys.
It counts the number of active cgroups in existence that require the
code behind those static branches.
