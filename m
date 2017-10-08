From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH iproute2] iproute: build more easily on Android
Date: Sun, 8 Oct 2017 09:47:47 +0300
Message-ID: <20171008064747.GN25829@mtr-leonro.local>
References: <20171002170337.42235-1-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="TXIPBuAs4GDcsx9K"
Cc: netdev@vger.kernel.org, stephen@networkplumber.org, enh@google.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:48866 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751189AbdJHGrv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 8 Oct 2017 02:47:51 -0400
Content-Disposition: inline
In-Reply-To: <20171002170337.42235-1-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--TXIPBuAs4GDcsx9K
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Oct 03, 2017 at 02:03:37AM +0900, Lorenzo Colitti wrote:
> iproute2 contains a bunch of kernel headers, including uapi ones.
> Android's libc uses uapi headers almost directly, and uses a
> script to fix kernel types that don't match what userspace
> expects.
>
> For example: https://issuetracker.google.com/36987220 reports
> that our struct ip_mreq_source contains "__be32 imr_multiaddr"
> rather than "struct in_addr imr_multiaddr". The script addresses
> this by replacing the uapi struct definition with a #include
> <bits/ip_mreq.h> which contains the traditional userspace
> definition.
>
> Unfortunately, when we compile iproute2, this definition
> conflicts with the one in iproute2's linux/in.h.
>
> Historically we've just solved this problem by running "git rm"
> on all the iproute2 include/linux headers that break Android's
> libc.  However, deleting the files in this way makes it harder to
> keep up with upstream, because every upstream change to
> an include file causes a merge conflict with the delete.
>
> This patch fixes the problem by moving the iproute2 linux headers
> from include/linux to include/uapi/linux.
>
> Tested: compiles on ubuntu trusty (glibc)
>
> Signed-off-by: Elliott Hughes <enh@google.com>
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
> ---

include/rdma/* files are coming from kernel's uapi too.

BTW, I know that the rdma folder is not relevant for android, but
anyway would like to see the same treatment for that folder as for the
include/linux.

Thanks

--TXIPBuAs4GDcsx9K
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlnZyhMACgkQ5GN7iDZy
WKefyg/+LrQMHsGSvbQlkiqW65jMKkQyYgOeLcNDiymDzQzujgQ/9EUfnq2kHkOb
8ZkxRcX8XwgQSIf7M+oh5Q7RGWpDm7OLyzvGHjZc5OYi84Zwy6H3Zt7ZoiXAGrF9
/yEVQVePsvhD4WjOHQ7jRwnZS+tKdS7ywkS5XcLI6HIKz0I5i2qgWYBQDayOZTaa
5kKwJwdL9Tz+sEyJT8VYpOMgvfHGH2fey8AAI2UVYHhSpuPsHimfjCsYxtztkLdu
LwGdTBvxzxTtRee1f95KZSquGMjtKlR3NP/FhHNtFhvoXbv1osq7EykTPYgogGBQ
SHnsccBWHA+UfLNdXO6DVdgNJOYJyMGK/aaHNPa7htj7wII4iYPZmPpTBB5JZM83
WmJkDpze/4f2FoZY+C66qQ7X1o/RRhUfRFuidUZMl32HVo37zcsw0ZnEBL3KJVIl
W2FLZpxdmgQ7GfQC7/XJwev22mkFzykQ7D2Qh2JnabxqRPWXyb4zhlNjF1WR16Oz
OytdfCGIcL2lN2zX6ZDirbN6BwdOUIM/s43a4A0PGweg+hs2RXBk8Ah/ug+FrjAX
uYqgUaYtLWxmhqI/qtSCvIiZJqH7Y+e58LtoKmyP7xZGvLAtdzzVkoW6/hoZjJGX
Hs/FB6B1OamFRgMDBlIpGCsye3fiTxRG6UrEp5u6JbxiXs7WTxo=
=4cvx
-----END PGP SIGNATURE-----

--TXIPBuAs4GDcsx9K--
