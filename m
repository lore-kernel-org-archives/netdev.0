From: Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Date: Fri, 23 Oct 2015 15:19:56 +0200
Message-ID: <20151023131956.GA15375@dhcp22.suse.cz>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <1445487696-21545-6-git-send-email-hannes@cmpxchg.org>
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
In-Reply-To: <1445487696-21545-6-git-send-email-hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu 22-10-15 00:21:33, Johannes Weiner wrote:
> Socket memory can be a significant share of overall memory consumed by
> common workloads. In order to provide reasonable resource isolation
> out-of-the-box in the unified hierarchy, this type of memory needs to
> be accounted and tracked per default in the memory controller.

What about users who do not want to pay an additional overhead for the
accounting? How can they disable it?

> Signed-off-by: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>

[...]

> @@ -5453,10 +5470,9 @@ void mem_cgroup_replace_page(struct page *oldpage, struct page *newpage)
>  	commit_charge(newpage, memcg, true);
>  }
>  
> -/* Writing them here to avoid exposing memcg's inner layout */
> -#if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
> +#ifdef CONFIG_INET
>  
> -DEFINE_STATIC_KEY_FALSE(mem_cgroup_sockets);
> +DEFINE_STATIC_KEY_TRUE(mem_cgroup_sockets);

AFAIU this means that the jump label is enabled by default. Is this
intended when you enable it explicitly where needed?

>  
>  void sock_update_memcg(struct sock *sk)
>  {
-- 
Michal Hocko
SUSE Labs
