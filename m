From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: i40e: prevent access to uninitilized variables in i40e_tx_enable_csum()
Date: Sun, 31 Jan 2016 16:00:30 +0100
Message-ID: <2765946.QCanWNG0gi@wuerfel>
References: <56ACD7C6.1010808@virtuozzo.com> <56ACE928.3080108@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	intel-wired-lan@lists.osuosl.org
To: Vasily Averin <vvs@virtuozzo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:53658 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757218AbcAaPAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jan 2016 10:00:50 -0500
In-Reply-To: <56ACE928.3080108@virtuozzo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 30 January 2016 19:47:36 Vasily Averin wrote:
> Patch makes safe an access to 'oiph' and 'oudph' variables
> if they was not initilized.
> 
> Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> index 47bd8b3..779f77e 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> @@ -2363,7 +2363,8 @@ static void i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
>                 }
>                 if ((tx_ring->flags & I40E_TXR_FLAGS_OUTER_UDP_CSUM) &&
>                     (l4_tunnel == I40E_TXD_CTX_UDP_TUNNELING)        &&
> -                   (*cd_tunneling & I40E_TXD_CTX_QW0_EXT_IP_MASK)) {
> +                   (*cd_tunneling & I40E_TXD_CTX_QW0_EXT_IP_MASK)   &&
> +                   oudph && oiph) {
>                         oudph->check = ~csum_tcpudp_magic(oiph->saddr,
>                                         oiph->daddr,
>                                         (skb->len - skb_transport_offset(skb)),

If we can actually get here with oudph==NULL or oiph==NULL, we should back
my patch instead and fix it another way.

In the version we have in net-next, that is not possible.

	Arnd
