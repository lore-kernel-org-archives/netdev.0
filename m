From: Patrick McHardy <kaber@trash.net>
Subject: Re: [net-next 6/10] bnx2x: Update vlan_features
Date: Thu, 23 Jul 2009 12:46:27 +0200
Message-ID: <4A683F83.1060701@trash.net>
References: <1248191263.18195.49.camel@lb-tlvb-eilong>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Gerlitz <ogerlitz@Voltaire.com>
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33267 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752881AbZGWKqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 06:46:35 -0400
In-Reply-To: <1248191263.18195.49.camel@lb-tlvb-eilong>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eilon Greenstein wrote:
> As noted by Or Gerlitz <ogerlitz@Voltaire.com>, the vlan_features was not
> updated
> 
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> ---
>  drivers/net/bnx2x_main.c |   19 +++++++++++++++++--
>  1 files changed, 17 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
> index 18c3803..b404a9b 100644
> --- a/drivers/net/bnx2x_main.c
> +++ b/drivers/net/bnx2x_main.c
> @@ -9310,9 +9310,17 @@ static int bnx2x_set_tso(struct net_device *dev, u32 data)
>  	if (data) {
>  		dev->features |= (NETIF_F_TSO | NETIF_F_TSO_ECN);
>  		dev->features |= NETIF_F_TSO6;
> +#ifdef BCM_VLAN
> +		dev->vlan_features |= (NETIF_F_TSO | NETIF_F_TSO_ECN);
> +		dev->vlan_features |= NETIF_F_TSO6;
> +#endif
>  	} else {
>  		dev->features &= ~(NETIF_F_TSO | NETIF_F_TSO_ECN);
>  		dev->features &= ~NETIF_F_TSO6;
> +#ifdef BCM_VLAN
> +		dev->vlan_features &= ~(NETIF_F_TSO | NETIF_F_TSO_ECN);
> +		dev->vlan_features &= ~NETIF_F_TSO6;
> +#endif

vlan_features doesn't need to be updated, the resulting dev->features
of the VLAN device is computed as the intersection of dev->features
and dev->vlan_features.

