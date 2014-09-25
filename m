From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [Patch net-next 1/2] net_sched: fix errno in tcindex_set_parms()
Date: Thu, 25 Sep 2014 14:07:54 -0700
Message-ID: <5424842A.60802@intel.com>
References: <1411671965-18887-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, John Fastabend <john.fastabend@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:50504 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751650AbaIYVIP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2014 17:08:15 -0400
In-Reply-To: <1411671965-18887-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/25/2014 12:06 PM, Cong Wang wrote:
> When kmemdup() fails, we should return -ENOMEM.
> 
> Cc: John Fastabend <john.fastabend@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---

Acked-by: John Fastabend <john.r.fastabend@intel.com>

Thanks Cong.

>  net/sched/cls_tcindex.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
> index 5054fae..9d78fd7 100644
> --- a/net/sched/cls_tcindex.c
> +++ b/net/sched/cls_tcindex.c
> @@ -237,15 +237,14 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
>  	if (err < 0)
>  		return err;
>  
> +	err = -ENOMEM;
>  	/* tcindex_data attributes must look atomic to classifier/lookup so
>  	 * allocate new tcindex data and RCU assign it onto root. Keeping
>  	 * perfect hash and hash pointers from old data.
>  	 */
>  	cp = kzalloc(sizeof(*cp), GFP_KERNEL);
> -	if (!cp) {
> -		err = -ENOMEM;
> +	if (!cp)
>  		goto errout;
> -	}
>  
>  	cp->mask = p->mask;
>  	cp->shift = p->shift;
> 
