From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 13/14] mm: memcontrol: account socket memory in unified
 hierarchy memory controller
Date: Wed, 18 Nov 2015 17:22:56 +0100
Message-ID: <20151118162256.GK19145@dhcp22.suse.cz>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-14-git-send-email-hannes@cmpxchg.org>
 <20151116155923.GH14116@dhcp22.suse.cz>
 <20151116181810.GB32544@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vladimir Davydov <vdavydov@virtuozzo.com>,
	Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org,
	linux-mm@kvack.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com
To: Johannes Weiner <hannes@cmpxchg.org>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20151116181810.GB32544@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon 16-11-15 13:18:10, Johannes Weiner wrote:
> On Mon, Nov 16, 2015 at 04:59:25PM +0100, Michal Hocko wrote:
> > On Thu 12-11-15 18:41:32, Johannes Weiner wrote:
> > > Socket memory can be a significant share of overall memory consumed by
> > > common workloads. In order to provide reasonable resource isolation in
> > > the unified hierarchy, this type of memory needs to be included in the
> > > tracking/accounting of a cgroup under active memory resource control.
> > > 
> > > Overhead is only incurred when a non-root control group is created AND
> > > the memory controller is instructed to track and account the memory
> > > footprint of that group. cgroup.memory=nosocket can be specified on
> > > the boot commandline to override any runtime configuration and
> > > forcibly exclude socket memory from active memory resource control.
> > 
> > Do you have any numbers about the overhead?
> 
> Hm? Performance numbers make sense when you have a specific scenario
> and a theory on how to optimize the implementation for it.

The fact that there was a strong push to use static branches to put
the code out of line to reduce an overhead before the feature was
merged shows that people are sensitive to network performance and that
significant effort has been spent to eliminate it. My point was that you
are enabling the feature for all memcg users in unified hierarchy now
without having a performance impact overview which users can use
to judge whether to keep it enabled or disable before they start seeing
regressions or to make regression easier to track once it happens.

> What load would you test and what would be the baseline to compare it
> to?

It seems like netperf with a stream load running in a memcg with no
limits vs. in root memcg (and no other cgroups) should give at least a
hint about the runtime overhead, no?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
