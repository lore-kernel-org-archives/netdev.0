From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Fw: [Bug 79891] New: Router causes TCP retransmits for windows
 hosts after "ip_forward: fix inverted local_df test"
Date: Fri, 11 Jul 2014 20:01:12 +0100
Message-ID: <1405105272.26540.88.camel@deadeye.wl.decadent.org.uk>
References: <20140710064433.1fd17105@samsung-9>
	 <CAHA+R7N0ZgLfZNMrnHyRD+C=rGD86QXVkE0weLOLCM9npXMozg@mail.gmail.com>
	 <1405102310.26540.83.camel@deadeye.wl.decadent.org.uk>
	 <CAHA+R7PDJ42Y1Wovtw=dzN-JqQjcamPtDPSmS_SyUK95JNp_aA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-2bGbxQY6Ojw4qLEzjwj/"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	stable <stable@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <CAHA+R7PDJ42Y1Wovtw=dzN-JqQjcamPtDPSmS_SyUK95JNp_aA@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-2bGbxQY6Ojw4qLEzjwj/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-07-11 at 11:38 -0700, Cong Wang wrote:
> On Fri, Jul 11, 2014 at 11:11 AM, Ben Hutchings <ben@decadent.org.uk> wro=
te:
> > On Thu, 2014-07-10 at 10:11 -0700, Cong Wang wrote:
> >> On Thu, Jul 10, 2014 at 6:44 AM, Stephen Hemminger
> >> <stephen@networkplumber.org> wrote:
> >> >
> >> > After upgrading a router to Linux 3.2.60 most windows machines behin=
d it
> >> > started experiencing connection stalls. Downgrade to 3.2.59 resolved=
 the
> >> > problem. Using git bisect I pinpointed it to
> >> > "59d9f389df3cdf72833d5ee17c3fe959b6bdc792 is the first bad commit", =
which
> >> > entered the kernel from here
> >> > http://marc.info/?l=3Dlinux-netdev&m=3D139949081418806&w=3D2
> >> >
> >>
> >> This commit should have been reverted for older kernels like 3.2.y.
> >
> > Really?  We already had fe6cc55f3a9 ("net: ip, ipv6: handle gso skbs in
> > forwarding path") backported in 3.2.57.
>=20
> I haven't read the code, but according to a previous discussion it sounds
> like that should be reverted:
>=20
> http://lists.openwall.net/netdev/2014/06/11/67

My reading of that is we need 895162b1101b ("netfilter: ipv4: defrag:
set local_df flag on defragmented skb") in 3.2.y and 3.4.y.  But there
seem to be many other places that local_df should be set, that have only
recently been fixed.  So maybe reverting is the safer option.

Ben.

--=20
Ben Hutchings
To err is human; to really foul things up requires a computer.

--=-2bGbxQY6Ojw4qLEzjwj/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAU8A0fee/yOyVhhEJAQpRShAAzPBhfT4PaSLt/0dRF4X4K0pMXpEAmvXJ
R1sN8ujpDP3jPA2t3wWPi1Mbyibxt4N8nHrdxsemAlDzCe6dbSMX2ywWT3MAwME7
/tChaIj/ROwt+bY64Pdux2Elwi9Qn/w24I8XsQN+LsybHd+P3F76TxMdhtYe+T2S
QNLSNuu6HPNxjKXU6AAD/VaIgtNFBGZOys6FqtB5uPCh7rLBt8qDkc1L487aQCz/
GSxdul2L30x+CRINpkyd1wqsH1ut94iocwStx9PLnJgjU9c3otU/4Em0vq4nbOSW
6cmBFORy0qVWY9ZaDa4Uk4kwQ1snbhY6ptlGV+GMpAC6NZXB9QLwz15J8TnId/NP
7j/2k6HujLS+uSzUx5PB6wmdxQz86ypFujAZVZHbbs9y9GVnmcMX2SgtswTHdouX
/5nqczLJZ8AOPpQ+fEPo6+OQBJHZAsNnk+wYACYzUyMcdLKqHFOMuNmQ2TMeGLc8
2RKsw8K0blfpks6Frons+G5I+7aJhSOoMOSx6ht3w789M/oHipY9sHwaLcrVKm1m
/Thxqyep28YD8+5+4ltgrvliMUHtggXOo6zRb9MSagNB0sWtmdPNuqMJlWKOQkfs
Y2z+GdoOeS1ws7auBMIdq5aiuG7Rp5UtVW97QnMvVL1fXNFMDaFjooiuqr7s2Qla
cG1TDsDwt7w=
=Gt4k
-----END PGP SIGNATURE-----

--=-2bGbxQY6Ojw4qLEzjwj/--
