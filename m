From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next] net: flush the softnet backlog in process
 context
Date: Thu, 25 Aug 2016 16:58:38 +0200
Message-ID: <1472137118.4769.38.camel@redhat.com>
References: <528006070d2951617c55b94c60c5d690ff0e4fc3.1472130597.git.pabeni@redhat.com>
         <1472135557.14381.130.camel@edumazet-glaptop3.roam.corp.google.com>
         <1472136456.14381.133.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Tom Herbert <tom@herbertland.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59834 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758459AbcHYO7c (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 10:59:32 -0400
In-Reply-To: <1472136456.14381.133.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-08-25 at 07:47 -0700, Eric Dumazet wrote:
> On Thu, 2016-08-25 at 07:32 -0700, Eric Dumazet wrote:
> 
> > In a future patch, we could change this so that we kick
> > flush_all_backlogs() once for all devices, instead of one device at a
> > time.
> > 
> > We would not pass @dev anymore as a parameter and simply look at
> > skb->dev->reg_state to decide to remove packets from queues in
> > flush_backlog()
> 
> This would be something like :

This is actually a nice cleanup. I hope to test it later.

> diff --git a/net/core/dev.c b/net/core/dev.c
> index 7feae74ca928..793ace2c600f 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4293,7 +4293,6 @@ int netif_receive_skb(struct sk_buff *skb)
>  EXPORT_SYMBOL(netif_receive_skb);
>  
>  struct flush_work {
> -	struct net_device *dev;
>  	struct work_struct work;
>  };

With 'dev' removal, I think we can use directly 'work_struct'  and avoid
'container_of' usage in flush_backlog().

Paolo
