From: Mel Gorman <mgorman-3eNAlZScCAx27rWaFMvyedHuzzzSOjJt@public.gmane.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Date: Thu, 12 Nov 2015 18:36:20 +0000
Message-ID: <20151112183620.GC14880@techsingularity.net>
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
Content-Type: text/plain; charset=iso-8859-15
Cc: Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	vdavydov-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20151106161953.GA7813-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 06, 2015 at 11:19:53AM -0500, Johannes Weiner wrote:
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
> 
> We're talking about actual container users here. It's not turning on
> resource control for all "privileged services", which is what we were
> worried about here. Can you at least admit that when you yourself link
> to the refuting evidence?
> 
> And if you've been "burnt quite heavily" by this, where is your bug
> report to stop other users from getting "burnt quite heavily" as well?
> 

I didn't read this thread in detail but the lack of public information on
problems with cgroup controllers is partially my fault so I'd like to correct
that.

https://bugzilla.suse.com/show_bug.cgi?id=954765

This bug documents some of the impact that was incurred due to ssh
sessions being resource controlled by default. It talks primarily about
pipetest being impacted by cpu,cpuacct. It is also found in the recent
past that dbench4 was previously impacted because the blkio controller
was enabled. That bug is not public but basically dbench4 regressed 80% as
the journal thread was in a different cgroup than dbench4. dbench4 would
stall for 8ms in case more IO was issued before the journal thread could
issue any IO. The opensuse bug 954765 bug is not affected by blkio because
it's disabled by a distribution-specific patch. Mike Galbraith adds some
additional information on why activating the cpu controller can have an
impact on semantics even if the overhead was zero.

It may be the case that it's an oversight by the systemd developers and the
intent was only to affect containers. My experience was that everything
was affected. It also may be the case that this is an opensuse-specific
problem due to how the maintainers packaged systemd. I don't actually
know and hopefully the bug will be able to determine if upstream is really
affected or not.

There is also a link to this bug on the upstream project so there is some
chance they are aware https://github.com/systemd/systemd/issues/1715

Bottom line, there is legimate confusion over whether cgroup controllers
are going to be enabled by default or not in the future. If they are
enabled by default, there is a non-zero cost to that and a change in
semantics that people may or may not be surprised by.

-- 
Mel Gorman
SUSE Labs
