From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure in Linus' tree
Date: Mon, 3 Nov 2014 15:09:30 +1100
Message-ID: <20141103150930.70a260c7@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/2JL2.b9m2WlRSXIw=EzYmG7"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/2JL2.b9m2WlRSXIw=EzYmG7
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Linus,

With Linus' tree, today's linux-next build (powerpc allyesconfig)
failed like this:

net/bridge/netfilter/nft_reject_bridge.c: In function 'nft_reject_br_send_v=
6_unreach':
net/bridge/netfilter/nft_reject_bridge.c:240:3: error: implicit declaration=
 of function 'csum_ipv6_magic' [-Werror=3Dimplicit-function-declaration]
   csum_ipv6_magic(&nip6h->saddr, &nip6h->daddr,
   ^

Caused by commit 523b929d5446 ("netfilter: nft_reject_bridge: don't use
IP stack to reject traffic") from Linus' tree.

I applied the following patch for today:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 3 Nov 2014 15:01:16 +1100
Subject: [PATCH] netfilter: nft_reject_bridge: include ip6_checksum.h for c=
sum_ipv6_magic

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/bridge/netfilter/nft_reject_bridge.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/bridge/netfilter/nft_reject_bridge.c b/net/bridge/netfilte=
r/nft_reject_bridge.c
index 654c9018e3e7..1123f2b4a1b1 100644
--- a/net/bridge/netfilter/nft_reject_bridge.c
+++ b/net/bridge/netfilter/nft_reject_bridge.c
@@ -16,6 +16,7 @@
 #include <net/netfilter/nft_reject.h>
 #include <net/netfilter/ipv4/nf_reject.h>
 #include <net/netfilter/ipv6/nf_reject.h>
+#include <net/ip6_checksum.h>
 #include <linux/ip.h>
 #include <net/ip.h>
 #include <linux/netfilter_bridge.h>
--=20
2.1.1

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/2JL2.b9m2WlRSXIw=EzYmG7
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUVv//AAoJEMDTa8Ir7ZwVnnwQAIgjU76KXvI9j2HrNkuchbxp
6k/F06HD6+rsEoZUxOAeS5JwDVfHBfbByMAmPcOJW57rOtvACBBU3nJBfZFvlJ9K
N2/AZyrBCIwKh2vb1uEjgEfTWNiqKtky8J7noZFqizrZGS/B4dXqHlTwz3/1Xr3n
mkuAs+aduEuxSbA2SXChyOLoUuiKS2zkFtGUw8Rwouf43LSZHPynVhLqDFJG9Rsl
W2Eb2DnU9h1sBjAx4AtLy9THxOFS6hYHk8t6E6dstuA1967OQwOtqDZhvhP3A0jZ
Lk6H4IJgtIPi+/LXl6P990qfAldnWYVdNQvXVmQOfCbHTu/znhHq5rt4t+PFuZwV
cdpcmJx+sa9jEFGATWLgpE9To7sexW3iR5Y+enOeVoSSmP+WO529Y3KUv3bfSVjW
BWLsDZfzIDR92YcTOlmqkfbicu+IL1SWAVVmNfRFlAZdvYgNqP5zXKA4kD44STO/
uEtMQoHHr+JzixWCXDFm7hq6kugiibD9ALrRs82UWfi/E9peBeJyYG7VZZSAQJ15
FRnYhP9wiHoiVZLI1uPkuJJpWKIQFBFoGOyio3ylSh2xfKSUl8FewJ3WVtgmSuq/
ShNqdf2K4bmbvKyWAGBIj+qwb3FIdms1sBOaVIja+B9FTDyruDLjZI0rRpkjsf7/
Vo/KRkZ+VLNFLbe5iASa
=2KqR
-----END PGP SIGNATURE-----

--Sig_/2JL2.b9m2WlRSXIw=EzYmG7--
