From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH] net/core: use htons for skb->protocol
Date: Tue, 29 Jun 2010 15:19:10 -0700
Message-ID: <4C2A715E.4010301@caviumnetworks.com>
References: <20100629163246.GA18647@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:3130 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756172Ab0F2WTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 18:19:12 -0400
In-Reply-To: <20100629163246.GA18647@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/29/2010 09:32 AM, Sebastian Andrzej Siewior wrote:
> From: Sebastian Andrzej Siewior<bigeasy@linutronix.de>
>
> This is only noticed by people that are not doing everything correct in
> the first place.
>
> Signed-off-by: Sebastian Andrzej Siewior<bigeasy@linutronix.de>
> ---
>   net/core/dev.c |    3 ++-
>   1 files changed, 2 insertions(+), 1 deletions(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 2b3bf53..78ad37c 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1541,7 +1541,8 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
>   				if (net_ratelimit())
>   					printk(KERN_CRIT "protocol %04x is "
>   					       "buggy, dev %s\n",
> -					       skb2->protocol, dev->name);
> +					       htons(skb2->protocol),

Would ntohs() be more appropriate here?  It looks like you are 
converting from network order to host order for printing.

David Daney
