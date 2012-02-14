From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC] netpoll: netpoll_poll_dev() should access dev->flags
Date: Tue, 14 Feb 2012 08:27:56 -0500
Message-ID: <20120214132755.GA2434@neilslaptop.think-freely.org>
References: <1329217821.2336.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amerigo Wang <amwang@redhat.com>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42212 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754702Ab2BNN2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 08:28:14 -0500
Content-Disposition: inline
In-Reply-To: <1329217821.2336.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 14, 2012 at 12:10:21PM +0100, Eric Dumazet wrote:
> commit 5a698af53f (bond: service netpoll arp queue on master device)
> use a dubious test : if (dev->priv_flags & IFF_SLAVE)
> 
> It seems to me IFF_SLAVE is present on dev->flags only ?
> 
> What am I missing ?
> 
I want to say there was a reason for checking priv_flags, but if there was, it
escapes me now.  Either way, ->flags is definately what we want now.  

Acked-by: Neil Horman <nhorman@tuxdriver.com>

> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index 4ce473e..3d84fb9 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -205,7 +205,7 @@ static void netpoll_poll_dev(struct net_device *dev)
>  
>  	poll_napi(dev);
>  
> -	if (dev->priv_flags & IFF_SLAVE) {
> +	if (dev->flags & IFF_SLAVE) {
>  		if (dev->npinfo) {
>  			struct net_device *bond_dev = dev->master;
>  			struct sk_buff *skb;
> 
> 
> 
