From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/2] net: verify GSO flag bits against netdev features
Date: Thu, 17 Nov 2011 00:35:18 +0000
Message-ID: <1321490118.2709.87.camel@bwh-desktop>
References: <2ec988cd27c6eb5162ea2e41416edcaae207bb5e.1321488025.git.mirq-linux@rere.qmqm.pl>
	 <d4513ed885d62d13873f9b7310fc20cbfa55f634.1321488025.git.mirq-linux@rere.qmqm.pl>
	 <1321488596.2709.68.camel@bwh-desktop> <20111117001312.GB9596@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:43202 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754073Ab1KQAfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 19:35:21 -0500
In-Reply-To: <20111117001312.GB9596@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-11-17 at 01:13 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> On Thu, Nov 17, 2011 at 12:09:56AM +0000, Ben Hutchings wrote:
> > On Thu, 2011-11-17 at 01:05 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> > > Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl=
>
> > > ---
> > >  include/linux/netdevice.h |    9 +++++++++
> > >  1 files changed, 9 insertions(+), 0 deletions(-)
> > >=20
> > > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.=
h
> > > index b35ffd7..31da3bb 100644
> > > --- a/include/linux/netdevice.h
> > > +++ b/include/linux/netdevice.h
> > > @@ -2492,6 +2492,15 @@ netdev_features_t netif_skb_features(struc=
t sk_buff *skb);
> > >  static inline int net_gso_ok(netdev_features_t features, int gso=
_type)
> > >  {
> > >  	netdev_features_t feature =3D gso_type << NETIF_F_GSO_SHIFT;
> > > +
> > > +	/* check flags correspondence */
> > > +	BUILD_BUG_ON(SKB_GSO_TCPV4   !=3D (NETIF_F_TSO >> NETIF_F_GSO_S=
HIFT));
> > > +	BUILD_BUG_ON(SKB_GSO_UDP     !=3D (NETIF_F_UFO >> NETIF_F_GSO_S=
HIFT));
> > > +	BUILD_BUG_ON(SKB_GSO_DODGY   !=3D (NETIF_F_GSO_ROBUST >> NETIF_=
=46_GSO_SHIFT));
> > > +	BUILD_BUG_ON(SKB_GSO_TCP_ECN !=3D (NETIF_F_TSO_ECN >> NETIF_F_G=
SO_SHIFT));
> > > +	BUILD_BUG_ON(SKB_GSO_TCPV6   !=3D (NETIF_F_TSO6 >> NETIF_F_GSO_=
SHIFT));
> > > +	BUILD_BUG_ON(SKB_GSO_FCOE    !=3D (NETIF_F_FSO >> NETIF_F_GSO_S=
HIFT));
> > > +
> > >  	return (features & feature) =3D=3D feature;
> > >  }
> > This is fine but should still be done at the same time as changing =
the
> > definitions.
>=20
> Agreed. But as Dave was quicker, we need to fix this in separate patc=
h.

Sorry, I somehow failed to spot that.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
