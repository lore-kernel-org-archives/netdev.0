From: Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Date: Fri, 6 Nov 2015 17:46:57 +0100
Message-ID: <20151106164657.GL4390@dhcp22.suse.cz>
References: <20151027164227.GB7749@cmpxchg.org>
 <20151029152546.GG23598@dhcp22.suse.cz>
 <20151029161009.GA9160@cmpxchg.org>
 <20151104104239.GG29607@dhcp22.suse.cz>
 <20151104195037.GA6872@cmpxchg.org>
 <20151105144002.GB15111@dhcp22.suse.cz>
 <20151105205522.GA1067@cmpxchg.org>
 <20151105225200.GA5432@cmpxchg.org>
 <20151106105724.GG4390@dhcp22.suse.cz>
 <20151106161953.GA7813@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	vdavydov-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20151106161953.GA7813-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri 06-11-15 11:19:53, Johannes Weiner wrote:
> On Fri, Nov 06, 2015 at 11:57:24AM +0100, Michal Hocko wrote:
> > On Thu 05-11-15 17:52:00, Johannes Weiner wrote:
> > > On Thu, Nov 05, 2015 at 03:55:22PM -0500, Johannes Weiner wrote:
> > > > On Thu, Nov 05, 2015 at 03:40:02PM +0100, Michal Hocko wrote:
> > > > > This would be true if they moved on to the new cgroup API intentionally.
> > > > > The reality is more complicated though. AFAIK sysmted is waiting for
> > > > > cgroup2 already and privileged services enable all available resource
> > > > > controllers by default as I've learned just recently.
> > > > 
> > > > Have you filed a report with them? I don't think they should turn them
> > > > on unless users explicitely configure resource control for the unit.
> > > 
> > > Okay, verified with systemd people that they're not planning on
> > > enabling resource control per default.
> > > 
> > > Inflammatory half-truths, man. This is not constructive.
> > 
> > What about Delegate=yes feature then? We have just been burnt by this
> > quite heavily. AFAIU nspawn@.service and nspawn@.service have this
> > enabled by default
> > http://lists.freedesktop.org/archives/systemd-commits/2014-November/007400.html
> 
> That's when you launch a *container* and want it to be able to use
> nested resource control.

Ups. copy&paste error here. The second one was user@.service. So it is
not only about containers AFAIU but all user defined sessions.

> We're talking about actual container users here. It's not turning on
> resource control for all "privileged services", which is what we were
> worried about here. Can you at least admit that when you yourself link
> to the refuting evidence?

My bad, that was misundestanding of the changelog.

> And if you've been "burnt quite heavily" by this, where is your bug
> report to stop other users from getting "burnt quite heavily" as well?

The bug report is still internal because it is tracking an unrelased
product. We have ended up reverting Delegate feature. Our systemd
developers are supposed to bring this up with the upstream.

The basic problem was that the Delegate feature has been backported to
our systemd package without further consideration and that has
invalidated a lot of performance testing because some resource
controllers have measurable effects on those benchmarks.

> All I read here is vague inflammatory language to spread FUD.

I was merely pointing out that memory controller might be enabled without
_user_ actually even noticing because the controller wasn't enabled
explicitly. I haven't blamed anybody for that.

> You might think sending these emails is helpful, but it really
> isn't. Not only is it not contributing code, insights, or solutions,
> you're now actively sabotaging someone else's effort to build something.

Come on! Are you even serious?

-- 
Michal Hocko
SUSE Labs
