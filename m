From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sfc: Use ether_addr_copy and
 eth_broadcast_addr
Date: Tue, 04 Mar 2014 15:36:53 -0500 (EST)
Message-ID: <20140304.153653.263004778768283059.davem@davemloft.net>
References: <alpine.LFD.2.03.1403041449370.13034@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sshah@solarflare.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36746 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932618AbaCDUg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 15:36:56 -0500
In-Reply-To: <alpine.LFD.2.03.1403041449370.13034@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Tue, 4 Mar 2014 20:11:34 +0000

> Faster than memcpy/memset on some architectures.
> 
> Signed-off-by: Edward Cree <ecree@solarflare.com>
> ---
>  drivers/net/ethernet/sfc/ef10.c        | 13 +++++--------
>  drivers/net/ethernet/sfc/efx.c         |  4 ++--
>  drivers/net/ethernet/sfc/ethtool.c     | 17 ++++++++---------
>  drivers/net/ethernet/sfc/falcon.c      |  2 +-
>  drivers/net/ethernet/sfc/filter.h      |  2 +-
>  drivers/net/ethernet/sfc/mcdi.c        | 14 ++++++++------
>  drivers/net/ethernet/sfc/mcdi_port.c   |  4 ++--
>  drivers/net/ethernet/sfc/selftest.c    |  6 +++---
>  drivers/net/ethernet/sfc/siena_sriov.c | 13 ++++++-------
>  9 files changed, 36 insertions(+), 39 deletions(-)
> 
> diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
> index 3b39798..de0c815 100644
> --- a/drivers/net/ethernet/sfc/ef10.c
> +++ b/drivers/net/ethernet/sfc/ef10.c
> @@ -162,8 +162,8 @@ static int efx_ef10_get_mac_address(struct efx_nic *efx, u8 *mac_address)
>  	if (outlen < MC_CMD_GET_MAC_ADDRESSES_OUT_LEN)
>  		return -EIO;
>  
> -	memcpy(mac_address,
> -	       MCDI_PTR(outbuf, GET_MAC_ADDRESSES_OUT_MAC_ADDR_BASE), ETH_ALEN);
> +	ether_addr_copy(mac_address,
> +	       MCDI_PTR(outbuf, GET_MAC_ADDRESSES_OUT_MAC_ADDR_BASE));

This is not indented correctly, the original code was.

When a function call spans multiple lines, the arguments on the second
and subsequent lines must start at the first column after the openning
parenthesis of the function call.

You must use the appropriate number of TAB and space characters necessary
to achieve this.
