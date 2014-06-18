From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH 1/2] xen-netfront: fix oops when disconnected
 from backend
Date: Wed, 18 Jun 2014 15:23:01 +0100
Message-ID: <20140618142300.GD20819@zion.uk.xensource.com>
References: <1403084848-12872-1-git-send-email-david.vrabel@citrix.com>
 <1403084848-12872-2-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	<wei.liu2@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:45250 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191AbaFROXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 10:23:10 -0400
Content-Disposition: inline
In-Reply-To: <1403084848-12872-2-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 18, 2014 at 10:47:27AM +0100, David Vrabel wrote:
> xennet_disconnect_backend() was not correctly iterating over all the
> queues.
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Reviewed-by: Wei Liu <wei.liu2@citrix.com>

> ---
>  drivers/net/xen-netfront.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 5a7872a..daaf1e5 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -1287,7 +1287,7 @@ static irqreturn_t xennet_rx_interrupt(int irq, void *dev_id)
>  
>  	if (likely(netif_carrier_ok(dev) &&
>  		   RING_HAS_UNCONSUMED_RESPONSES(&queue->rx)))
> -			napi_schedule(&queue->napi);
> +		napi_schedule(&queue->napi);
>  

This indentation fix is not actually related to this bug. IMHO it should
either be removed or noted in commit message.

Wei.
