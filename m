From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net] macvtap: fix tx_dropped counting error
Date: Mon, 25 Nov 2013 13:50:05 +0200
Message-ID: <20131125115005.GA32173@redhat.com>
References: <1385371144-11071-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Vlad Yasevich <vyasevic@redhat.com>,
	Eric Dumazet <edumazet@google.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5234 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750822Ab3KYLqw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Nov 2013 06:46:52 -0500
Content-Disposition: inline
In-Reply-To: <1385371144-11071-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 25, 2013 at 05:19:04PM +0800, Jason Wang wrote:
> After commit 8ffab51b3dfc54876f145f15b351c41f3f703195
> (macvlan: lockless tx path), tx stat counter were converted to percpu stat
> structure. So we need use to this also for tx_dropped in macvtap. Otherwise, the
> management won't notice the dropping packet in macvtap tx path.
> 
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Vlad Yasevich <vyasevic@redhat.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>


Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/net/macvtap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index dc76670..0605da8 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -744,7 +744,7 @@ err:
>  	rcu_read_lock();
>  	vlan = rcu_dereference(q->vlan);
>  	if (vlan)
> -		vlan->dev->stats.tx_dropped++;
> +		this_cpu_inc(vlan->pcpu_stats->tx_dropped);
>  	rcu_read_unlock();
>  
>  	return err;
> -- 
> 1.8.3.2
