From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [PATCH 1/9] ipv6: implement dataplane support for rthdr type
 4 (Segment Routing Header)
Date: Tue, 18 Oct 2016 13:43:03 +0200
Message-ID: <58060AC7.1010501@uclouvain.be>
References: <1476715350-18983-1-git-send-email-david.lebrun@uclouvain.be> <1476715350-18983-2-git-send-email-david.lebrun@uclouvain.be> <CALx6S35sU+aw3UvMTknj8SjJP4O=Q-9eVV3OC640Qzces_eE7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="oXOj4Hqg9T4Otg2qWJWWLLaKxpPS0x9XT"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:48662 "EHLO
        smtp2.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753558AbcJRLld (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 07:41:33 -0400
In-Reply-To: <CALx6S35sU+aw3UvMTknj8SjJP4O=Q-9eVV3OC640Qzces_eE7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--oXOj4Hqg9T4Otg2qWJWWLLaKxpPS0x9XT
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 10/17/2016 07:01 PM, Tom Herbert wrote:
>> +struct ipv6_sr_hdr {
>> +       __u8    nexthdr;
>> +       __u8    hdrlen;
>> +       __u8    type;
>> +       __u8    segments_left;
>> +       __u8    first_segment;
>> +       __be16  flags;
>=20
> Bad alignment for 16 bit field could be unpleasant on some
> architectures. Might be better to split this into to u8's, defined
> flags are only in first eight bits anyway.
>=20

Will do

>> +config IPV6_SEG6
>> +       bool "IPv6: Segment Routing support"
>> +       depends on IPV6
>> +       select CRYPTO_HMAC
>> +       select CRYPTO_SHA1
>> +       select CRYPTO_SHA256
>> +       ---help---
>> +         Experimental support for IPv6 Segment Routing dataplane as d=
efined
>=20
> I don't think calling this experimental is relevant.

OK

>> +       if (skb->ip_summed =3D=3D CHECKSUM_COMPLETE)
>> +               skb->ip_summed =3D CHECKSUM_NONE;
>> +
> Because the packet is being changed? Would it make sense to update the
> checksum complete value based on the changes being made. Consider the
> case that the next hop is local to the host (someone may try to
> implement network virtualization this way).
>=20

Seems to make sense, I will try your suggestion

>>
>> +#ifdef CONFIG_IPV6_SEG6
>> +       /* segment routing */
>> +       if (hdr->type =3D=3D IPV6_SRCRT_TYPE_4)
>> +               return ipv6_srh_rcv(skb);
>> +#endif
>=20
> This doesn't belong in one of the switch statements in ipv6_rthdr_rcv?
>=20

=46rom what I see, ipv6_rthdr_rcv was initially implemented to support
RH0, and then specific code was added at multiple points to handle MIP6.
The first switch already handles a specific case (i.e. segments_left =3D=3D=

0), so the call to ipv6_srh_rcv() must happen before that. I choose not
to inline ipv6_srh_rcv into ipv6_rthdr_rcv as it would make the code
quite messy.


--oXOj4Hqg9T4Otg2qWJWWLLaKxpPS0x9XT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iEYEARECAAYFAlgGCsoACgkQjbzn67sZ6APubwCdGlX3oHBBVqxEFHBSTz6FPNum
u/0AoIxvZdzQd1/0jA1jtFM7hvckprfL
=tSNn
-----END PGP SIGNATURE-----

--oXOj4Hqg9T4Otg2qWJWWLLaKxpPS0x9XT--
