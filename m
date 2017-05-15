From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: iproute2 build error due to sr-ipv6 lwtunnel
Date: Mon, 15 May 2017 09:56:18 +0200
Message-ID: <6c156160-706e-7f87-117e-5c2c9784ec6f@uclouvain.be>
References: <590AF0C3.6070006@iogearbox.net>
 <3c0c0584-338d-47d0-76d4-e4408decc2c1@uclouvain.be>
 <590AFA8A.30602@iogearbox.net> <59185B16.5020107@iogearbox.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="St30lv91VSeSW17n33dBtqNwquKmkAQ10"
Cc: <netdev@vger.kernel.org>, <stephen@networkplumber.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:58740 "EHLO
        smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759721AbdEOHzu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 03:55:50 -0400
In-Reply-To: <59185B16.5020107@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--St30lv91VSeSW17n33dBtqNwquKmkAQ10
Content-Type: multipart/mixed; boundary="2Hiv5tvj3hGJLHUojIxWH6HGpQnvwr7VX"
From: David Lebrun <david.lebrun@uclouvain.be>
To: Daniel Borkmann <daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
Message-ID: <6c156160-706e-7f87-117e-5c2c9784ec6f@uclouvain.be>
Subject: Re: iproute2 build error due to sr-ipv6 lwtunnel
References: <590AF0C3.6070006@iogearbox.net>
 <3c0c0584-338d-47d0-76d4-e4408decc2c1@uclouvain.be>
 <590AFA8A.30602@iogearbox.net> <59185B16.5020107@iogearbox.net>
In-Reply-To: <59185B16.5020107@iogearbox.net>

--2Hiv5tvj3hGJLHUojIxWH6HGpQnvwr7VX
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 05/14/2017 03:26 PM, Daniel Borkmann wrote:
>=20
> David, are you still looking into fixing this?

Sorry, I left the issue on the side and then forgot about it.

Could you try the following iproute2 patch ? Thanks

diff --git a/include/linux/seg6.h b/include/linux/seg6.h
index 0715279..dd28017 100644
--- a/include/linux/seg6.h
+++ b/include/linux/seg6.h
@@ -15,7 +15,12 @@
 #define _LINUX_SEG6_H

 #include <linux/types.h>
+
+#ifdef __KERNEL__
 #include <linux/in6.h>         /* For struct in6_addr. */
+#else
+#include <netinet/in.h>
+#endif

 /*
  * SRH
diff --git a/ip/iproute_lwtunnel.c b/ip/iproute_lwtunnel.c
index 1395f03..434e60a 100644
--- a/ip/iproute_lwtunnel.c
+++ b/ip/iproute_lwtunnel.c
@@ -20,9 +20,6 @@
 #include <linux/lwtunnel.h>
 #include <linux/mpls_iptunnel.h>

-#ifndef __USE_KERNEL_IPV6_DEFS
-#define __USE_KERNEL_IPV6_DEFS
-#endif
 #include <linux/seg6.h>
 #include <linux/seg6_iptunnel.h>
 #include <linux/seg6_hmac.h>



--2Hiv5tvj3hGJLHUojIxWH6HGpQnvwr7VX--

--St30lv91VSeSW17n33dBtqNwquKmkAQ10
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iF0EARECAB0WIQT8nTbQ2eQR5sQwCJ+NvOfruxnoAwUCWRlfJgAKCRCNvOfruxno
A9IoAJwOHBBhVjMVo8C+mIHAylMm/ZvJ+wCbBXWyrKuD9SDMBRbquTBVIFUSac4=
=QHJk
-----END PGP SIGNATURE-----

--St30lv91VSeSW17n33dBtqNwquKmkAQ10--
