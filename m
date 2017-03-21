From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: PROBLEM: null-ptr deref in ip_options_echo may lead to denial
 of service
Date: Tue, 21 Mar 2017 00:36:01 +0000
Message-ID: <1490056561.4770.7.camel@decadent.org.uk>
References: <CAC9A2PqFcJ2k5Nm8QyxbOrO6rQnfHxcPvsnkzPMGUuJ5hCXM1Q@mail.gmail.com>
         <1489987500.16816.19.camel@edumazet-glaptop3.roam.corp.google.com>
         <1490056423.4770.6.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-V9/ujm+Fi+ixlgAp682G"
Cc: davem@davemloft.net, security@kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Anarcheuz Fritz <anarcheuz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:37671 "EHLO
        shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754691AbdCUAgQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 20:36:16 -0400
In-Reply-To: <1490056423.4770.6.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-V9/ujm+Fi+ixlgAp682G
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2017-03-21 at 00:33 +0000, Ben Hutchings wrote:
> On Sun, 2017-03-19 at 22:25 -0700, Eric Dumazet wrote:
> > On Mon, 2017-03-20 at 12:59 +0800, Anarcheuz Fritz wrote:
> > > Hi David,
> > >=20
> > >=20
> > > While working on some legacy kernel I stumbled upon a null-ptr deref =
in
> > > ip_options_echo. The bug has been verified on the latest version
> > > 3.2.87 from the supported long-term branch.
> > >=20
> >=20
> > Fixed in commit 34b2cef20f19c87999fff3da4071e66937db9644
> > ("ipv4: keep skb->dst around in presence of IP options")
> >=20
> > For 3.2, since d826eb14ecef was not backported, following patch should
> > do it.
> >=20
> > (Bug origin was f84af32cbca70 ("net: ip_queue_rcv_skb() helper"))
>=20
> I see, I thought the vulnerability was introduced by d826eb14ecef.
>=20
> > diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
> > index b3648bbef0da..a6e1eeb02267 100644
> > --- a/net/ipv4/ip_sockglue.c
> > +++ b/net/ipv4/ip_sockglue.c
> > @@ -1009,7 +1009,8 @@ e_inval:
> > =C2=A0 */
> > =C2=A0int ip_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
> > =C2=A0{
> > -	if (!(inet_sk(sk)->cmsg_flags & IP_CMSG_PKTINFO))
> > +	if (!(inet_sk(sk)->cmsg_flags & IP_CMSG_PKTINFO) &&
> > +	=C2=A0=C2=A0=C2=A0=C2=A0!IPCB(skb)->opt.optlen)
> > =C2=A0		skb_dst_drop(skb);
> > =C2=A0	return sock_queue_rcv_skb(sk, skb);
> > =C2=A0}
>=20
> Thanks to both of you; I'll queue this up for 3.2.

Actually, could I have a Signed-off-by for this, Eric?

Ben.

--=20
Ben Hutchings
Power corrupts.=C2=A0=C2=A0Absolute power is kind of neat.
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0- John Lehman, Secretary of the US Navy
1981-1987


--=-V9/ujm+Fi+ixlgAp682G
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEErCspvTSmr92z9o8157/I7JWGEQkFAljQdXEACgkQ57/I7JWG
EQm3Gg/7BXl+jUm4QkC9jUvGuhyrWYsbLyjnsAV0lUPFcCevETD7Mtrjix8wNKOo
dG6nUO0f8synHFYPQklU+80muq3Wvpb1cGhZP00VfaYqp4e2uAEUtY7wkeNe9c68
MROzIP7i8MBDcVzH+9F6qp541ibTDxauw4ZD2WCy/2rqeW/a/JQCgte4tXHvZV0d
ZbtLmDaS2qIB3SiOlkRHXENo/i4ArIjy/EsV3S7sutw5CYqOU2YKUC6IgkMpP1Yy
wb+Z9KbTPYZ8fkqUdjos79isGW+T07aLntfVatDOXFWqAQYYAMaw1/Nvunxi//Sl
+hBecwOKUb0xxe34RNo2XwmgqUTXh5vQeUpwyFFfRbg8U4gpcvPchEH3zhpsJdg5
+CNfksjJJjnIi+gYDV2Audzf1v/Svx48pcyoL6yhjGL5Ta9M0PIxud6zCpLyN6/x
fs8HKUAwr9jxfhn30SZXL4PZIKxXd3jeOXzgr9vfiTgAPhNneo8Bzh/1VDq+wPhp
MFe1WsYFEPVzuuUUIPXZwsx0Q5/tkrmCuq1Bw3JFjn/r7b1Q7zc9UIP0mNz/2ZdK
rh0QI2yt+5aWor7QLy8aS9ulPMgsZK99nH3zmKcMO9X9lMLai1W/OS/F+YlqD+cz
S9izf0QFJkjPiSfSpd3ggqO2+g/gpq4Ou/1RrRGWL7wi/fBCIHQ=
=O/3h
-----END PGP SIGNATURE-----

--=-V9/ujm+Fi+ixlgAp682G--
