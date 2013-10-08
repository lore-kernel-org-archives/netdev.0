From: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH 2/2] cgroup: cls: remove unnecessary task_cls_classid
Date: Tue, 8 Oct 2013 09:17:48 -0400
Message-ID: <20131008131748.GB13089@hmsreliant.think-freely.org>
References: <1381201520-25938-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1381201520-25938-2-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1381201520-25938-2-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 08, 2013 at 11:05:20AM +0800, Gao feng wrote:
> We can get classid through cgroup_subsys_state,
> this is directviewing and effective.
> 
> Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  net/sched/cls_cgroup.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
> index 867b4a3..16006c9 100644
> --- a/net/sched/cls_cgroup.c
> +++ b/net/sched/cls_cgroup.c
> @@ -72,11 +72,11 @@ static void cgrp_attach(struct cgroup_subsys_state *css,
>  			struct cgroup_taskset *tset)
>  {
>  	struct task_struct *p;
> -	void *v;
> +	struct cgroup_cls_state *cs = css_cls_state(css);
> +	void *v = (void *)(unsigned long)cs->classid;
>  
>  	cgroup_taskset_for_each(p, css, tset) {
>  		task_lock(p);
> -		v = (void *)(unsigned long)task_cls_classid(p);
>  		iterate_fd(p->files, 0, update_classid, v);
>  		task_unlock(p);
>  	}
> -- 
> 1.8.3.1
> 
> 

Acked-by: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
