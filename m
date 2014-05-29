From: Amos Kong <akong@redhat.com>
Subject: Re: [PATCH net-next] bridge: fix the unbalanced promiscuous count
 when add_if failed
Date: Thu, 29 May 2014 11:51:31 +0800
Message-ID: <20140529035131.GA12648@z.redhat.com>
References: <53869842.4060202@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	bridge@lists.linux-foundation.org, netdev <netdev@vger.kernel.org>,
	vyasevic@redhat.com
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16216 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755453AbaE2Dvm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 May 2014 23:51:42 -0400
Content-Disposition: inline
In-Reply-To: <53869842.4060202@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 29, 2014 at 10:15:30AM +0800, Wang Weidong wrote:
> As commit 2796d0c648c94("bridge: Automatically manage port
> promiscuous mode."), make the add_if use dev_set_allmulti
> instead of dev_set_promiscuous, so when add_if failed, we
> should do dev_set_allmulti(dev, -1).
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> ---
>  net/bridge/br_if.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index 104a811..a08d2b8 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -528,7 +528,7 @@ err2:
>  	kobject_put(&p->kobj);
>  	p = NULL; /* kobject_put frees */
>  err1:
> -	dev_set_promiscuity(dev, -1);
> +	dev_set_allmulti(dev, -1);

Right fix.

Reviewed-by: Amos Kong <akong@redhat.com>

>  put_back:
>  	dev_put(dev);
>  	kfree(p);
> -- 
> 1.8.4
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
			Amos.
