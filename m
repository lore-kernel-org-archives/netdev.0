From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH -next] vxlan: using kfree_rcu() to simplify the code
Date: Fri, 16 Aug 2013 16:45:44 -0700
Message-ID: <20130816164544.628ae1df@nehalam.linuxnetplumber.net>
References: <CAPgLHd8gtuhjrPP-t0dHGj_BDY5WqqX-QQbHpNK+0gPpuSN9LQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, pshelar@nicira.com,
	mike.rapoport@ravellosystems.com, amwang@redhat.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:57309 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239Ab3HQAON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 20:14:13 -0400
Received: by mail-pa0-f41.google.com with SMTP id bj1so2466462pad.28
        for <netdev@vger.kernel.org>; Fri, 16 Aug 2013 17:14:13 -0700 (PDT)
In-Reply-To: <CAPgLHd8gtuhjrPP-t0dHGj_BDY5WqqX-QQbHpNK+0gPpuSN9LQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 17 Aug 2013 07:32:09 +0800
Wei Yongjun <weiyj.lk@gmail.com> wrote:

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> The callback function of call_rcu() just calls a kfree(), so we
> can use kfree_rcu() instead of call_rcu() + callback function.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  drivers/net/vxlan.c | 8 +-------
>  1 file changed, 1 insertion(+), 7 deletions(-)
> 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 227b54a..d6fc046 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -498,12 +498,6 @@ static int vxlan_fdb_create(struct vxlan_dev *vxlan,
>  	return 0;
>  }
>  
> -static void vxlan_fdb_free_rdst(struct rcu_head *head)
> -{
> -	struct vxlan_rdst *rd = container_of(head, struct vxlan_rdst, rcu);
> -	kfree(rd);
> -}
> -
>  static void vxlan_fdb_free(struct rcu_head *head)
>  {
>  	struct vxlan_fdb *f = container_of(head, struct vxlan_fdb, rcu);
> @@ -643,7 +637,7 @@ static int vxlan_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
>  	 */
>  	if (rd && !list_is_singular(&f->remotes)) {
>  		list_del_rcu(&rd->list);
> -		call_rcu(&rd->rcu, vxlan_fdb_free_rdst);
> +		kfree_rcu(rd, rcu);
>  		goto out;
>  	}
>  
> 

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
