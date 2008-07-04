From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCHv2] fs_enet: restore promiscuous and multicast settings
 in restart()
Date: Fri, 04 Jul 2008 08:25:07 -0400
Message-ID: <486E16A3.6020403@garzik.org>
References: <200806261148.26569.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	pantelis.antoniou@gmail.com, vbordug@ru.mvista.com,
	Matvejchikov Ilya <matvejchikov@gmail.com>
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48136 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753086AbYGDMZO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2008 08:25:14 -0400
In-Reply-To: <200806261148.26569.laurentp@cse-semaphore.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Laurent Pinchart wrote:
> The restart() function is called when the link state changes and resets
> multicast and promiscuous settings. This patch restores those settings at the
> end of restart().
> 
> Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
> ---
>  drivers/net/fs_enet/mac-fcc.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/fs_enet/mac-fcc.c b/drivers/net/fs_enet/mac-fcc.c
> index e363211..849afbe 100644
> --- a/drivers/net/fs_enet/mac-fcc.c
> +++ b/drivers/net/fs_enet/mac-fcc.c
> @@ -463,6 +463,9 @@ static void restart(struct net_device *dev)
>  	else
>  		C32(fccp, fcc_fpsmr, FCC_PSMR_FDE | FCC_PSMR_LPB);
>  
> +	/* Restore multicast and promiscuous settings */
> +	set_multicast_list(dev);
> +
>  	S32(fccp, fcc_gfmr, FCC_GFMR_ENR | FCC_GFMR_ENT);

applied 2.6.26


