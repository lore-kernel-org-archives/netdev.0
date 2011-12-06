From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: `ip addr show' shows maximum of 56 addresses?
Date: Tue, 06 Dec 2011 03:48:56 +0000
Message-ID: <1323143336.7454.225.camel@deadeye>
References: <1323129923.2887.51.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-nxwRE0ZHtKWfQve7bjPm"
Cc: Ben Jencks <ben@bjencks.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:45427 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932879Ab1LFDtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 22:49:16 -0500
In-Reply-To: <1323129923.2887.51.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-nxwRE0ZHtKWfQve7bjPm
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Eric Dumazet wrote:
> Le lundi 05 d=C3=A9cembre 2011 =C3=A0 16:12 -0500, Ben Jencks a =C3=A9cri=
t :
> > I'm finding that ip addr show will only give me up to 56 addresses:
> >=20
> > $ ip -6 addr show lo
> > 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436=20
> >     inet6 ::1/128 scope host=20
> >        valid_lft forever preferred_lft forever
> > $ for i in `seq 55` ; do sudo ip addr del fd9a:704e:4d65:136d::`printf =
'%x\n' $i`/128 dev lo ; done
> > $ ip addr show lo | grep inet6 | wc -l
> > 56
> > $ ip addr show lo | grep ' ::1'
> >     inet6 ::1/128 scope host=20
> > $ sudo ip addr add fd9a:704e:4d65:136d::`printf '%x\n' 56`/128 dev lo
> > $ ip addr show lo | grep inet6 | wc -l
> > 56
> > $ ifconfig lo | grep inet6 | wc -l
> > 57
> > $ ip addr show lo | grep ' ::1'
> > <no output>
> >=20
> > It doesn't even help to specify the address explicitly:
> >=20
> > $ ip addr show dev lo to ::1
> > <no output>
> >=20
> > (Ubuntu kernel 2.6.32, tested with both distributed and latest git ipro=
ute2)
> >=20
> > I searched for this issue, and even looked in the iproute2/ip/ipaddress=
.c and couldn't find any explicit limits. Is there a maximum netlink messag=
e size causing problems?
> >=20
> > Sorry if this question is too user-ish for a dev list, but both linux-n=
et and lartc looked dead.
> >=20
> > Thanks,
> > -Ben--
>=20
> This was fixed two years ago by commit bcd323262a94b14b in 2.6.33
> (ipv6: Allow inet6_dump_addr() to handle more than 64 addresses)

Seems like a candidate for 2.6.32.y.  I don't think it depends on any of
your other changes for 2.6.33, does it?

Ben.

--=20
Ben Hutchings
Absolutum obsoletum. (If it works, it's out of date.) - Stafford Beer

--=-nxwRE0ZHtKWfQve7bjPm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATt2QqOe/yOyVhhEJAQrRRw/+McKuThwXoNE0hOQbGVwUXQV64k0HeP9Y
ApazD2IUkSFGL0XC37SeLh4H0ngXcsTp+X+LdXJvmTmPzrsGnVAk46wzYaElTaD6
lATqVVa2yXY9dqRg+yuNmsQFq4RcEXsedHrM6FrCq9T9A4fFBrQO0s8LCdZVO+3e
zILOZwkwJxwjsq7mJfsJftF/fP0IeeMIMM1DbGUyAS1i8mJKvcASuxCiQKYfGITB
PAZFB/0kA/W1AYETqX6jaxCd9VWDxZzHnQMotbnJjHoI6sd8XZqEr9GAC9G7ouZx
3KPypYa7lhCPIMAvmVSHy/b65+ffxq/3zThVQMU1b302CAG/hj6jp358aQrvPXmz
+Z3TemKnH6QSnD3CnfJ/zfR3wgUzMsr0XxrxUoV6yDrE9AOYOHH/PqXCzkwsV8X+
oQG2rHuurXUbwPkD9HdCpNpNcos4hjbuC3FFNCyDlP2xJqSAATWShTPXMrg9rPc+
QOmIio9KWyNLgI5waeuV52bB8M7AFx5YURTMztFJCnHKu/Mnm+o3y8ZCXzwVvUfP
LwBU6y2AJWRBBRl0/UVaJka64btf5T1/uEk8hmL+Zo7A8Ntu83ZUjhIqcgCVaS94
tvnqFQ04HBSr/rT72ntkQvOt7dOjMbmNc+k1sR6TGnN2wfly7KxwEWQ92X+NfCnn
8/FmSV9w/wI=
=9Nvk
-----END PGP SIGNATURE-----

--=-nxwRE0ZHtKWfQve7bjPm--
