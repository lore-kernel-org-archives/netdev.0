From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCHv2 net-next-2.6 3/7] sfc: Implement generic features
	interface
Date: Tue, 5 Apr 2011 20:15:52 +0200
Message-ID: <20110405181552.GB16977@rere.qmqm.pl>
References: <1302026446.2932.56.camel@bwh-desktop> <1302026609.2932.59.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:49166 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755621Ab1DESPx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2011 14:15:53 -0400
Content-Disposition: inline
In-Reply-To: <1302026609.2932.59.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 05, 2011 at 07:03:29PM +0100, Ben Hutchings wrote:
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/sfc/efx.c        |   20 +++++++++--
>  drivers/net/sfc/ethtool.c    |   78 --------------------------------=
----------
>  drivers/net/sfc/net_driver.h |    2 -
>  drivers/net/sfc/rx.c         |    2 +-
>  4 files changed, 18 insertions(+), 84 deletions(-)
>=20
> diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
> index 542f32d..db72a6e 100644
> --- a/drivers/net/sfc/efx.c
> +++ b/drivers/net/sfc/efx.c
[...]
> @@ -2452,12 +2463,15 @@ static int __devinit efx_pci_probe(struct pci=
_dev *pci_dev,
>  		return -ENOMEM;
>  	net_dev->features |=3D (type->offload_features | NETIF_F_SG |
>  			      NETIF_F_HIGHDMA | NETIF_F_TSO |
> -			      NETIF_F_GRO);
> +			      NETIF_F_RXCSUM);
>  	if (type->offload_features & NETIF_F_V6_CSUM)
>  		net_dev->features |=3D NETIF_F_TSO6;
>  	/* Mask for features that also apply to VLAN devices */
>  	net_dev->vlan_features |=3D (NETIF_F_ALL_CSUM | NETIF_F_SG |
> -				   NETIF_F_HIGHDMA | NETIF_F_ALL_TSO);
> +				   NETIF_F_HIGHDMA | NETIF_F_ALL_TSO |
> +				   NETIF_F_RXCSUM);
> +	/* All offloads can be toggled */
> +	net_dev->hw_features =3D net_dev->features & ~NETIF_F_HIGHDMA;
>  	efx =3D netdev_priv(net_dev);
>  	pci_set_drvdata(pci_dev, efx);
>  	SET_NETDEV_DEV(net_dev, &pci_dev->dev);

Does the driver really allow independent switching of RX checksumming
for tagged and untagged frames? The VLAN code currently doesn't ignore
HW checksum when present in skb and doesn't allow toggling of the featu=
re
(see: vlan_fix_features() and vlan_skb_recv() in net/8021q/vlan_dev.c).

Best Regards,
Micha=B3 Miros=B3aw
