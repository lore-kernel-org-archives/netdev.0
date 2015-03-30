From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Mon, 30 Mar 2015 15:05:34 +1100
Message-ID: <20150330150534.52bf72dd@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/Jr6nuAHfhaPgiSEoQpT2uPQ"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ben Hutchings <ben.hutchings@codethink.co.uk>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:49704 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750743AbbC3EFn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2015 00:05:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/Jr6nuAHfhaPgiSEoQpT2uPQ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (x86_64
allmodconfig) failed like this:

drivers/net/usb/cdc_ncm.c: In function 'cdc_ncm_fill_tx_frame':
drivers/net/usb/cdc_ncm.c:1187:2: error: too few arguments to function 'usb=
net_set_skb_tx_stats'
  usbnet_set_skb_tx_stats(skb_out, n);
  ^
In file included from drivers/net/usb/cdc_ncm.c:51:0:
include/linux/usb/usbnet.h:238:1: note: declared here
 usbnet_set_skb_tx_stats(struct sk_buff *skb,
 ^

Caused by a bad merge between commits 1e9e39f4a298 ("usbnet: Fix
tx_packets stat for FLAG_MULTI_FRAME drivers") and 7a1e890e2168
("usbnet: Fix tx_bytes statistic running backward in cdc_ncm") form the
net tree and commit 6588af614e7b ("usbnet: Fix tx_packets stat for
FLAG_MULTI_FRAME drivers") from the net-next tree.  (Presumably,
6588af614e7b was cherry-picked as a bug fix.  So, Dave, something to
watch for if you merge net into net-next.)

I applied the following merge fix patch:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 30 Mar 2015 14:59:49 +1100
Subject: [PATCH] usbnet: fix bad merge in cdc_ncm.c

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/usb/cdc_ncm.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index ee6fed0af6f5..c3e4da9e79ca 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1184,8 +1184,6 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk_b=
uff *skb, __le32 sign)
 	usbnet_set_skb_tx_stats(skb_out, n,
 				ctx->tx_curr_frame_payload - skb_out->len);
=20
-	usbnet_set_skb_tx_stats(skb_out, n);
-
 	return skb_out;
=20
 exit_no_skb:
--=20
2.1.4

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/Jr6nuAHfhaPgiSEoQpT2uPQ
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVGMuTAAoJEMDTa8Ir7ZwVUPMQAJBNnUnRFpZNcRGq+AJwVlA3
2HxqW7RXMTzRuYR7UoVmMoo+mcONdYH9fDYHi5yWVcp4JregwNQDA5axXbxEn2Md
Y4vyRQKroTjluEN4hihgz4Cht+/13RfMyUC8qXUG1PLvQ+pY8dVQ7Fly6xgJGSoh
5bw9ohKI4owTn/LDvFb2qQWXhwE9TT2iCe2kNVwXCXm8QOUxCBxgCwOhYdLz7zGL
+rWTAOAw0oZhF+N2MpWNc7MZuRiZ/6OrgCFs1zaI0T8aB8Jpy+Pnue167i91/14o
lgo7bT1AFxtaGpw1qQjG/k+HQ5IyNc1Q7fGHe6ogjne64V7OwAHZACTK29xqV6bL
oHvbLisOx0hS02g0lMVz1hAy6i5Y+QvEqh9+2scvuQQR1jdUjCkSNFKL0pFsVm7O
cPlxkURFFEmao1E3QnbUIa5ZBI9SLX4DVxETfnOb5tC5ukvhO1BuGdh4qaVAgUfj
abZUFcJBM1pdilVGKyJASggJ+LI4vq8+ZwkVwX+jVwfpHgrqP5AQfgqjU4aZj7iF
TA6/8AR1Ve3+YB6lKnKMrNTgR+6fwLAdcwE2B7q89BAJ+uh6gu16AQ30z5NagPJo
GeBlPE7+5vrT/m/xbMBnIaGUJz32ttg1j5UDGAin+ebSTTFcscsYcALsgZq7qYl4
BHGY3G2lgEsMIKmtQ1yV
=/muZ
-----END PGP SIGNATURE-----

--Sig_/Jr6nuAHfhaPgiSEoQpT2uPQ--
