From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Drivers: net: Hyperv
Date: Tue, 22 Apr 2014 19:21:36 +0100
Message-ID: <1398190896.7767.91.camel@deadeye.wl.decadent.org.uk>
References: <1398190933-8990-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-QAOqHhuXmQV+l580OZDb"
Cc: davem@davemloft.net, netdev@vger.kernel.org, olaf@aepfle.de,
	jasowang@redhat.com
To: "K. Y. Srinivasan" <kys@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53963 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751261AbaDVSVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 14:21:49 -0400
In-Reply-To: <1398190933-8990-1-git-send-email-kys@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-QAOqHhuXmQV+l580OZDb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-04-22 at 11:22 -0700, K. Y. Srinivasan wrote:
> I am trying to port the various offloads (checksum, TSO etc.) that I rece=
ntly=20
> implemented for the Hyper-V network driver to a 2.6.32 kernel and while t=
his
> code works on the upstream bits, TCP checksum offload does not seem to wo=
rk
> on the 2.6.32 kernel. Would you know if there is a different way to turn =
on
> checksum offload on 2.6.32 kernels?  I am setting the relevant feature fl=
ags:
>=20
>=20
>         net->features =3D  NETIF_F_SG | NETIF_F_RXCSUM |
>                         NETIF_F_IP_CSUM | NETIF_F_TSO;

There is no NETIF_F_RXCSUM in 2.6.32, but otherwise this should work.

I notice that NETIF_F_HIGHDMA is not there, and it seems like you could
add it as netvsc_start_xmit() doesn't assume page fragments are in
lowmem.

> What I am observing is that when the skb is presented to the driver for t=
ransmission,
> The ip_summed field in the skb is set to 0.

Maybe you tested on a 32-bit system and the packet had to be copied to
lowmem?  The allocation behaviour may have changed since 2.6.32.

> On the kernel tip, I see this value set to CHECKSUM_PARTIAL and the offlo=
ads
> work correctly on the kernel tip. The other difference I see is that on e=
ntry into the driver,
> the eth_hdr state is not correctly set in the skb.
> I need to invoke skb_reset_mac_header() to get this state correctly set.
> Any help would be greatly appreciated.

I don't recall that problem.

Ben.

--=20
Ben Hutchings
Beware of programmers who carry screwdrivers. - Leonard Brandwein

--=-QAOqHhuXmQV+l580OZDb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU1azMOe/yOyVhhEJAQq0Jg/9HrVMXOL7IZpNKiIdz0UTqG7f9DTpU9hX
DooHhRinf6r7+EnpX+dZVqh0M/he1qrCCqLJtxKB5PMZgPvPH3JnvP+h7m6w4wf/
gFCR4xkWVmbo2qoRFio0jYGvBJdNK8XoU0ugRpogSQ+hPSqhyp/t7pDGUNzSOt/H
IaWUl55hPpTyhOOYkrjcfr+hVtiVM/CXD5LU+5C+m/mU4+2JbaZsmDO/fXZ0KU53
Xm3NkdvX5qFTrv2MLDdGQr5UdDtDBfdj1PTO28W4BAqfoXdoCy1RWXRjO1QrlZTO
7hpC/y1eAm+paKB9XGMaqGyLCX2KZuheBTUKrV7bWzCfv6/sypgFnCpoaaFq22pA
WxnkJ/PE3by4nWNjqcKpEP0osbwfS8MZY1LzQ7Xo840YssfSjQkNOp7we7HgN3V1
KHXgl2tXJVR4qXTG/YsUDfONzLKoVQ/1aq6Lrz9df9p1+y72rZQqsmu35OtCBiby
mo6qPttK5XzoSngaj+EBXraqYKUU/6IV78ApGws8t4sZnTyB+iBu7NVMGoyX8C5J
PDH0+dnlL56bZOH6tfn173+nyUOmJSfF8VIKRn5suOsJYHAjRPGHfSjghVQqrWno
WbgZCDm0brQ2yVEfQztLzsmkekGlqe70r3xX0xclRTOJ5NeKr1QFBkRWwTc7/mrK
W5+odBTHXnQ=
=qpcK
-----END PGP SIGNATURE-----

--=-QAOqHhuXmQV+l580OZDb--
