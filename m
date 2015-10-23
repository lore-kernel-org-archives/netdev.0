From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/8] mm: memcontrol: export root_mem_cgroup
Date: Fri, 23 Oct 2015 13:32:38 +0200
Message-ID: <20151023113237.GK2410@dhcp22.suse.cz>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <1445487696-21545-3-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vladimir Davydov <vdavydov@virtuozzo.com>,
	Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org,
	linux-mm@kvack.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Weiner <hannes@cmpxchg.org>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <1445487696-21545-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu 22-10-15 00:21:30, Johannes Weiner wrote:
> A later patch will need this symbol in files other than memcontrol.c,
> so export it now and replace mem_cgroup_root_css at the same time.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/memcontrol.h | 3 ++-
>  mm/backing-dev.c           | 2 +-
>  mm/memcontrol.c            | 5 ++---
>  3 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 805da1f..19ff87b 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -275,7 +275,8 @@ struct mem_cgroup {
>  	struct mem_cgroup_per_node *nodeinfo[0];
>  	/* WARNING: nodeinfo must be the last member here */
>  };
> -extern struct cgroup_subsys_state *mem_cgroup_root_css;
> +
> +extern struct mem_cgroup *root_mem_cgroup;
>  
>  /**
>   * mem_cgroup_events - count memory events against a cgroup
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index 095b23b..73ab967 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -702,7 +702,7 @@ static int cgwb_bdi_init(struct backing_dev_info *bdi)
>  
>  	ret = wb_init(&bdi->wb, bdi, 1, GFP_KERNEL);
>  	if (!ret) {
> -		bdi->wb.memcg_css = mem_cgroup_root_css;
> +		bdi->wb.memcg_css = &root_mem_cgroup->css;
>  		bdi->wb.blkcg_css = blkcg_root_css;
>  	}
>  	return ret;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index a8ccdbc..e54f434 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -76,9 +76,9 @@
>  struct cgroup_subsys memory_cgrp_subsys __read_mostly;
>  EXPORT_SYMBOL(memory_cgrp_subsys);
>  
> +struct mem_cgroup *root_mem_cgroup __read_mostly;
> +
>  #define MEM_CGROUP_RECLAIM_RETRIES	5
> -static struct mem_cgroup *root_mem_cgroup __read_mostly;
> -struct cgroup_subsys_state *mem_cgroup_root_css __read_mostly;
>  
>  /* Whether the swap controller is active */
>  #ifdef CONFIG_MEMCG_SWAP
> @@ -4213,7 +4213,6 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
>  	/* root ? */
>  	if (parent_css == NULL) {
>  		root_mem_cgroup = memcg;
> -		mem_cgroup_root_css = &memcg->css;
>  		page_counter_init(&memcg->memory, NULL);
>  		memcg->high = PAGE_COUNTER_MAX;
>  		memcg->soft_limit = PAGE_COUNTER_MAX;
> -- 
> 2.6.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
