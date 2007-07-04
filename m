From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: multicasting netlink messages to groups > 31 from userspace
Date: Wed, 04 Jul 2007 15:54:01 +0200
Message-ID: <1183557241.3812.20.camel@johannes.berg>
References: <1183492286.4021.21.camel@johannes.berg>
	 <20070704120440.GB6336@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-fcUshrrADsj0W0XD1J1P"
Cc: netdev <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Patrick McHardy <kaber@trash.net>, Thomas Graf <tgraf@suug.ch>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:36794 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759192AbXGDNxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2007 09:53:09 -0400
In-Reply-To: <20070704120440.GB6336@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-fcUshrrADsj0W0XD1J1P
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-07-04 at 16:04 +0400, Evgeniy Polyakov wrote:
> On Tue, Jul 03, 2007 at 09:51:25PM +0200, Johannes Berg (johannes@sipsolu=
tions.net) wrote:
> > Does anybody have any better ideas?

> Why don't you want to reserve a set of bits in group number, which means=20
> 'allow to work with unpriveledged users', that bits should not cross exis=
ting=20
> users (hardcoded in various files in kernel), all new code can use that
> groups.

Uh wait, we're confusing two issues here. This idea actually makes good
sense, although it'd have to be two bits (allow unpriv users to recv,
allow unpriv users to send), limiting the groups to 2^30-1. Fine with
me.

However, the actual issue I wanted to address with this mail is that we
cannot have userspace send to groups > 32. However, your idea above can
equally well apply here; we could say some bit in the nl_groups field is
reserved and that if that bit is set the other bits form the group
number to send to instead of a bitfield where the highest group is sent
to. That should work fine, both limits the number of available groups to
2^30 respectively 2^31 but that's not an issue.

The thing with actually trying to fix this issue now is that when we
have generic netlink and multicast group registrations, we'll have
userspace programs sending to a multicast group using nl_groups =3D
(1<<group.id) and then group.id grows > 32 if a whole bunch of other
groups were registered before, and it all messes up. Hence we actually
have to address this issue well before userspace starts using the
generic netlink multicast API.

johannes

--=-fcUshrrADsj0W0XD1J1P
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGi6Z4/ETPhpq3jKURAk4rAJ9pOQFmvB1rXRUvtMz9WwfcMbAECQCeL7R0
yffjoksqGPwtMdLT/WvnrW4=
=GgPz
-----END PGP SIGNATURE-----

--=-fcUshrrADsj0W0XD1J1P--

