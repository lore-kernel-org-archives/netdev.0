From: Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 7/8] mm: vmscan: report vmpressure at the level of
 reclaim activity
Date: Fri, 23 Oct 2015 15:49:57 +0200
Message-ID: <20151023134957.GC15375@dhcp22.suse.cz>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <1445487696-21545-8-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Vladimir Davydov <vdavydov-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1445487696-21545-8-git-send-email-hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu 22-10-15 00:21:35, Johannes Weiner wrote:
> The vmpressure metric is based on reclaim efficiency, which in turn is
> an attribute of the LRU. However, vmpressure events are currently
> reported at the source of pressure rather than at the reclaim level.
> 
> Switch the reporting to the reclaim level to allow finer-grained
> analysis of which memcg is having trouble reclaiming its pages.

I can see how this can be useful.
 
> As far as memory.pressure_level interface semantics go, events are
> escalated up the hierarchy until a listener is found, so this won't
> affect existing users that listen at higher levels.

This is true but the parent will not see cumulative events anymore.
One memcg might be fighting and barely reclaim anything so it would
report high pressure while other would be doing just fine. The parent
will just see conflicting events in a short time period and cannot match
them the source memcg. This sounds really confusing. Even more confusing
than the current semantic which allows the same behavior under certain
configurations.

I dunno, have to think about it some more. Maybe we need to rethink the
way how the pressure is signaled. If we want the breakdown of the
particular memcgs then we should be able to identify them for this to be
useful.

[...]
-- 
Michal Hocko
SUSE Labs
