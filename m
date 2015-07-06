From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH net] Revert "dev: set iflink to 0 for virtual interfaces"
Date: Mon, 06 Jul 2015 18:38:06 +0200
Message-ID: <559AAEEE.5060208@hartkopp.net>
References: <5589959A.8060600@hartkopp.net> <1436196310-4090-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ulrich.gemkow@ikr.uni-stuttgart.de, davem@davemloft.net,
	netdev@vger.kernel.org, shemminger@vyatta.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.217]:8979 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752343AbbGFQi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 12:38:26 -0400
In-Reply-To: <1436196310-4090-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06.07.2015 17:25, Nicolas Dichtel wrote:
> This reverts commit e1622baf54df8cc958bf29d71de5ad545ea7d93c.
>
> The side effect of this commit is to add a '@NONE' after each virtual
> interface name with a 'ip link'. It may break existing scripts.
>
> Reported-by: Olivier Hartkopp <socketcan@hartkopp.net>
                   ^^^
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Tested-by: Oliver Hartkopp <socketcan@hartkopp.net>

Thanks Nicolas!

BR
Oliver

> ---
>   net/core/dev.c | 4 ----
>   1 file changed, 4 deletions(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 6778a9999d52..72e0a4331154 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -677,10 +677,6 @@ int dev_get_iflink(const struct net_device *dev)
>   	if (dev->netdev_ops && dev->netdev_ops->ndo_get_iflink)
>   		return dev->netdev_ops->ndo_get_iflink(dev);
>
> -	/* If dev->rtnl_link_ops is set, it's a virtual interface. */
> -	if (dev->rtnl_link_ops)
> -		return 0;
> -
>   	return dev->ifindex;
>   }
>   EXPORT_SYMBOL(dev_get_iflink);
>
