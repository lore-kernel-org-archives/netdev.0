From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net] macvtap: fix tx_dropped counting error
Date: Mon, 25 Nov 2013 13:29:50 -0500
Message-ID: <5293971E.7040407@redhat.com>
References: <1385371144-11071-1-git-send-email-jasowang@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Eric Dumazet <edumazet@google.com>
To: Jason Wang <jasowang@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28645 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753758Ab3KYS3y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Nov 2013 13:29:54 -0500
In-Reply-To: <1385371144-11071-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/2013 04:19 AM, Jason Wang wrote:
> After commit 8ffab51b3dfc54876f145f15b351c41f3f703195
> (macvlan: lockless tx path), tx stat counter were converted to percpu stat
> structure. So we need use to this also for tx_dropped in macvtap. Otherwise, the
> management won't notice the dropping packet in macvtap tx path.
> 
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Vlad Yasevich <vyasevic@redhat.com>

Acked-by: Vlad Yasevich <vyasevic@redhat.com>

-vlad
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
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
> 
