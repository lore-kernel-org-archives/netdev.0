From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net-next
 tree related)
Date: Mon, 17 Mar 2014 21:21:00 +1100
Message-ID: <20140317212100.9b57a2237439427be566ede7@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__17_Mar_2014_21_21_00_+1100_FvwW=D9uoton8b2z"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__17_Mar_2014_21_21_00_+1100_FvwW=D9uoton8b2z
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, today's linux-next build (powerpc
allyesconfig) failed like this:

drivers/net/ethernet/intel/i40evf/built-in.o:(.data+0x1868): multiple defin=
ition of `i40e_ptype_lookup'
drivers/net/ethernet/intel/i40e/built-in.o:(.data+0x3f58): first defined he=
re

Caused by commit 206812b5fccb ("i40e/i40evf: i40e implementation for
skb_set_hash") from the net-next tree.

I applied this patch for today (there is probably a better way):

=46rom 6964d39f8436eade2cdb0c5236734c579b8b0897 Mon Sep 17 00:00:00 2001
From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 17 Mar 2014 21:18:48 +1100
Subject: [PATCH] i40e/i40evf: i40e implementation for skb_set_hash fix

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ethernet/intel/i40evf/i40e_common.c    | 8 ++++----
 drivers/net/ethernet/intel/i40evf/i40e_prototype.h | 4 ++--
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/=
ethernet/intel/i40evf/i40e_common.c
index 78618af271cf..c688a0fc5c29 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -160,7 +160,7 @@ i40e_status i40evf_aq_queue_shutdown(struct i40e_hw *hw,
 }
=20
=20
-/* The i40e_ptype_lookup table is used to convert from the 8-bit ptype in =
the
+/* The i40evf_ptype_lookup table is used to convert from the 8-bit ptype i=
n the
  * hardware to a bit-field that can be used by SW to more easily determine=
 the
  * packet type.
  *
@@ -173,10 +173,10 @@ i40e_status i40evf_aq_queue_shutdown(struct i40e_hw *=
hw,
  *
  * Typical work flow:
  *
- * IF NOT i40e_ptype_lookup[ptype].known
+ * IF NOT i40evf_ptype_lookup[ptype].known
  * THEN
  *      Packet is unknown
- * ELSE IF i40e_ptype_lookup[ptype].outer_ip =3D=3D I40E_RX_PTYPE_OUTER_IP
+ * ELSE IF i40evf_ptype_lookup[ptype].outer_ip =3D=3D I40E_RX_PTYPE_OUTER_=
IP
  *      Use the rest of the fields to look at the tunnels, inner protocols=
, etc
  * ELSE
  *      Use the enum i40e_rx_l2_ptype to decode the packet type
@@ -205,7 +205,7 @@ i40e_status i40evf_aq_queue_shutdown(struct i40e_hw *hw,
 #define I40E_RX_PTYPE_INNER_PROT_TS	I40E_RX_PTYPE_INNER_PROT_TIMESYNC
=20
 /* Lookup table mapping the HW PTYPE to the bit field for decoding */
-struct i40e_rx_ptype_decoded i40e_ptype_lookup[] =3D {
+struct i40e_rx_ptype_decoded i40evf_ptype_lookup[] =3D {
 	/* L2 Packet types */
 	I40E_PTT_UNUSED_ENTRY(0),
 	I40E_PTT(1,  L2, NONE, NOF, NONE, NONE, NOF, NONE, PAY2),
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_prototype.h b/drivers/n=
et/ethernet/intel/i40evf/i40e_prototype.h
index 33c99051cc96..862fcdf52675 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_prototype.h
@@ -63,11 +63,11 @@ i40e_status i40evf_aq_queue_shutdown(struct i40e_hw *hw,
=20
 i40e_status i40e_set_mac_type(struct i40e_hw *hw);
=20
-extern struct i40e_rx_ptype_decoded i40e_ptype_lookup[];
+extern struct i40e_rx_ptype_decoded i40evf_ptype_lookup[];
=20
 static inline struct i40e_rx_ptype_decoded decode_rx_desc_ptype(u8 ptype)
 {
-	return  i40e_ptype_lookup[ptype];
+	return  i40evf_ptype_lookup[ptype];
 }
=20
 /* prototype for functions used for SW locks */
--=20
1.9.0

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Mon__17_Mar_2014_21_21_00_+1100_FvwW=D9uoton8b2z
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTJsyQAAoJEMDTa8Ir7ZwVKs0P/0fmBnSafPVQIN6AIIU5K/u/
A3vSOdoNg7zDJoQ3vE38bdDAc6pcaDiF2I4Hoqqfz4hQdzg6omG/iwAPZMHbcGNl
l+G89lLqYGQz6CsntvBlg0jKV1HKJLC7sxOxLePoTpIAwTcVXAXU5eF6oIzDBiUr
SxWaGRCKsJDH8f1kB/uEcZFkAweENMLGTIxLNuuv5mD9B/G2sS7iQFlLifUv7+wG
AqWWSnIZuhpwiZuSciJjkqc+4FXAxDVUUopqrwAHUXZ9p8ZTBTcdpoJr7tIDChfr
wVqgDhKE9WDhRsiSrZC5daZeEvF1txzvYSObkM2Y9zJj4qgi5xrCBl7GSG8jlwlI
0yN53j2OJei6fqCAArShPUTUXXiU2Srhbs1riz9JHAwOBQbBvj/dHGOmy/4nx9+3
cs4cELY/y1l3tcW2h+F+pywf6G47W33aHEU5DHyrEslPgYg8AZJkRbQwlxy7PgX8
6LBJyPc8/CThMsZqK+KzfWF+xKbN83qC+hYEfng2hiZjKVEStanFSs9OQf08BoDt
LZlc7L4MYOd1xhGZFPDrSKo4f8Kwgzw8Y4RAu1WTZJXbdHGByvu3AP8qSMPk2pjd
yNJXfZgnnkMXk6FFJ9W0TkDHOnQq7/5cFFhUlFHbACNy0CMBvAWXZdqDBKHNm8sG
ataSDvNuO9w9/B6smOsH
=SKxj
-----END PGP SIGNATURE-----

--Signature=_Mon__17_Mar_2014_21_21_00_+1100_FvwW=D9uoton8b2z--
