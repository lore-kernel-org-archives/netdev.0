From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v5 5/9] net: Define enum for net device features.
Date: Thu, 17 Nov 2011 00:34:08 +0100
Message-ID: <20111116233408.GB8476@rere.qmqm.pl>
References: <cover.1321404954.git.mirq-linux@rere.qmqm.pl>
 <d47c3468cf74bd42f28989d078d9a70ca8cfd7e0.1321404954.git.mirq-linux@rere.qmqm.pl>
 <1321483177.2709.28.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:43981 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753962Ab1KPXeK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 18:34:10 -0500
Content-Disposition: inline
In-Reply-To: <1321483177.2709.28.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 16, 2011 at 10:39:37PM +0000, Ben Hutchings wrote:
> On Wed, 2011-11-16 at 02:29 +0100, Micha=B3 Miros=B3aw wrote:
> > Define feature values by bit position instead of direct 2**i values
> > and force the values to be of type netdev_features_t.
> >=20
> > Cleaned and extended from patch by Mahesh Bandewar <maheshb@google.=
com>:
> > + added netdev_features_t casts
> > + included bits under NETIF_F_GSO_MASK
> > + moved feature #defines out of struct net_device definition
> >=20
> > Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> > ---
> >  include/linux/netdev_features.h |  129 +++++++++++++++++++++++++++=
-----------
> >  1 files changed, 91 insertions(+), 38 deletions(-)
> >=20
> > diff --git a/include/linux/netdev_features.h b/include/linux/netdev=
_features.h
> > index af52381..04ac8f8 100644
> > --- a/include/linux/netdev_features.h
> > +++ b/include/linux/netdev_features.h
> [...]
> > +	/**/NETIF_F_GSO_SHIFT,		/* keep the order of SKB_GSO_* bits */
> > +	NETIF_F_TSO_BIT			/* ... TCPv4 segmentation */
> > +		=3D NETIF_F_GSO_SHIFT,
> > +	NETIF_F_UFO_BIT,		/* ... UDPv4 fragmentation */
> > +	NETIF_F_GSO_ROBUST_BIT,		/* ... ->SKB_GSO_DODGY */
> > +	NETIF_F_TSO_ECN_BIT,		/* ... TCP ECN support */
> > +	NETIF_F_TSO6_BIT,		/* ... TCPv6 segmentation */
> > +	NETIF_F_FSO_BIT,		/* ... FCoE segmentation */
> > +	NETIF_F_GSO_RESERVED1,		/* ... free (fill GSO_MASK to 8 bits) */
> > +	/**/NETIF_F_GSO_LAST,		/* [can't be last bit, see GSO_MASK] */
> > +	NETIF_F_GSO_RESERVED2		/* ... free (fill GSO_MASK to 8 bits) */
> > +		=3D NETIF_F_GSO_LAST,
> > =20
> > -/* Segmentation offload features */
> > -#define NETIF_F_GSO_SHIFT	16
> > -#define NETIF_F_GSO_MASK	0x00ff0000
> > -#define NETIF_F_TSO		(SKB_GSO_TCPV4 << NETIF_F_GSO_SHIFT)
> > -#define NETIF_F_UFO		(SKB_GSO_UDP << NETIF_F_GSO_SHIFT)
> > -#define NETIF_F_GSO_ROBUST	(SKB_GSO_DODGY << NETIF_F_GSO_SHIFT)
> > -#define NETIF_F_TSO_ECN		(SKB_GSO_TCP_ECN << NETIF_F_GSO_SHIFT)
> > -#define NETIF_F_TSO6		(SKB_GSO_TCPV6 << NETIF_F_GSO_SHIFT)
> > -#define NETIF_F_FSO		(SKB_GSO_FCOE << NETIF_F_GSO_SHIFT)
> [...]
>=20
> You should either add BUILD_BUG_ON()s somewhere to ensure that the
> netdev feature and skb GSO flags remain in sync, or redefine the skb =
GSO
> flags using the netdev feature flags (which I thought was the reason =
for
> moving features to their own header).

Main motiviation for the moving out of features to separate headers was
to avoid circular inclusion of linux/netdevice.h from linux/skbuff.h.
We get readability for free.

BUILD_BUG_ON() is a good idea. It should go to skbuff.h and as separate
patch as it's something new and independent.

Best Regards,
Micha=B3 Miros=B3aw
