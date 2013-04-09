From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] can: gw: use kmem_cache_free() instead of kfree()
Date: Tue, 09 Apr 2013 08:48:08 +0200
Message-ID: <5163B9A8.2030306@hartkopp.net>
References: <CAPgLHd9eAfwJMJ9P5RqOKNP5kq87y61V7CTw2J--Ld8uHT0RrQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: yongjun_wei@trendmicro.com.cn, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>, davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <CAPgLHd9eAfwJMJ9P5RqOKNP5kq87y61V7CTw2J--Ld8uHT0RrQ@mail.gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09.04.2013 08:16, Wei Yongjun wrote:

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> memory allocated by kmem_cache_alloc() should be freed using
> kmem_cache_free(), not kfree().
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>


Oh yes, that's right ...

Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>

Is also a stable candidate for Linux 3.2+ (can-gw emerged in 3.2)

Thanks for catching this!

Best regards,
Oliver

> ---
>  net/can/gw.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/can/gw.c b/net/can/gw.c
> index 2d117dc..117814a 100644
> --- a/net/can/gw.c
> +++ b/net/can/gw.c
> @@ -466,7 +466,7 @@ static int cgw_notifier(struct notifier_block *nb,
>  			if (gwj->src.dev == dev || gwj->dst.dev == dev) {
>  				hlist_del(&gwj->list);
>  				cgw_unregister_filter(gwj);
> -				kfree(gwj);
> +				kmem_cache_free(cgw_cache, gwj);
>  			}
>  		}
>  	}
> @@ -864,7 +864,7 @@ static void cgw_remove_all_jobs(void)
>  	hlist_for_each_entry_safe(gwj, nx, &cgw_list, list) {
>  		hlist_del(&gwj->list);
>  		cgw_unregister_filter(gwj);
> -		kfree(gwj);
> +		kmem_cache_free(cgw_cache, gwj);
>  	}
>  }
>  
> @@ -920,7 +920,7 @@ static int cgw_remove_job(struct sk_buff *skb,  struct nlmsghdr *nlh, void *arg)
>  
>  		hlist_del(&gwj->list);
>  		cgw_unregister_filter(gwj);
> -		kfree(gwj);
> +		kmem_cache_free(cgw_cache, gwj);
>  		err = 0;
>  		break;
>  	}
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


