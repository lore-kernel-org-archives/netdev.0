From: Vladimir Davydov <vdavydov-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
Subject: Re: [PATCH 7/8] mm: vmscan: report vmpressure at the level of
 reclaim activity
Date: Thu, 22 Oct 2015 21:48:53 +0300
Message-ID: <20151022184852.GP18351@esperanza>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <1445487696-21545-8-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>,
	<cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1445487696-21545-8-git-send-email-hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 22, 2015 at 12:21:35AM -0400, Johannes Weiner wrote:
...
> @@ -2437,6 +2439,10 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>  				}
>  			}
>  
> +			vmpressure(sc->gfp_mask, memcg,
> +				   sc->nr_scanned - scanned,
> +				   sc->nr_reclaimed - reclaimed);
> +
>  			/*
>  			 * Direct reclaim and kswapd have to scan all memory
>  			 * cgroups to fulfill the overall scan target for the
> @@ -2454,10 +2460,6 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>  			}
>  		} while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
>  
> -		vmpressure(sc->gfp_mask, sc->target_mem_cgroup,
> -			   sc->nr_scanned - nr_scanned,
> -			   sc->nr_reclaimed - nr_reclaimed);
> -
>  		if (sc->nr_reclaimed - nr_reclaimed)
>  			reclaimable = true;
>  

I may be mistaken, but AFAIU this patch subtly changes the behavior of
vmpressure visible from the userspace: w/o this patch a userspace
process will only receive a notification for a memory cgroup only if
*this* memory cgroup calls reclaimer; with this patch userspace
notification will be issued even if reclaimer is invoked by any cgroup
up the hierarchy.

Thanks,
Vladimir
