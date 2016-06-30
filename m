From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: poll tx timeout only on active tx queues
Date: Thu, 30 Jun 2016 16:28:12 +0200
Message-ID: <1467296892.11238.24.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1467295085-9204-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <tom@herbertland.com>,
	Mohamad Haj Yahia <mohamad@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34103 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752170AbcF3O3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 10:29:12 -0400
Received: by mail-wm0-f68.google.com with SMTP id 187so23369102wmz.1
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 07:28:15 -0700 (PDT)
In-Reply-To: <1467295085-9204-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-06-30 at 16:58 +0300, Saeed Mahameed wrote:
> From: Mohamad Haj Yahia <mohamad@mellanox.com>
> 
> Change the netdev watchdog to poll only the real active tx queues
> instead of polling all tx queues.
> The netdev driver doesn't necessarily have to start/stop all the
> tx queues including the inactive tx queues.
> 
> Fixes: fd2ea0a79faa ('net: Use queue aware tests throughout.')
> Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> ---
>  net/sched/sch_generic.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index f9e0e9c..a10f0ff 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -253,7 +253,7 @@ static void dev_watchdog(unsigned long arg)
>  			unsigned int i;
>  			unsigned long trans_start;
>  
> -			for (i = 0; i < dev->num_tx_queues; i++) {
> +			for (i = 0; i < dev->real_num_tx_queues; i++) {
>  				struct netdev_queue *txq;
>  
>  				txq = netdev_get_tx_queue(dev, i);

Strange, why don't you change all others helpers that are using
num_tx_queues ?

Which driver had a problem with this code ?
