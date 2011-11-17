From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH 2/2] net: verify GSO flag bits against netdev features
Date: Thu, 17 Nov 2011 01:13:12 +0100
Message-ID: <20111117001312.GB9596@rere.qmqm.pl>
References: <2ec988cd27c6eb5162ea2e41416edcaae207bb5e.1321488025.git.mirq-linux@rere.qmqm.pl>
 <d4513ed885d62d13873f9b7310fc20cbfa55f634.1321488025.git.mirq-linux@rere.qmqm.pl>
 <1321488596.2709.68.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:46074 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754826Ab1KQANN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 19:13:13 -0500
Content-Disposition: inline
In-Reply-To: <1321488596.2709.68.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 17, 2011 at 12:09:56AM +0000, Ben Hutchings wrote:
> On Thu, 2011-11-17 at 01:05 +0100, Micha=B3 Miros=B3aw wrote:
> > Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> > ---
> >  include/linux/netdevice.h |    9 +++++++++
> >  1 files changed, 9 insertions(+), 0 deletions(-)
> >=20
> > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> > index b35ffd7..31da3bb 100644
> > --- a/include/linux/netdevice.h
> > +++ b/include/linux/netdevice.h
> > @@ -2492,6 +2492,15 @@ netdev_features_t netif_skb_features(struct =
sk_buff *skb);
> >  static inline int net_gso_ok(netdev_features_t features, int gso_t=
ype)
> >  {
> >  	netdev_features_t feature =3D gso_type << NETIF_F_GSO_SHIFT;
> > +
> > +	/* check flags correspondence */
> > +	BUILD_BUG_ON(SKB_GSO_TCPV4   !=3D (NETIF_F_TSO >> NETIF_F_GSO_SHI=
=46T));
> > +	BUILD_BUG_ON(SKB_GSO_UDP     !=3D (NETIF_F_UFO >> NETIF_F_GSO_SHI=
=46T));
> > +	BUILD_BUG_ON(SKB_GSO_DODGY   !=3D (NETIF_F_GSO_ROBUST >> NETIF_F_=
GSO_SHIFT));
> > +	BUILD_BUG_ON(SKB_GSO_TCP_ECN !=3D (NETIF_F_TSO_ECN >> NETIF_F_GSO=
_SHIFT));
> > +	BUILD_BUG_ON(SKB_GSO_TCPV6   !=3D (NETIF_F_TSO6 >> NETIF_F_GSO_SH=
IFT));
> > +	BUILD_BUG_ON(SKB_GSO_FCOE    !=3D (NETIF_F_FSO >> NETIF_F_GSO_SHI=
=46T));
> > +
> >  	return (features & feature) =3D=3D feature;
> >  }
> This is fine but should still be done at the same time as changing th=
e
> definitions.

Agreed. But as Dave was quicker, we need to fix this in separate patch.

Best Regards,
Micha=B3 Miros=B3aw
