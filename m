From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] net: Fix too optimistic NETIF_F_HW_CSUM features
Date: Tue, 30 Nov 2010 16:41:23 +0100
Message-ID: <20101130154123.GA27904@rere.qmqm.pl>
References: <20101130142352.3936.51663.stgit@rechot.qmqm.pl> <1291130005.21077.18.camel@bwh-desktop> <20101130152838.GA26281@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>,
	Jesse Gross <jesse@nicira.com>
To: Ramkrishna Vepa <ramkrishna.vepa@exar.com>,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Jon Mason <jon.mason@exar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:42198 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753083Ab0K3PlY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Nov 2010 10:41:24 -0500
Content-Disposition: inline
In-Reply-To: <20101130152838.GA26281@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 30, 2010 at 04:28:38PM +0100, Micha=B3Miros=B3aw wrote:
> On Tue, Nov 30, 2010 at 03:13:25PM +0000, Ben Hutchings wrote:
> > On Tue, 2010-11-30 at 15:23 +0100, Micha=B3Miros=B3aw wrote:
> > > NETIF_F_HW_CSUM is superset of NETIF_F_IP_CSUM+NETIF_F_IPV6_CSUM,=
 but
> > > some drivers miss the difference. Fix this and also fix UFO depen=
dency
> > > on checksumming offload as it makes the same mistake in assumptio=
ns.
[...]
> > > diff --git a/drivers/net/vxge/vxge-ethtool.c b/drivers/net/vxge/v=
xge-ethtool.c
> > > index bc9bd10..5ece50d 100644
> > > --- a/drivers/net/vxge/vxge-ethtool.c
> > > +++ b/drivers/net/vxge/vxge-ethtool.c
> > > @@ -1177,7 +1177,7 @@ static const struct ethtool_ops vxge_ethtoo=
l_ops =3D {
> > >  	.get_rx_csum		=3D vxge_get_rx_csum,
> > >  	.set_rx_csum		=3D vxge_set_rx_csum,
> > >  	.get_tx_csum		=3D ethtool_op_get_tx_csum,
> > > -	.set_tx_csum		=3D ethtool_op_set_tx_hw_csum,
> > > +	.set_tx_csum		=3D ethtool_op_set_tx_csum,
> > >  	.get_sg			=3D ethtool_op_get_sg,
> > >  	.set_sg			=3D ethtool_op_set_sg,
> > >  	.get_tso		=3D ethtool_op_get_tso,
> > > diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge=
-main.c
> > > index a21dae1..9f6d379 100644
> > > --- a/drivers/net/vxge/vxge-main.c
> > > +++ b/drivers/net/vxge/vxge-main.c
> > > @@ -3368,7 +3368,7 @@ static int __devinit vxge_device_register(s=
truct __vxge_hw_device *hldev,
> > > =20
> > >  	ndev->features |=3D NETIF_F_SG;
> > > =20
> > > -	ndev->features |=3D NETIF_F_HW_CSUM;
> > > +	ndev->features |=3D NETIF_F_IP_CSUM;
> > >  	vxge_debug_init(vxge_hw_device_trace_level_get(hldev),
> > >  		"%s : checksuming enabled", __func__);
> > > =20
> > Why are you disabling IPv6 checksum offload?  From a quick look at =
the
> > driver, I think the hardware does support it.
>=20
> In vxge_xmit() (at drivers/net/vxge/vxge-main.c:922 in net-next) ther=
e
> is the following code, that suggested otherwise:
>=20
>         if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
>                 vxge_hw_fifo_txdl_cksum_set_bits(dtr,
>                                         VXGE_HW_FIFO_TXD_TX_CKO_IPV4_=
EN |
>                                         VXGE_HW_FIFO_TXD_TX_CKO_TCP_E=
N |
>                                         VXGE_HW_FIFO_TXD_TX_CKO_UDP_E=
N);
>=20

Lets ask vxge driver maintainters on this.

Does vxge support IPv6 TCP/UDP checksumming offload?

Best Regards,
Micha=B3 Miros=B3aw
