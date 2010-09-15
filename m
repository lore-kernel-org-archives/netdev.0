From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] vlan: enable GRO if real_dev supports it
Date: Wed, 15 Sep 2010 18:24:36 +0100
Message-ID: <1284571476.2293.5.camel@achroite.uk.solarflarecom.com>
References: <20100914.213544.112598547.davem@davemloft.net>
	 <20100915163749.GA4191@mmm.home.ifup.org>
	 <1284570520.2462.5.camel@edumazet-laptop>
	 <20100915.101418.59680213.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, bphilips@suse.de,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, alexander.h.duyck@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com,
	donald.c.skidmore@intel.com, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:37920 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753475Ab0IORYl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 13:24:41 -0400
In-Reply-To: <20100915.101418.59680213.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-09-15 at 10:14 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 15 Sep 2010 19:08:40 +0200
>=20
> > Le mercredi 15 septembre 2010 =C3=A0 09:37 -0700, Brandon Philips a=
 =C3=A9crit :
> >> Currently vlan devices don't have GRO by default as none of the Et=
hernet
> >> drivers add NETIF_F_GRO to their vlan_features.
> >>=20
> >> As GRO is a software feature just propogate GRO from the real_dev =
in the
> >> vlan core. There is no need to have the drivers each add NETIF_F_G=
RO to
> >> their vlan_features.
> >>=20
> >> Signed-off-by: Brandon Philips <bphilips@suse.de>
> >> ---
> >>  net/8021q/vlan_dev.c |    1 +
> >>  1 files changed, 1 insertions(+), 0 deletions(-)
> >>=20
> >> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> >> index 3bccdd1..6fbc445 100644
> >> --- a/net/8021q/vlan_dev.c
> >> +++ b/net/8021q/vlan_dev.c
> >> @@ -735,6 +735,7 @@ static int vlan_dev_init(struct net_device *de=
v)
> >>  					  (1<<__LINK_STATE_DORMANT))) |
> >>  		      (1<<__LINK_STATE_PRESENT);
> >> =20
> >> +	dev->features |=3D real_dev->features & NETIF_F_GRO;
> >>  	dev->features |=3D real_dev->features & real_dev->vlan_features;
> >>  	dev->gso_max_size =3D real_dev->gso_max_size;
> >> =20
> >=20
> > Hmm, this is only part of a generic solution.
> >=20
> > If I enable gro with "ethtool -K eth0 gro on", should we propagate =
GRO
> > on vlan eth0.555 ?
>=20
> I think a better way to implement this is to set NETIF_F_GRO in
> netdev->vlan_features at register_netdev() time if it is set in
> netdev->features
>=20
> That is the implementation I was implying earlier in this thread.

We can even add it unconditionally there, since we only ever use
dev->features & dev->vlan_features.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

