From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: TX timestamping for ICMP (sfc and core)?
Date: Sun, 09 Mar 2014 17:07:37 +0000
Message-ID: <1394384857.2861.159.camel@deadeye.wl.decadent.org.uk>
References: <CALCETrXpaD4i9V2Qv_0xfouGRb_y27-R6fOQ5v4Q97jNwgecFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-g9qxSDIHJ+Vir2m0VS3H"
Cc: Network Development <netdev@vger.kernel.org>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50975 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751307AbaCIRHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 13:07:45 -0400
In-Reply-To: <CALCETrXpaD4i9V2Qv_0xfouGRb_y27-R6fOQ5v4Q97jNwgecFA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-g9qxSDIHJ+Vir2m0VS3H
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-03-04 at 12:43 -0800, Andy Lutomirski wrote:
> I'm trying to get tx timestamping working on ping sockets.  My program
> works fine (with hardware TX timestamps) if I send my "pings" on the
> PTP UDP ports.  I want to send real ICMP pings, though.
>=20
> It looks like there are two problems:
>=20
>  - Something in the core code seems to eat SKBTX_HW_STAMP on ping
> sockets.  At least, this code in efx_hard_start_xmit triggers for
> IPPROTO_UDP on PTP ports but not for IPPROTO_ICMP:
>=20
>         if (unlikely(efx_xmit_with_hwtstamp(skb)))
>                 printk(KERN_DEBUG "sfc: trying to do a TX timestamp\n");
>
>  - The sfc driver refuses to timestamp non-PTP packets.  There's a
> check in efx_hard_start_xmit and another in ptp.c.  I suspect that the
> hardware can support timestamping any outgoing packet, but I'm not
> really sure.  (I'm using an SFN7322F.)

I think that the SFC9100 family can do TX timestamping for arbitrary
packets, but they still have to be sent via the MC and that will greatly
limit the packet rate.

(It may or may not be possible on the SFN[56]322F, as the addition of
timestamping in a peripheral to the SFC9020 is quite a delicate
arrangement.  The MCDI transport there also limits TX timestamped
packets to 252 bytes.)

If you want to send more than a very low rate of packets with TX
timestamping, the driver should probably tell the kernel to allocate an
extra TX queue for them and should implement ndo_select_queue.

Ben.

--=20
Ben Hutchings
I say we take off; nuke the site from orbit.  It's the only way to be sure.

--=-g9qxSDIHJ+Vir2m0VS3H
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUxyf2ee/yOyVhhEJAQp39Q/9Gsooy7N+UbrnIjIHzitjia2lTCLW7N9a
tqxCR13fYtq8/3fdBBYICEfpsu1N0b0DvgwP6dORnEdoLTuJdmVgc7cvXKkQo+7h
/KdSrrK6TRgur2ia4jahtdCGJGDsX3z4SVACi3DGa69u2/P6W7C3C2FsfG4wNLUl
LOj2NQTEGPwlOHsnA5A70qAMm7DVpJ6jJjOn8c0CpW/mrby4pRzM0YAYDI5z4Kv+
BcG11BGHtSrkGjMWkEtOnH61hKTGG5YRJNwGUVmSlK8ludMOiMYAjSPqHim3vdtj
r4HpjToxhEThiPXGK4+G2bSvjXz3rF53NBVS87dU1tu0w3eGK6RBvDfMYIBHhmKJ
oC+vvERhBKjJ39AfQxGn2DHB/KNjMNuCRCiK5RU4CarZYjWiX/m53q8sdzFwLzvl
uGKPujg9/cmzS3gIU3gMB9P+UZC7nYhyoF1X9xnSPbIoenaIFcVaD3CbF6Eyov/L
2MARgbxgBoiyroshGJKJXhzXH0wwdMzuRg4hq+jtuEnj5NRThLqUuOcqradxVyZT
jI0jBbtbRIqM2lW5hPNi+2/MZLGYsKOrpMwK4rk1I5WeTnAeVGfSBmnfbAmnIqqD
K/jW9E9iHBE0UZ10brfiuwXwduMEaKdqfJhmtT6myHu1vnnz7fsJt+guJOZdTsiS
+/pV4Ck3U6E=
=DkVA
-----END PGP SIGNATURE-----

--=-g9qxSDIHJ+Vir2m0VS3H--
