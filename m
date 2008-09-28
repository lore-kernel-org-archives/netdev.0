From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: wireless vs. network namespaces (part II)
Date: Sun, 28 Sep 2008 09:40:51 +0200
Message-ID: <1222587651.3798.72.camel@johannes.berg>
References: <1222509685.3798.59.camel@johannes.berg>
	 <m1r675aw0l.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-gHgsaSec0iEKm4nDQu0r"
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Jouni Malinen <j@w1.fi>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:56579 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077AbYI1Hk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2008 03:40:58 -0400
In-Reply-To: <m1r675aw0l.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-gHgsaSec0iEKm4nDQu0r
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, 2008-09-27 at 18:39 -0700, Eric W. Biederman wrote:

> Sounds like a fun way to test the wireless stack.
> Have both a client and an access point on the same box talking
> to each other ;)

Pretty much. Or mesh networking :)

> > When looking into it, though, I noticed that you can generate some
> > breakage with wireless and network namespaces: you can move a wireless
> > netdev to a different namespace and then things will break down because
> > we internally use init_net to find it.
>=20
> > What I'd like to do in wireless is not allow moving netdevs between
> > namespaces, but rather move entire hardware devices between namespaces,
> > I see little value and great pain in trying to support virtual
> > interfaces from a single physical device showing up in different
> > namespaces, but I do see value in binding a physical device (wiphy) to =
a
> > namespace.
>=20
> At the moment I don't understand the distinction very well.  Why do we
> have both a wireless master device and a wireless device that we
> actually use?

The wireless "master" device is just a hack in mac80211, the actual
thing you'd want would be having all interfaces that are on the same
physical hardware to be in one namespace.

> In the wired ethernet world there is a lot of value in moving just
> a vlan interface or just one mac address with mac vlan into a network
> namespace.  Allowing full speed access to the hardware that can do
> just about anything while functionally restricting what user space
> can do with the hardware.

Right, except that wireless really is different in that for one you
can't really usefully have multiple virtual interfaces unless you're
making an AP (and I think it's unlikely you'd want that in an AP, and
even if I'm not willing to support it, it'd be rather complicated); also
you could use each of the interfaces to manipulate PHY parameters like
the channel it's operating on etc. You can still of course operate
software-implemented VLANs on top for different namespaces, but since so
far no hardware that does this in hw/fw has shown up I don't see the
point.

> > As far as I understand, to disallow moving them, I should set the
> > NETIF_F_NETNS_LOCAL flag on all devices, although that is sort of a
> > misnomer then because I'd be using it to indicate 'cannot switch
> > namespace'.=20
>=20
> In this case yes.   It is designed for devices like the loo back
> device and other virtual devices that we use for creating virtual
> devices.  Although the recent support for creating new network
> devices with netlink removes much of the need for the second use case.
>=20
> It was also designed to handle the case if we do find a network
> device that just can't handle being moved between network namespaces.

Ok.

> >  * ensure that all netdevs created for this wiphy will have the right
> >    netns.
> >
> > The latter part I'm unsure on, alloc_netdev_mq seems to always use
> > init_net so I can't put them into the right namespace to start with, bu=
t
> > because they're all "in there together" I can't allow switching
> > namespaces either.. Ideas?
>=20
> alloc_netdev_mq doesn't register the device, so it is a matter of simply
> changing the network device pointer after allocation and before registrat=
ion.
>=20
> We do this by default when we dynamically create network devices using
> netlink.  see rtnl_create_link for an example.

Ok. So I guess I'd want to write a wrapper for registering the netdev
that puts it into the right namespace for the wireless hardware and sets
the NETIF_F_NETNS_LOCAL flag.

I'll have to experiment a bit I guess.

Thanks,
johannes

--=-gHgsaSec0iEKm4nDQu0r
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJI3zT/AAoJEKVg1VMiehFYAgwP/3BOj6TAZeGrBS7rdj2dyNV1
1x62APZ46CTLfIp1zUBWd6Vw5TY3E3h+snuW7jDYDdl5nK9dcJYot9Lgt1dInotc
a4DgiBdE3sC28uhf2+uEbhzl/b0BlJffyvxqIZnUgdlvEKaXp04VIaLF9/4Cp7oQ
Ruw4VhV97nyv85A0pNpDb6HmOEyNKnnlWouEHQwKbaFCCjHBtMZeXDhq8Qhis+p/
KU7Cgwa3Ko7gzCKm+Doo70xTIBQxG7I5pSSkcY/bNFHFJDQdDJyHiLeADKbn2ZoX
5paAUNJfqeM5h+I+bfK8bj2oDYbGzMoXzl2NzQH7OjRTc0idnUyaNZ+nYm61+E2u
yauYhvvJTUH4MSPUhrkj+aCrdC2B+VAcJ/IAH08tPTXwWS+LsTG7FiY6wRZifSc2
x645I+z3jRHix9wdLU051930ISm+PlhxLmggLToTGhcZytuj8aJqAoqqQK8Bioah
lGpjgfT22+QZIGRQ4xAed13xNXmLyvPHhYd8wXyltOaxV0rMQ0LTf8TLcLC7Gza4
+8juLpvFxJu8IJWy2l/ejssigdfSR1AQg4OaCR3U6OeE4vHkVP+rZFSZGkF+Gqnb
ObugQ3sfCeNP9AHej7YBddCFDyLR4ctmNJ3+/j8t8rk9Dov2g1hqFgVzgz2K2cbm
TMp0O31zG9+nneOEZGr/
=EHfX
-----END PGP SIGNATURE-----

--=-gHgsaSec0iEKm4nDQu0r--

