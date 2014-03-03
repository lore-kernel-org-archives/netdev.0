From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@web.de>
Subject: Re: bridge is not forwaring ICMP6 neighbor solicitation to KVM guest
Date: Mon, 3 Mar 2014 22:27:59 +0100
Message-ID: <20140303212759.GW5090@Linus-Debian>
References: <1566805413.12693479.1393872931017.JavaMail.zimbra@redhat.com>
 <2107636851.12713862.1393876035292.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="kaF1vgn83Aa7CiXN"
Cc: netdev@vger.kernel.org, Florian Westphal <fwestpha@redhat.com>,
	bridge@lists.linux-foundation.org
To: Jan Stancek <jstancek@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.11]:64274 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755021AbaCCV2H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2014 16:28:07 -0500
Content-Disposition: inline
In-Reply-To: <2107636851.12713862.1393876035292.JavaMail.zimbra@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--kaF1vgn83Aa7CiXN
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Jan,

On Mon, Mar 03, 2014 at 02:47:15PM -0500, Jan Stancek wrote:
> I'm seeing an issue where bridge (sometimes) stops forwarding ICMP6
> neighbor solicitation packets to KVM guest and as result KVM guest doesn't
> respond with neighbor advertisement.

Hm, okay, that's not supposed to happen.

> The reason I think this packet is related is because when I send same exa=
ct
> packet I'm often hitting same issue - bridge stops forwarding ICMP6 neigh.
> solicitation packets to KVM guest.

Yes, the MLD query is kicking the multicast snooping into gear. If
there's never a query, then snooping is basically disabled
(compare: "bridge: disable snooping if there is no querier").

>=20
> My current way to reproduce this is:
> 0. host B IP / MAC is: 2620:52:0:1040:221:5aff:fe47:931c / 00:21:5a:47:93=
:1c
>    guest IP / MAC is: 2620:52:0:1040:5056:ff:fe00:29 / 52:56:00:00:00:29
> 1. host B is sending neigh solicit packets every 5 seconds with KVM guest=
 IP
>    using ns6 from ipv6toolkit: http://www.si6networks.com/tools/ipv6toolk=
it/
>    with parameters:
>    --src-address=3D2620:52:0:1040:221:5aff:fe47:931c --dst-address=3Dff02=
::1:ff00:0029
>    -t 2620:52:0:1040:5056:ff:fe00:29 --link-src-address=3D00:21:5a:47:93:=
1c
>    --source-lla-opt=3D00:21:5a:47:93:1c --link-dst-address=3D33:33:ff:00:=
00:29
>    tcpdump running on guest can see both solicit and advertisement packets
> 2. wait ~5 minutes
> 3. host B sends Multicast Listener Query packet described above
> 4. tcpdump running on guest is no longer seeing any neigh solicit packets

Just to clarify, host B is behind eno1 and vnet0 is directly
connected to the interface of the guest, no additional bridge or
anything else on top of that, right?

Would it be possible for you to upload the tcpdumps from host B
(or if you can't tcpdump on host B, then capturing on eno1)
and the guest somewhere and saying at which time/packet in the dumps
it stops working (probably ~10 seconds after the query). Filtering
for ICMPv6 should be sufficient.=20

What I'm curious about is, whether the guest receives
the MLD query and responds with an MLD report. I suspect that
either the bridge doesn't get an MLD report and therefore is
shutting down the according port or there's a bug in parsing the
MLD report in the bridge code.


Thanks for the detailed report so far!

Cheers, Linus

--kaF1vgn83Aa7CiXN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTFPPdAAoJELxyPiAAt6Uvk5QQAJ4a0v3U9RgzOFfOqN1xH6NS
VsjoXyu+Sy68erBCvz0f/8mGW5jwSgOzbvR6HH36GYbWs5QaDsxBWz+nkWPKKzkf
kkHZCzGIWUhhKIjliPz0PPj8JCOpjSLv4GDPogYe3NITYPy05We06iYdPHhNpjW2
PkBCQCvWw2Qqc7Aqjhk3mJn3gNO6AthftHHypE5fv55/iTuBUt/VswS16ZHDHBBz
k68axskRX6lhuOsZ7kNgFrLnIU+aTYIKCitcbY//3zJ/wkanYgT+gLWLimFDRVPm
eSgN9OusPaIisDBWBGcHNJUQrLfeRAMPXqKNvLJdjilXYhVsdKNk8z/k/TRQiMUK
NKVO1KhP7xSpWTf4KxgWevz5aUSWz+/LzbKUhw+GcMEuQdXneOOei2lEf+t1osqU
21To72ynxQqs9OitYcNEXZmVzlBl+okrOv80S1hdDVc0nmSwVDHxkBmkAs/KV9h7
P1YdlDpjRUDIWNQ9hPjO380c/dXnqlvdVb/lK3ViQxQ6P8SKL8XTSA2mOYBCnUtw
g5TL+DU6RySzw85djZ+RydbzHYREBwVOlm16CsX/OqXtgH4oVfENGFtrOoWazvnd
IZQwU649uY42oY6w3ybDeLNj+xWCq/9jnDDHydnQGLeI60y/CclTY2ogL+Hy6g8+
+6D54DV2yNp/3RWAFfxg
=N/Jw
-----END PGP SIGNATURE-----

--kaF1vgn83Aa7CiXN--
