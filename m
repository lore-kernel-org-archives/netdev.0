From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 02/14] mm: vmscan: simplify memcg vs. global shrinker
 invocation
Date: Sat, 14 Nov 2015 10:06:04 -0500
Message-ID: <20151114150604.GA28175@cmpxchg.org>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-3-git-send-email-hannes@cmpxchg.org>
 <20151114123650.GH31308@esperanza>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>,
	netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20151114123650.GH31308@esperanza>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 14, 2015 at 03:36:50PM +0300, Vladimir Davydov wrote:
> On Thu, Nov 12, 2015 at 06:41:21PM -0500, Johannes Weiner wrote:
> > @@ -2432,20 +2447,6 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
> >  			}
> >  		} while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
> >  
> > -		/*
> > -		 * Shrink the slab caches in the same proportion that
> > -		 * the eligible LRU pages were scanned.
> > -		 */
> > -		if (global_reclaim(sc) && is_classzone)
> > -			shrink_slab(sc->gfp_mask, zone_to_nid(zone), NULL,
> > -				    sc->nr_scanned - nr_scanned,
> > -				    zone_lru_pages);
> > -
> > -		if (reclaim_state) {
> > -			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
> > -			reclaim_state->reclaimed_slab = 0;
> > -		}
> > -
> 
> AFAICS this patch deadly breaks memcg-unaware shrinkers vs LRU balance:
> currently we scan (*total* LRU scanned / *total* LRU pages) of all such
> objects; with this patch we'd use the numbers from the root cgroup
> instead. If most processes reside in memory cgroups, the root cgroup
> will have only a few LRU pages and hence the pressure exerted upon such
> objects will be unfairly severe.

You're absolutely right, good catch.

Please disregard this patch. It's not necessary for this series after
v2, I just kept it because I thought it's a nice simplification that's
possible after making root_mem_cgroup public.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
