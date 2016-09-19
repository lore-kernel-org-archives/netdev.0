From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 1/3] mm: memcontrol: make per-cpu charge cache IRQ-safe
 for socket accounting
Date: Mon, 19 Sep 2016 18:35:45 +0300
Message-ID: <20160919153545.GF1989@esperanza>
References: <20160914194846.11153-1-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org,
	cgroups@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com
To: Johannes Weiner <hannes@cmpxchg.org>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20160914194846.11153-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 03:48:44PM -0400, Johannes Weiner wrote:
> From: Johannes Weiner <jweiner@fb.com>
> 
> During cgroup2 rollout into production, we started encountering css
> refcount underflows and css access crashes in the memory controller.
> Splitting the heavily shared css reference counter into logical users
> narrowed the imbalance down to the cgroup2 socket memory accounting.
> 
> The problem turns out to be the per-cpu charge cache. Cgroup1 had a
> separate socket counter, but the new cgroup2 socket accounting goes
> through the common charge path that uses a shared per-cpu cache for
> all memory that is being tracked. Those caches are safe against
> scheduling preemption, but not against interrupts - such as the newly
> added packet receive path. When cache draining is interrupted by
> network RX taking pages out of the cache, the resuming drain operation
> will put references of in-use pages, thus causing the imbalance.
> 
> Disable IRQs during all per-cpu charge cache operations.
> 
> Fixes: f7e1cb6ec51b ("mm: memcontrol: account socket memory in unified hierarchy memory controller")
> Cc: <stable@vger.kernel.org> # 4.5+
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
