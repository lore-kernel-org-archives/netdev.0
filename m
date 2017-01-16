From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH] sfc: Replace memset with eth_zero_addr
Date: Mon, 16 Jan 2017 09:35:38 +0000
Message-ID: <7f1c75ec-3cad-0071-9f41-86773361281e@solarflare.com>
References: <1484538981-24591-1-git-send-email-mayhs11saini@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <bkenward@solarflare.com>, <netdev@vger.kernel.org>,
        <linux-net-drivers@solarflare.com>
To: Shyam Saini <mayhs11saini@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:2085 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751070AbdAPJfw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 04:35:52 -0500
In-Reply-To: <1484538981-24591-1-git-send-email-mayhs11saini@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/01/17 03:56, Shyam Saini wrote:
> Use eth_zero_addr to assign zero address to the given address array
> instead of memset when the second argument in memset is address
> of zero which makes the code clearer and also add header
> file linux/etherdevice.h
>
> Signed-off-by: Shyam Saini <mayhs11saini@gmail.com>
> ---
Acked-by: Edward Cree <ecree@solarflare.com>
>  drivers/net/ethernet/sfc/ef10_sriov.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/sfc/ef10_sriov.c b/drivers/net/ethernet/sfc/ef10_sriov.c
> index a949b9d..228806c 100644
> --- a/drivers/net/ethernet/sfc/ef10_sriov.c
> +++ b/drivers/net/ethernet/sfc/ef10_sriov.c
> @@ -6,6 +6,7 @@
>   * under the terms of the GNU General Public License version 2 as published
>   * by the Free Software Foundation, incorporated herein by reference.
>   */
> +#include <linux/etherdevice.h>
>  #include <linux/pci.h>
>  #include <linux/module.h>
>  #include "net_driver.h"
> @@ -554,7 +555,7 @@ int efx_ef10_sriov_set_vf_mac(struct efx_nic *efx, int vf_i, u8 *mac)
>  	return 0;
>  
>  fail:
> -	memset(vf->mac, 0, ETH_ALEN);
> +	eth_zero_addr(vf->mac);
>  	return rc;
>  }
>  
