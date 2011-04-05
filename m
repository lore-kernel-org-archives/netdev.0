From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv2 net-next-2.6 3/7] sfc: Implement generic features
 interface
Date: Tue, 05 Apr 2011 19:20:40 +0100
Message-ID: <1302027640.2932.70.camel@bwh-desktop>
References: <1302026446.2932.56.camel@bwh-desktop>
	 <1302026609.2932.59.camel@bwh-desktop>
	 <20110405181552.GB16977@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:17480 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753014Ab1DESUn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 14:20:43 -0400
In-Reply-To: <20110405181552.GB16977@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-04-05 at 20:15 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> On Tue, Apr 05, 2011 at 07:03:29PM +0100, Ben Hutchings wrote:
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> > ---
> >  drivers/net/sfc/efx.c        |   20 +++++++++--
> >  drivers/net/sfc/ethtool.c    |   78 ------------------------------=
------------
> >  drivers/net/sfc/net_driver.h |    2 -
> >  drivers/net/sfc/rx.c         |    2 +-
> >  4 files changed, 18 insertions(+), 84 deletions(-)
> >=20
> > diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
> > index 542f32d..db72a6e 100644
> > --- a/drivers/net/sfc/efx.c
> > +++ b/drivers/net/sfc/efx.c
> [...]
> > @@ -2452,12 +2463,15 @@ static int __devinit efx_pci_probe(struct p=
ci_dev *pci_dev,
> >  		return -ENOMEM;
> >  	net_dev->features |=3D (type->offload_features | NETIF_F_SG |
> >  			      NETIF_F_HIGHDMA | NETIF_F_TSO |
> > -			      NETIF_F_GRO);
> > +			      NETIF_F_RXCSUM);
> >  	if (type->offload_features & NETIF_F_V6_CSUM)
> >  		net_dev->features |=3D NETIF_F_TSO6;
> >  	/* Mask for features that also apply to VLAN devices */
> >  	net_dev->vlan_features |=3D (NETIF_F_ALL_CSUM | NETIF_F_SG |
> > -				   NETIF_F_HIGHDMA | NETIF_F_ALL_TSO);
> > +				   NETIF_F_HIGHDMA | NETIF_F_ALL_TSO |
> > +				   NETIF_F_RXCSUM);
> > +	/* All offloads can be toggled */
> > +	net_dev->hw_features =3D net_dev->features & ~NETIF_F_HIGHDMA;
> >  	efx =3D netdev_priv(net_dev);
> >  	pci_set_drvdata(pci_dev, efx);
> >  	SET_NETDEV_DEV(net_dev, &pci_dev->dev);
>=20
> Does the driver really allow independent switching of RX checksumming
> for tagged and untagged frames?

No.

> The VLAN code currently doesn't ignore
> HW checksum when present in skb and doesn't allow toggling of the fea=
ture
> (see: vlan_fix_features() and vlan_skb_recv() in net/8021q/vlan_dev.c=
).

So RX checksum offload is reported as enabled on the VLAN device iff it
is enabled for the physical device, which is correct.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

