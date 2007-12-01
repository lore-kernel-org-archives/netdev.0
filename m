From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000: Fix NAPI state bug when Rx complete
Date: Sat, 01 Dec 2007 16:34:31 -0500
Message-ID: <4751D367.3030908@garzik.org>
References: <20071128002636.26015.28453.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, davem@davemloft.net
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:32894 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751059AbXLAVee (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2007 16:34:34 -0500
In-Reply-To: <20071128002636.26015.28453.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Auke Kok wrote:
> Don't exit polling when we have not yet used our budget, this causes
> the NAPI system to end up with a messed up poll list.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000/e1000_main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> index b7c3070..724f067 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -3926,7 +3926,7 @@ e1000_clean(struct napi_struct *napi, int budget)
>  	                  &work_done, budget);
>  
>  	/* If no Tx and not enough Rx work done, exit the polling mode */
> -	if ((!tx_cleaned && (work_done < budget)) ||
> +	if ((!tx_cleaned && (work_done == 0)) ||
>  	   !netif_running(poll_dev)) {

applied


