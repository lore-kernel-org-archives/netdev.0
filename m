From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: iproute2 build error due to sr-ipv6 lwtunnel
Date: Thu, 4 May 2017 11:28:03 +0200
Message-ID: <3c0c0584-338d-47d0-76d4-e4408decc2c1@uclouvain.be>
References: <590AF0C3.6070006@iogearbox.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="cj8labB5QqSAbDbqV7e6P4MwHmPQ1m7MS"
Cc: <netdev@vger.kernel.org>, <stephen@networkplumber.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:33333 "EHLO
        smtp1.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754818AbdEDJ1l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 05:27:41 -0400
In-Reply-To: <590AF0C3.6070006@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--cj8labB5QqSAbDbqV7e6P4MwHmPQ1m7MS
Content-Type: multipart/mixed; boundary="4NBlOCt6oEtnuHvpGWsNb0BDNvod6jHHA"
From: David Lebrun <david.lebrun@uclouvain.be>
To: Daniel Borkmann <daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
Message-ID: <3c0c0584-338d-47d0-76d4-e4408decc2c1@uclouvain.be>
Subject: Re: iproute2 build error due to sr-ipv6 lwtunnel
References: <590AF0C3.6070006@iogearbox.net>
In-Reply-To: <590AF0C3.6070006@iogearbox.net>

--4NBlOCt6oEtnuHvpGWsNb0BDNvod6jHHA
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 05/04/2017 11:13 AM, Daniel Borkmann wrote:
> Hi David,
>=20
> I'm getting the following build error from e8493916a8ed ("iproute:
> add support for SR-IPv6 lwtunnel encapsulation"). Reverting your
> commit makes iproute2 build again for me. Please take a look.

Hi Daniel,

This is because linux/seg6.h does an include of linux/in6.h (cf kernel
commit ea3ebc73b46fbdb049dafd47543bb22efaa09c8e "uapi: fix linux/seg6.h
and linux/seg6_iptunnel.h userspace compilation errors"), and iproute2's
include/utils.h requires the system /usr/include/resolv.h, which itself
includes /usr/include/netinet/in.h, re-defining struct in6_addr.

However, netinet/in.h protects some struct definitions with #ifndef
__USE_KERNEL_IPV6_DEFS, which is explicitly defined in
iproute_lwtunnel.c, thus avoiding this specific issue.

What is your glibc version ?

David


--4NBlOCt6oEtnuHvpGWsNb0BDNvod6jHHA--

--cj8labB5QqSAbDbqV7e6P4MwHmPQ1m7MS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iF0EARECAB0WIQT8nTbQ2eQR5sQwCJ+NvOfruxnoAwUCWQr0JgAKCRCNvOfruxno
A9LAAJ99/sObUkbVhd9Fxxe+X40r1kuj6QCfXdeRMfiNXxTKFqZghL2zP5rV7wQ=
=vHJ2
-----END PGP SIGNATURE-----

--cj8labB5QqSAbDbqV7e6P4MwHmPQ1m7MS--
