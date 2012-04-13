From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the wireless-next tree with the
 net-next tree
Date: Fri, 13 Apr 2012 12:41:03 +1000
Message-ID: <20120413124103.5bc632a6425ea9da9c5c4aae@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__13_Apr_2012_12_41_03_+1000_BP1i8x.ow4b2P.hi"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Samuel Ortiz <sameo@linux.intel.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:54424 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752568Ab2DMClN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 22:41:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Fri__13_Apr_2012_12_41_03_+1000_BP1i8x.ow4b2P.hi
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi John,

Today's linux-next merge of the wireless-next tree got a semantic
conflict in net/nfc/netlink.c between commit b3fe91c53a0a ("netlink:
Delete all NLA_PUT*() macros") from the net-next tree and commit
8112a5c91d78 ("NFC: Add a target lost netlink event") from the
wireless-next tree.

I added the below merge fix patch.

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 13 Apr 2012 12:34:10 +1000
Subject: [PATCH] NFC: fix up for NLA_PUT_ api changes

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/nfc/netlink.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
index 539d041..24d8d12 100644
--- a/net/nfc/netlink.c
+++ b/net/nfc/netlink.c
@@ -202,8 +202,10 @@ int nfc_genl_target_lost(struct nfc_dev *dev, u32 targ=
et_idx)
 	if (!hdr)
 		goto free_msg;
=20
-	NLA_PUT_STRING(msg, NFC_ATTR_DEVICE_NAME, nfc_device_name(dev));
-	NLA_PUT_U32(msg, NFC_ATTR_TARGET_INDEX, target_idx);
+	if (nla_put_string(msg, NFC_ATTR_DEVICE_NAME, nfc_device_name(dev)))
+		goto nla_put_failure;
+	if (nla_put_u32((msg, NFC_ATTR_TARGET_INDEX, target_idx))
+		goto nla_put_failure;
=20
 	genlmsg_end(msg, hdr);
=20
--=20
1.7.10.rc3

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__13_Apr_2012_12_41_03_+1000_BP1i8x.ow4b2P.hi
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPh5I/AAoJEECxmPOUX5FE1cEP/2HciOQkfSLYv/KQ8vbUA/6A
mib/zxIj+1PNJuMfwXgg9ZMxFpCZoWfUWSVC4/aehM94gZO+o7pAvOOzK9z/10XN
neu0+Hkoy6/dF418/epmTDk9RnyvqseJ91+6odHo7yr+EUGzQ/4nJtM5FoEDjMrU
zvQuHiwoSJFRigK0kIrNd3X1YDH9gYKHXlW0zrnH3AHmEFBFpBUbuQEofyLzE7I9
CAuVNdSl/yiv5VCGjkBYLR1KateC90lqFQ2E542xJv6QI48jiaVWmCR5eWn8BnNZ
rXfE8AY0ZpZcoH89wEgpGPH0EacFDTnpcs3c9dXrshROJ/BfOx3rKWjyk9FuKkdm
1T7h0hRvQ9JqUrI4rUcG+/vvRWpg1ZZeDNmQKnlTEg+oPe8qWqPulXTsXtQy9wM2
5jcS9IU3MBkulJWfzRWYe6tBNAmIpwDbwq935Py5ArxQ42Wbklj9PGbRBwNUoFrk
2+s+Ul+QghUdUXFkQhGASo243UgWEL7PQGW0KYXmF8FdDLGA3QgKB8vIZkaGfLzw
tRZnXzzo/qarpvZLhBfKfEsJ0freF0SWM/oTeih6kGysG4tQttKfE9w8obKZuCmP
OaaJ6kd0LRYch/DNBQ4EQ2B6H2f1EL9XPDmXKFVLP2DCptftDJpnCqv9bCMGL96x
wrIzwUnKwAqDkG6nx6xK
=fsnu
-----END PGP SIGNATURE-----

--Signature=_Fri__13_Apr_2012_12_41_03_+1000_BP1i8x.ow4b2P.hi--
