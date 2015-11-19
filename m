From: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH 13/14] mm: memcontrol: account socket memory in unified
 hierarchy memory controller
Date: Thu, 19 Nov 2015 11:52:25 -0500
Message-ID: <20151119165225.GA1949@cmpxchg.org>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-14-git-send-email-hannes@cmpxchg.org>
 <20151116155923.GH14116@dhcp22.suse.cz>
 <20151116181810.GB32544@cmpxchg.org>
 <20151118162256.GK19145@dhcp22.suse.cz>
 <20151118214822.GA1365@cmpxchg.org>
 <20151119135023.GH8494@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Vladimir Davydov <vdavydov-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-team-b10kYP2dOMg@public.gmane.org
To: Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20151119135023.GH8494-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 19, 2015 at 02:50:24PM +0100, Michal Hocko wrote:
> On Wed 18-11-15 16:48:22, Johannes Weiner wrote:
> [...]
> > So I ran perf record -g -a netperf -t TCP_STREAM multiple times inside
> > a memory-controlled cgroup, but mostly mem_cgroup_charge_skmem() does
> > not show up in the profile at all. Once it was there with 0.00%.
> 
> OK, this sounds very good! This means that most workloads which are not
> focusing solely on the network traffic shouldn't even notice. I can
> imagine that workloads with high throughput demands would notice but I
> would also expect them to disable the feature.

Even for high throughput, the cost of this is a function of number of
packets sent. E.g. the 13MB/s over wifi showed the socket charging at
0.02%. But I just did an http transfer over 1Gbit ethernet at around
110MB/s, ten times the bandwidth, and the charge function is at 0.00%.

> Could you add this information to the changelog, please?

Sure, but which information exactly?

If we had found a realistic networking workload that is expected to be
containerized and had shown that load to be negatively affected by the
charging calls, that would have been worth bringing up in conjunction
with the boot-time flag. But what do we have to say here? People care
about cost. It seems unnecessary to point out the absence of it.
