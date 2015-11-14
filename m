From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 03/14] net: tcp_memcontrol: properly detect ancestor
 socket pressure
Date: Sat, 14 Nov 2015 10:15:18 -0500
Message-ID: <20151114151518.GB28175@cmpxchg.org>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-4-git-send-email-hannes@cmpxchg.org>
 <20151114124552.GI31308@esperanza>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>,
	netdev@vger.kernel.org, linux-mm@kvack.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151114124552.GI31308@esperanza>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 14, 2015 at 03:45:52PM +0300, Vladimir Davydov wrote:
> On Thu, Nov 12, 2015 at 06:41:22PM -0500, Johannes Weiner wrote:
> > When charging socket memory, the code currently checks only the local
> > page counter for excess to determine whether the memcg is under socket
> > pressure. But even if the local counter is fine, one of the ancestors
> > could have breached its limit, which should also force this child to
> > enter socket pressure. This currently doesn't happen.
> > 
> > Fix this by using page_counter_try_charge() first. If that fails, it
> > means that either the local counter or one of the ancestors are in
> > excess of their limit, and the child should enter socket pressure.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Thanks Vladimir!

> For the record: it was broken by commit 3e32cb2e0a12 ("mm: memcontrol:
> lockless page counters").

I didn't realize that.

Fixes: 3e32cb2e0a12 ("mm: memcontrol: lockless page counters")
