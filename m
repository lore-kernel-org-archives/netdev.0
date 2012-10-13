From: Andrew Savchenko <bircoph@gmail.com>
Subject: Re: [BUG] Kernel recieves DNS reply, but doesn't deliver it to a
 waiting application
Date: Sat, 13 Oct 2012 16:36:39 +0400
Message-ID: <20121013163639.87abca00.bircoph@gmail.com>
References: <20121003232548.eb6b6b22.bircoph@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Sat__13_Oct_2012_16_36_39_+0400_KIVBw2HeiBEsa9cA"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:41168 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753390Ab2JMMgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Oct 2012 08:36:54 -0400
Received: by mail-la0-f46.google.com with SMTP id h6so2508401lag.19
        for <netdev@vger.kernel.org>; Sat, 13 Oct 2012 05:36:52 -0700 (PDT)
In-Reply-To: <20121003232548.eb6b6b22.bircoph@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Sat__13_Oct_2012_16_36_39_+0400_KIVBw2HeiBEsa9cA
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

On Wed, 3 Oct 2012 23:25:48 +0400 Andrew Savchenko wrote:
> I encountered a very weird bug: after a while of uptime kernel stops to d=
eliver
> DNS reply to applications. Tcpdump shows that correct reply is recieved, =
but=20
> strace shows inquiring application never recieves it and ends with timeou=
t,
> epoll_wait() always returns 0:
> a slice from: $ host kernel.org 8.8.8.8:
>=20
> sendmsg(20, {msg_name(16)=3D{sa_family=3DAF_INET, sin_port=3Dhtons(53),
> sin_addr=3Dinet_addr("8.8.8.8")}, msg_iov(1)=3D[{"\266\344\1\0\0\1\0\0\0\=
0\0\0\6k
> ernel\3org\0\0\1\0\1", 28}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D 2=
8           =20
> epoll_wait(3, {}, 64, 0)                =3D 0                            =
        =20
> epoll_wait(3, {}, 64, 4999)             =3D 0
>=20
> Though tcpdump shows a normal reply:
>=20
> 20:28:44.162897 IP 10.7.74.7.43167 > 8.8.8.8.domain: 46820+ A? kernel.org=
. (28)=20
> 20:28:44.221308 IP 8.8.8.8.domain > 10.7.74.7.43167: 46820 1/0/0 A 149.20=
.4.69
> (44)
>=20
> After this bug has occured, it is no longer possible to perform DNS reque=
st on
> the crippled system. I tried to stop/restart all network-related daemons,=
 to
> recreate network interfaces whenever possible (e.g. pppX devices), but wi=
th no
> help. I use iptables and ebtables on this host, but reseting them (flushi=
ng all
> chains, removing user chains, setting all policies to ACCEPT) doesn't hel=
p. The
> only worknig solution is to reboot the system.
>=20
> This bug happens rarely and randomly (about once in 7-12 days on 24x7 ava=
ilable
> production system), but I had it 5 times already. Due to rare and random =
nature
> of the bug I can't bisect it.
>=20
> This problem occured after I updated vanilla kernel from 2.6.39.4 to 3.4.=
6.
> Afterward I updated kernel to 3.4.10 in the hope that this will fix the
> problem, but with no result. (I updated kernel due to commit
> 2ce42ec4ef551b08d2e5d26775d838ac640f82ad, which describes somewhat similar
> issue, though I don't use I/OAT engine due to lack of hardware support.)
>=20
> More details, attached trace files and kernel configs are available at bu=
gzilla:
> https://bugzilla.kernel.org/show_bug.cgi?id=3D48081
>=20
> In a few days I'll try 3.4.12 (I need to rebuild kernel anyway due to unr=
elated
> issue) and will report if this bug will occur again. But please note it m=
ay
> take several weeks to check this.

I got this problem again with 3.4.12 kernel. System lasted less than
a week and reboot was the only option...

Best regards,
Andrew Savchenko

--Signature=_Sat__13_Oct_2012_16_36_39_+0400_KIVBw2HeiBEsa9cA
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iEYEARECAAYFAlB5YGEACgkQ2anJBBcsZw3VvgCgjgpx6Wwz6gn8Mr/XcSrF0eZD
THwAoKY1TRKm6y8DcAErxgXpLcDnS6Si
=o3eR
-----END PGP SIGNATURE-----

--Signature=_Sat__13_Oct_2012_16_36_39_+0400_KIVBw2HeiBEsa9cA--
