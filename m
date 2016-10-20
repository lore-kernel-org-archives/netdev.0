From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [PATCH 1/9] ipv6: implement dataplane support for rthdr type
 4 (Segment Routing Header)
Date: Thu, 20 Oct 2016 15:04:59 +0200
Message-ID: <5808C0FB.2050202@uclouvain.be>
References: <1476715350-18983-1-git-send-email-david.lebrun@uclouvain.be> <1476715350-18983-2-git-send-email-david.lebrun@uclouvain.be> <CALx6S35sU+aw3UvMTknj8SjJP4O=Q-9eVV3OC640Qzces_eE7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="kiHK4HScUDNvNv8mXg3Sl4IxwS7NXhvLn"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:37295 "EHLO
        smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932543AbcJTND3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 09:03:29 -0400
In-Reply-To: <CALx6S35sU+aw3UvMTknj8SjJP4O=Q-9eVV3OC640Qzces_eE7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--kiHK4HScUDNvNv8mXg3Sl4IxwS7NXhvLn
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 10/17/2016 07:01 PM, Tom Herbert wrote:
>> > +
>> > +       if (skb->ip_summed =3D=3D CHECKSUM_COMPLETE)
>> > +               skb->ip_summed =3D CHECKSUM_NONE;
>> > +
> Because the packet is being changed? Would it make sense to update the
> checksum complete value based on the changes being made. Consider the
> case that the next hop is local to the host (someone may try to
> implement network virtualization this way).
>=20

Rethinking about that: even if the next hop is local, I am not sure to
see the benefits of updating the checksum instead of setting
CHECKSUM_NONE. For example, if the next and final hop is local and the
packet carries a TCP payload, tcp_checksum_complete() would force the
recomputation of the checksum anyway (unless ip_summed =3D=3D
CHECKSUM_UNNECESSARY).

So I fail to see a path where updating the checksum would be beneficial.

Am I missing something ?

David


--kiHK4HScUDNvNv8mXg3Sl4IxwS7NXhvLn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iEYEARECAAYFAlgIwPsACgkQjbzn67sZ6ANQCQCeMJ88JkRJmC5dXZ1ixcT60i2W
jOwAnAgjWoRs/K1GvYgFDJuPiGyVWtd+
=PVyR
-----END PGP SIGNATURE-----

--kiHK4HScUDNvNv8mXg3Sl4IxwS7NXhvLn--
