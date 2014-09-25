From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [Patch net-next 2/2] net_sched: fix another regression in cls_tcindex
Date: Thu, 25 Sep 2014 14:18:15 -0700
Message-ID: <54248697.2010202@intel.com>
References: <1411671965-18887-1-git-send-email-xiyou.wangcong@gmail.com> <1411671965-18887-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, John Fastabend <john.fastabend@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:39086 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751981AbaIYVSP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2014 17:18:15 -0400
In-Reply-To: <1411671965-18887-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/25/2014 12:06 PM, Cong Wang wrote:
> Clearly the following change is not expected:
> 
> 	-       if (!cp.perfect && !cp.h)
> 	-               cp.alloc_hash = cp.hash;
> 	+       if (!cp->perfect && cp->h)
> 	+               cp->alloc_hash = cp->hash;
> 
> Fixes: commit 331b72922c5f58d48fd ("net: sched: RCU cls_tcindex")
> Cc: John Fastabend <john.fastabend@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/sched/cls_tcindex.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
> index 9d78fd7..a18eb1b 100644
> --- a/net/sched/cls_tcindex.c
> +++ b/net/sched/cls_tcindex.c
> @@ -303,7 +303,7 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
>  			cp->hash = DEFAULT_HASH_SIZE;
>  	}
>  
> -	if (!cp->perfect && cp->h)
> +	if (!cp->perfect && !cp->h)
>  		cp->alloc_hash = cp->hash;
>  
>  	/* Note: this could be as restrictive as if (handle & ~(mask >> shift))
> 

Dang thanks. I added a test to my scripts that doesn't set the
hash explicitly with TCA_TCINDEX_HASH. It looks like changes to
the filter after the initial setup could fail without this fix.

Acked-by: John Fastabend <john.r.fastabend@intel.com>
