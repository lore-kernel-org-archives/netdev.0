From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] fs_enet: restore promiscuous and multicast settings in
 restart()
Date: Thu, 19 Jun 2008 23:01:28 -0400
Message-ID: <20080619230128.def96ee0.billfink@mindspring.com>
References: <200806181707.17739.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	pantelis.antoniou@gmail.com, vbordug@ru.mvista.com
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:38104 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751873AbYFTDBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 23:01:35 -0400
In-Reply-To: <200806181707.17739.laurentp@cse-semaphore.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Jun 2008, Laurent Pinchart wrote:

> The restart() function is called when the link state changes and resets
> multicast and promiscous settings. This patch restores those settings at the
> end of restart().
> 
> Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
> ---
>  drivers/net/fs_enet/mac-fcc.c     |    3 +++
>  2 files changed, 4 insertions(+), 1 deletions(-)

Is the whole patch here?  The above says 2 files changed and 5 lines
changed, but what's included here is only 1 file and 3 line changes.

> diff --git a/drivers/net/fs_enet/mac-fcc.c b/drivers/net/fs_enet/mac-fcc.c
> index ce40cf9..1a95cf1 100644
> --- a/drivers/net/fs_enet/mac-fcc.c
> +++ b/drivers/net/fs_enet/mac-fcc.c
> @@ -464,6 +464,9 @@ static void restart(struct net_device *dev)
>  		C32(fccp, fcc_fpsmr, FCC_PSMR_FDE | FCC_PSMR_LPB);
>  
>  	S32(fccp, fcc_gfmr, FCC_GFMR_ENR | FCC_GFMR_ENT);
> +
> +	/* Restore multicast and promiscous settings */
> +	set_multicast_list(dev);
>  }
>  
>  static void stop(struct net_device *dev)

						-Bill
