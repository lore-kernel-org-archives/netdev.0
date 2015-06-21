From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: Re: [PATCH] ipv6: Fixed source specific default route handling.
Date: Mon, 22 Jun 2015 00:35:50 +0200
Message-ID: <55873C46.4090804@universe-factory.net>
References: <7922B483-7EA7-4B50-BF1C-7681EB7CC454@iki.fi>
 <5586F1F8.1070800@universe-factory.net>
 <0D0CB420-018B-465C-B27B-72016F41C268@iki.fi>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="asRLSOsrM5nLgh7RNL2xHhOSlJajwH5AR"
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Steven Barth <steven@midlink.org>
To: Markus Stenberg <markus.stenberg@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chaos.universe-factory.net ([37.72.148.22]:49110 "EHLO
	chaos.universe-factory.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752248AbbFUWfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 18:35:54 -0400
In-Reply-To: <0D0CB420-018B-465C-B27B-72016F41C268@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--asRLSOsrM5nLgh7RNL2xHhOSlJajwH5AR
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 06/22/2015 12:05 AM, Markus Stenberg wrote:
> Prefsrc is essentially historic non IPv6 construct. IPv6 SAS is based o=
n dst, src, metric ordered lookup just like the routing is too ( lookup r=
fc, some src specific routing drafts for details ).=20
>=20
> Therefore I do not see a problem. If you want specific SA, add same rou=
te with higher metric and/or (more) specific src match.=20
>=20
> There might be bugs there tho, but that is how it should work. As SAS i=
s supposed to happen before routing ( see rfc ) the prefsrc is .. Cough.
>=20
> -Markus
>=20

Could you explain in detail what you mean with "If you want specific SA,
add same route with higher metric and/or (more) specific src match."?
Routes aren't bound to specific addresses except via the "src" attribute
(which is called prefsrc in the kernel), which is exactly what it not
working. I can't control the chosen source address at all when
source-specific routes are involved.

Also, metric-based route selection is broken when source-specific routes
are involved. The commands mentioned in my first mail will create the
following configuration:

# ip a
3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state
UNKNOWN group default qlen 500
    link/ether 22:46:f4:9c:9e:3a brd ff:ff:ff:ff:ff:ff
    inet6 fd00::20/64 scope global
       valid_lft forever preferred_lft forever
    inet6 fe80::2046:f4ff:fe9c:9e3a/64 scope link
       valid_lft forever preferred_lft forever
4: test@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue
state UNKNOWN group default
    link/ether ae:2b:02:16:23:0f brd ff:ff:ff:ff:ff:ff
    inet6 fd00::1/128 scope global
       valid_lft forever preferred_lft forever
    inet6 fe80::ac2b:2ff:fe16:230f/64 scope link
       valid_lft forever preferred_lft forever

# ip -6 r
fd00::/64 from fd00::/64 dev eth0 metric 1024
fd00::1 dev test proto kernel metric 256
fd00::/64 dev eth0 proto kernel metric 256

The only route I have added manually is the source-specific one, the
other two have been created by address assignment. Adding a "src"
address to the source-specific route has no effect.

Even though the source-specific route has a higher metric than the
generic one, the source-specific one shadows the generic route.

Thanks for your reply,
Matthias


--asRLSOsrM5nLgh7RNL2xHhOSlJajwH5AR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJVhzxGAAoJEBbvP2TLIB2clkAQAKrJQtJoMvVPbtNbIjct3/fR
tbUDbpdv8HuZKHGZFmbN9RP6gOg5LIb47FE75+2o55rOwp5fLOej3CEbglkI9Kfh
89ovhw2ut16rEp5aoI50YPc8DffAnL0wIkY3LFpZ4uUkc+D/OAL7V5x5vgJXRitn
hMhgm1v5qIZTghlLEXL53E9lfmOo4AazCz1qSsVZa3kl9YKMRgfHQMUNj1FccZUv
pZ7Slx/7WBVY0NtSzot1/Bo2h7M+rImdZURgC9tAcKK+f0Y4gZpNzQ4wIl5rnkm+
1xF2fisHZ96Um0+CowX5NMUdGbB1xA1pg1Qhn/mDqGd4jcsMVxkF714mLfiYmp6U
cNbjkB5BjqB6WSL+CNCTyW47k5gz4ZnNZcrVKhW70ffAV4Tk7lvT0uAOL967QXbD
AWjMhyxBmgsHmH5Buwh37jevZ491ih9C7mtW1OwAduHEI/8bTAA8Hy2a+2ppjQRP
MBjgJoztjKxwD9/qpF9xE7Fnv+1NDHyur+0X/5uOaAO2y+9yYxFGPtrwz8bT6Ast
iSqA1BJY0iQc2+F4fNo7DCEBUUvcGCQGPOwLyVHBxB/rhAv80R2S8YlaFKNBz6tE
KKgiE+mbd93/x0towZWjnSpDPKJ8TSdsdy+JAzniRvd+Y/OSUOduOrZMYfBTbCQC
u+7ozG9QztabpbWYtIRI
=W1J7
-----END PGP SIGNATURE-----

--asRLSOsrM5nLgh7RNL2xHhOSlJajwH5AR--
