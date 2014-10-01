From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Wed, 1 Oct 2014 17:04:03 +1000
Message-ID: <20141001170403.7a319458@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/s1LlBwVLeXabUhepYtuqBvK"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/s1LlBwVLeXabUhepYtuqBvK
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (powerpc
allyesconfig) failed like this:

drivers/net/ethernet/xilinx/ll_temac_main.c: In function 'temac_start_xmit_=
done':
drivers/net/ethernet/xilinx/ll_temac_main.c:633:22: warning: cast to pointe=
r from integer of different size [-Wint-to-pointer-cast]
    dev_kfree_skb_irq((struct sk_buff *)cur_p->app4);
                      ^
drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c: In function 'fm10k_set_ri=
ngparam':
drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c:477:2: error: implicit dec=
laration of function 'vmalloc' [-Werror=3Dimplicit-function-declaration]
  temp_ring =3D vmalloc(i * sizeof(struct fm10k_ring));
  ^
drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c:477:12: warning: assignmen=
t makes pointer from integer without a cast
  temp_ring =3D vmalloc(i * sizeof(struct fm10k_ring));
            ^
drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c:546:2: error: implicit dec=
laration of function 'vfree' [-Werror=3Dimplicit-function-declaration]
  vfree(temp_ring);
  ^

Caused by commit 82dd0f7ee9a3 ("fm10k: Add ethtool support").  See Rule
1 in Documentation/SubmitChecklist.

I have added the following fix patch for today:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 1 Oct 2014 17:00:49 +1000
Subject: [PATCH] fm10k: using vmalloc requires including linux/vmalloc.h

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net=
/ethernet/intel/fm10k/fm10k_ethtool.c
index a9bbe60347d8..2d04464e6aa3 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -18,6 +18,8 @@
  * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-64=
97
  */
=20
+#include <linux/vmalloc.h>
+
 #include "fm10k.h"
=20
 struct fm10k_stats {
--=20
2.1.1

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/s1LlBwVLeXabUhepYtuqBvK
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUK6dpAAoJEMDTa8Ir7ZwVcisP/iR/xYdFkbm6DBb+jYxD/ZQW
IDMIAT1TY7IYy7v4bcVQX3Z6kpzMwRiUQrByOHsu4x0pk7BE8Y+3JDatZIQiXd8A
APoiG6wWdkCmsYUrzeg86p/1y/oygDJslPAFmkA7gOTV2Lny+qKui11fUxNZNMIG
gHthDgJ1TEBZFglOiMsH3BOkjjfFn1xw5cRwAD3IN9JQu/bOwk7LwtaT9HBwOr12
uHYXwXQSpkN04kYvcnvnEU+HgD9tg2ZzJV05U+mfQFBbq488VjXE/73mjP7FJRTQ
UQMlYU1OXiLnEbHgJOGZ0kU9TthInV/zIscWlsy2gogLAJd4fHsL+K03WKVZSl/E
RhqfXCNbBdxa1fRrbswdvR6cpmYn3/Gk9WHVFhJSVqzmYlXdt22xij6zdv+FqW7x
crfAB41h3B7J/m1eqD7MCyabIpnibRAid+T7ReDUxD7xFN2Q8EALUjaQ1gj1aYIB
89WPUTzLGoaA0u6PN5Mc4gJvGpfHv1Lm5lWuWvQRklcN2c2/7F9S47N9/RFFFao3
yXZA4uuahu9uu8w+qQ278tcG7KSpAsLDvS49YMdL9BYWYiqcJcqwQom8NjWRuGfp
xwp5xi49o4RXqreC3wdRa+7gDSFAaF6rB9/TCiF2vxt6j5aer+T7XQ7h3jd2UMJk
X7yMcm7h3UaCG6NvDY3l
=Lwfd
-----END PGP SIGNATURE-----

--Sig_/s1LlBwVLeXabUhepYtuqBvK--
