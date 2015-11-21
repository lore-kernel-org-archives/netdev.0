From: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH 9/9] netfilter: implement xt_cgroup cgroup2 path match
Date: Sat, 21 Nov 2015 17:56:06 +0100
Message-ID: <20151121165605.GC25336@breakpoint.cc>
References: <1448122441-9335-1-git-send-email-tj@kernel.org>
 <1448122441-9335-10-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org,
	daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, nhorman-2XuSBdqkA4SvXiR4WA35Jg@public.gmane.org,
	lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-team-b10kYP2dOMg@public.gmane.org, ninasc-b10kYP2dOMg@public.gmane.org,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Jan Engelhardt <jengelh-9+2X+4sQBs8@public.gmane.org>
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1448122441-9335-10-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> This patch implements xt_cgroup path match which matches cgroup2
> membership of the associated socket.  The match is recursive and
> invertible.
> 
> For rationales on introducing another cgroup based match, please refer
> to a preceding commit "sock, cgroup: add sock->sk_cgroup".
> 
> v3: Folded into xt_cgroup as a new revision interface as suggested by
>     Pablo.
> 
> v2: Included linux/limits.h from xt_cgroup2.h for PATH_MAX.  Added
>     explicit alignment to the priv field.  Both suggested by Jan.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
> Cc: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
> CC: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Cc: Jan Engelhardt <jengelh-9+2X+4sQBs8@public.gmane.org>
> Cc: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
> ---
>  include/uapi/linux/netfilter/xt_cgroup.h | 13 ++++++
>  net/netfilter/xt_cgroup.c                | 69 ++++++++++++++++++++++++++++++++
>  2 files changed, 82 insertions(+)
> 
> diff --git a/include/uapi/linux/netfilter/xt_cgroup.h b/include/uapi/linux/netfilter/xt_cgroup.h
> index 577c9e0..1e4b37b 100644
> --- a/include/uapi/linux/netfilter/xt_cgroup.h
> +++ b/include/uapi/linux/netfilter/xt_cgroup.h
> @@ -2,10 +2,23 @@
>  #define _UAPI_XT_CGROUP_H
>  
>  #include <linux/types.h>
> +#include <linux/limits.h>
>  
>  struct xt_cgroup_info_v0 {
>  	__u32 id;
>  	__u32 invert;
>  };
>  
> +struct xt_cgroup_info_v1 {
> +	__u8		has_path;
> +	__u8		has_classid;
> +	__u8		invert_path;
> +	__u8		invert_classid;
> +	char		path[PATH_MAX];
> +	__u32		classid;
> +
> +	/* kernel internal data */
> +	void		*priv __attribute__((aligned(8)));
> +};

Ahem.  Am I reading this right? This struct is > 4k in size?
If so -- Ugh.  Does sizeof(path) really have to be PATH_MAX?

Thanks!
