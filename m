From: Christian Langrock <christian.langrock@secunet.com>
Subject: Re: [PATCH] ip/link_vti*.c: Fix output for ikey/okey
Date: Tue, 8 Aug 2017 08:24:12 +0200
Message-ID: <c78b6c79-ea06-2d8c-2e12-21a3faa7dc22@secunet.com>
References: <bf2d09ad-28b8-c64c-dd60-4fb288259e3e@secunet.com>
 <20170807153815.7acf5b93@xeon-e3>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature";
        boundary="ai9xekG62C0Q3eKSHQWWI4iUrkrngWh7E"
Cc: <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:59530 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750776AbdHHGYP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 8 Aug 2017 02:24:15 -0400
In-Reply-To: <20170807153815.7acf5b93@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--ai9xekG62C0Q3eKSHQWWI4iUrkrngWh7E
Content-Type: multipart/mixed; boundary="qCLhsgpQfOFXLhUjT21pDxB6AoS3uWPgL";
 protected-headers="v1"
From: Christian Langrock <christian.langrock@secunet.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Cc: netdev@vger.kernel.org
Message-ID: <c78b6c79-ea06-2d8c-2e12-21a3faa7dc22@secunet.com>
Subject: Re: [PATCH] ip/link_vti*.c: Fix output for ikey/okey
References: <bf2d09ad-28b8-c64c-dd60-4fb288259e3e@secunet.com>
 <20170807153815.7acf5b93@xeon-e3>
In-Reply-To: <20170807153815.7acf5b93@xeon-e3>

--qCLhsgpQfOFXLhUjT21pDxB6AoS3uWPgL
Content-Type: text/plain; charset=windows-1252
Content-Language: de-DE
Content-Transfer-Encoding: quoted-printable

Using hex values sounds reasonable.

BR,

Christian


Updated Patch:

Subject: [PATCH] ip/link_vti*.c: Fix output for ikey/okey

ikey and okey are normal u32 values. There's no reason to print them as
IPv4/IPv6 addresses. Instead print them as hex values.

Signed-off-by: Christian Langrock <christian.langrock@secunet.com>
---
 ip/link_vti.c  | 10 ++++------
 ip/link_vti6.c | 10 ++++------
 2 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/ip/link_vti.c b/ip/link_vti.c
index d5242ac..f87623b 100644
--- a/ip/link_vti.c
+++ b/ip/link_vti.c
@@ -244,14 +244,12 @@ static void vti_print_opt(struct link_util *lu,
FILE *f, struct rtattr *tb[])
                        fprintf(f, "dev %u ", link);
        }
 -       if (tb[IFLA_VTI_IKEY]) {
-               inet_ntop(AF_INET, RTA_DATA(tb[IFLA_VTI_IKEY]), s2,
sizeof(s2));
-               fprintf(f, "ikey %s ", s2);
+       if (tb[IFLA_VTI_IKEY] && rta_getattr_u32(tb[IFLA_VTI_IKEY])) {
+               fprintf(f, "ikey 0x%x ",
ntohl(rta_getattr_u32(tb[IFLA_VTI_IKEY])));
        }
 -       if (tb[IFLA_VTI_OKEY]) {
-               inet_ntop(AF_INET, RTA_DATA(tb[IFLA_VTI_OKEY]), s2,
sizeof(s2));
-               fprintf(f, "okey %s ", s2);
+       if (tb[IFLA_VTI_OKEY] && rta_getattr_u32(tb[IFLA_VTI_OKEY])) {
+               fprintf(f, "okey 0x%x ",
ntohl(rta_getattr_u32(tb[IFLA_VTI_OKEY])));
        }
         if (tb[IFLA_VTI_FWMARK] && rta_getattr_u32(tb[IFLA_VTI_FWMARK]))=
 {
diff --git a/ip/link_vti6.c b/ip/link_vti6.c
index 220b7df..6ae87dd 100644
--- a/ip/link_vti6.c
+++ b/ip/link_vti6.c
@@ -247,14 +247,12 @@ static void vti6_print_opt(struct link_util *lu,
FILE *f, struct rtattr *tb[])
                        fprintf(f, "dev %u ", link);
        }
 -       if (tb[IFLA_VTI_IKEY]) {
-               inet_ntop(AF_INET, RTA_DATA(tb[IFLA_VTI_IKEY]), s2,
sizeof(s2));
-               fprintf(f, "ikey %s ", s2);
+       if (tb[IFLA_VTI_IKEY] && rta_getattr_u32(tb[IFLA_VTI_IKEY])) {
+               fprintf(f, "ikey %u ",
ntohl(rta_getattr_u32(tb[IFLA_VTI_IKEY])));
        }
 -       if (tb[IFLA_VTI_OKEY]) {
-               inet_ntop(AF_INET, RTA_DATA(tb[IFLA_VTI_OKEY]), s2,
sizeof(s2));
-               fprintf(f, "okey %s ", s2);
+       if (tb[IFLA_VTI_OKEY] && rta_getattr_u32(tb[IFLA_VTI_OKEY])) {
+               fprintf(f, "okey %u ",
ntohl(rta_getattr_u32(tb[IFLA_VTI_OKEY])));
        }
         if (tb[IFLA_VTI_FWMARK] && rta_getattr_u32(tb[IFLA_VTI_FWMARK]))=
 {
--=20
2.7.4






Am 08.08.2017 um 00:38 schrieb Stephen Hemminger:
> On Mon, 7 Aug 2017 11:59:28 +0200
> Christian Langrock <christian.langrock@secunet.com> wrote:
>
>> ikey and okey are normal u32 values. There's no reason to print them a=
s
>> IPv4/IPv6 addresses.
>>
>> Signed-off-by: Christian Langrock <christian.langrock@secunet.com>
> Changing output format breaks scripts that parse output.
> But on the other hand, the VTI code breaks the assumption that ip comma=
nd
> output should be the same as input.
>
> More likely the original output format was done to match Cisco output.
>
>
> Why not print in hex like fwmark?
>
>
>
>
>




--qCLhsgpQfOFXLhUjT21pDxB6AoS3uWPgL--

--ai9xekG62C0Q3eKSHQWWI4iUrkrngWh7E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJZiVkMAAoJEKN4x1+C62tedSAH/i5crqTy5zC0v4NiqtbfBukD
ZypVHvSCWgyw5wXnUi50vKnbcfA004104nCdq5CAfFly4k2PTuVqfVqow51n3ADN
ufTC+2lF9QQl6ObAKqN8Ltx1sW+5P5S50Vb/1o8SmyhvlOwI7u5RP8Dl0s5KHzL+
VEGnxrebwhq7CvrFWHcyD1FDgT0Vx12iu4gUTs4gOBuXYXxaDL0PPbZdiFRxCnT8
IGN/ZDSGGeOYIdyo0mQGzWUL0naBPSIsi8VXauoZyF82/euG1H5Lz/x+nKf95t7d
eGhTz8iuYjq0JHwSCx4NVzereXBi7O9uyX33R8VUcenW/fN5cm1fGq9y5sN9mA8=
=GafL
-----END PGP SIGNATURE-----

--ai9xekG62C0Q3eKSHQWWI4iUrkrngWh7E--
