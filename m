From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sfc: only use RSS filters if we're using RSS
Date: Thu, 10 Dec 2015 13:06:22 -0500 (EST)
Message-ID: <20151210.130622.228718339897846404.davem@davemloft.net>
References: <56697E60.9050304@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: bkenward@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57699 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753370AbbLJSG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 13:06:26 -0500
In-Reply-To: <56697E60.9050304@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bert Kenward <bkenward@solarflare.com>
Date: Thu, 10 Dec 2015 13:30:08 +0000

> Without this filter insertion on a VF would fail if only one channel
> was in use. This would include the unicast station filter and therefore
> no traffic would be received.
> 
> Signed-off-by: Bert Kenward <bkenward@solarflare.com>
> ---
>  drivers/net/ethernet/sfc/ef10.c  | 23 +++++++++++------------
>  drivers/net/ethernet/sfc/efx.h   |  5 +++++
>  drivers/net/ethernet/sfc/farch.c |  2 +-
>  3 files changed, 17 insertions(+), 13 deletions(-)
> 
> diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
> index c4a0e8a..368e98e 100644
> --- a/drivers/net/ethernet/sfc/ef10.c
> +++ b/drivers/net/ethernet/sfc/ef10.c
> @@ -3309,7 +3309,7 @@ static int efx_ef10_filter_remove_internal(struct efx_nic *efx,
>  
>  		new_spec.priority = EFX_FILTER_PRI_AUTO;
>  		new_spec.flags = (EFX_FILTER_FLAG_RX |
> -				  EFX_FILTER_FLAG_RX_RSS);
> +			(efx_rss_enabled(efx) ? EFX_FILTER_FLAG_RX_RSS : 0));

This was indented properly before your change, please don't damage the indentation
like this.  There must be 4 TAB characters and 2 SPACE characters on that
second line of the assignment so that the first character is precisely at the
first column after the openning parenthesis of the first line.
