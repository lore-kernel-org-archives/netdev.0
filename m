From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] fs_enet: Don't call NAPI functions when NAPI is not used.
Date: Sat, 12 Apr 2008 01:53:53 -0400
Message-ID: <48004E71.4040805@pobox.com>
References: <200804111405.50896.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44467 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753502AbYDLFx4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 01:53:56 -0400
In-Reply-To: <200804111405.50896.laurentp@cse-semaphore.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Laurent Pinchart wrote:
> fs_enet_close() calls napi_disable() unconditionally. This patch skips the
> call when use_napi isn't set.
> 
> Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
> ---
>  drivers/net/fs_enet/fs_enet-main.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
> index c83bd65..1801ce3 100644
> --- a/drivers/net/fs_enet/fs_enet-main.c
> +++ b/drivers/net/fs_enet/fs_enet-main.c
> @@ -835,7 +835,8 @@ static int fs_enet_close(struct net_device *dev)
>  
>  	netif_stop_queue(dev);
>  	netif_carrier_off(dev);
> -	napi_disable(&fep->napi);
> +	if (fep->fpi->use_napi)
> +		napi_disable(&fep->napi);
>  	phy_stop(fep->phydev);

applied


