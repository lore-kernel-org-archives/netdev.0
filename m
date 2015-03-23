From: Shradha Shah <sshah@solarflare.com>
Subject: Re: sfc fixup patch
Date: Mon, 23 Mar 2015 10:55:15 +0000
Message-ID: <550FF113.8000209@solarflare.com>
References: <1427080232.4770.212.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:53911 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752060AbbCWLCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 07:02:42 -0400
In-Reply-To: <1427080232.4770.212.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 23/03/15 03:10, Benjamin Herrenschmidt wrote:
> Hi Dave, Shradha !
> 
> While merging some EEH changes, I noticed a breakage in the SFC driver
> due to it using an API we didn't mean driver to use directly and that
> is going away. I've done this small fixup patch, any objection to me
> sticking it in the original series (as to avoid bisection breaks)
> before I send it to Linus ?
> 
> Cheers,
> Ben.
> 
> net/ethernet/sfc: Don't use of_node_to_eeh_dev()
> 
> This is deprecated, it forces the driver to hop via the OF node
> that may or may not exist, instead use pci_dev_to_eeh_dev() which
> is simpler.
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

Acked-by: Shradha Shah <sshah@solarflare.com>

> ---
>  drivers/net/ethernet/sfc/efx.c   | 4 +---
>  drivers/net/ethernet/sfc/siena.c | 3 +--
>  2 files changed, 2 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
> index 2384824..77d6453 100644
> --- a/drivers/net/ethernet/sfc/efx.c
> +++ b/drivers/net/ethernet/sfc/efx.c
> @@ -2523,9 +2523,7 @@ int efx_try_recovery(struct efx_nic *efx)
>  	 * schedule a 'recover or reset', leading to this recovery handler.
>  	 * Manually call the eeh failure check function.
>  	 */
> -	struct eeh_dev *eehdev =
> -		of_node_to_eeh_dev(pci_device_to_OF_node(efx->pci_dev));
> -
> +	struct eeh_dev *eehdev = pci_dev_to_eeh_dev(efx->pci_dev);
>  	if (eeh_dev_check_failure(eehdev)) {
>  		/* The EEH mechanisms will handle the error and reset the
>  		 * device if necessary.
> diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
> index 3583f02..f12c811 100644
> --- a/drivers/net/ethernet/sfc/siena.c
> +++ b/drivers/net/ethernet/sfc/siena.c
> @@ -205,8 +205,7 @@ static int siena_map_reset_flags(u32 *flags)
>   */
>  static void siena_monitor(struct efx_nic *efx)
>  {
> -	struct eeh_dev *eehdev =
> -		of_node_to_eeh_dev(pci_device_to_OF_node(efx->pci_dev));
> +	struct eeh_dev *eehdev = pci_dev_to_eeh_dev(efx->pci_dev);
>  
>  	eeh_dev_check_failure(eehdev);
>  }
> 
> 

-- 
Many Thanks,
Regards,
Shradha Shah
