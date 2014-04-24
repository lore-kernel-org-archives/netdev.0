From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 24 Apr 2014 11:51:16 +1000
Message-ID: <20140424115116.340b7da0bc0bba781dc6cc1f@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__24_Apr_2014_11_51_16_+1000_1mQoBjeUuOBysgmb"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Chema Gonzalez <chema@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__24_Apr_2014_11_51_16_+1000_1mQoBjeUuOBysgmb
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/core/filter.c between commit 83d5b7ef99c9 ("net: filter: initialize A
and X registers") from the net tree and commit 4cd3675ebf74 ("filter:
added BPF random opcode") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/core/filter.c
index 9d79ca0a6e8e,78a636e60a0b..000000000000
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@@ -652,6 -643,19 +652,12 @@@ static u64 __get_raw_cpu_id(u64 ctx, u6
  	return raw_smp_processor_id();
  }
 =20
+ /* note that this only generates 32-bit random numbers */
+ static u64 __get_random_u32(u64 ctx, u64 A, u64 X, u64 r4, u64 r5)
+ {
+ 	return (u64)prandom_u32();
+ }
+=20
 -/* Register mappings for user programs. */
 -#define A_REG		0
 -#define X_REG		7
 -#define TMP_REG		8
 -#define ARG2_REG	2
 -#define ARG3_REG	3
 -
  static bool convert_bpf_extensions(struct sock_filter *fp,
  				   struct sock_filter_int **insnp)
  {

--Signature=_Thu__24_Apr_2014_11_51_16_+1000_1mQoBjeUuOBysgmb
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTWG4YAAoJEMDTa8Ir7ZwVfHkQAIngJyA+COCzHt7ryJtH9jF0
jxo52CCKb6MXSajGVf3Zeo43V2yxe53Fuichc/FFa5BPU+QVnWtytFW/7YXKPWaA
iIDWV5ozAAzP78QJDLxqGA/h/9TuVZIGA+k9iz+L/HBrJXdAARTsmrxcZRcbjPd2
mZ2wavAh6kilo2Z0YIY1rH6swMUhM6zqPDEIB+9EHdc1dEdIK7IkHqwcVLVr44YA
JAEU1eZlwO5q0hbFa8nE7ZYQeVhQuRwUjHGKstVQsoDp3CJbsBi2VOh+N5AxfpB4
1GKUsg0+KCT5nx86cYsTz3xgaS48PyUOhWdiZPTcTcZ+eZyd480L9HYWo8LPbe15
eRzc6U9QfsG+3B5eIwdL2m7eiEtNlSUcValtCJ8r3ms5BJ0Lw3/liZIpfwY55fnc
J2J2/LTpzvFrDQ+AD07HgL5YofweFxuQKWBUrtQTjyEN7t8KwPwA/w7bc0bxxR2C
zf1PnLv9cdldjGwsiyaVruWwpbl9MO14e9+FfsL7Npn7igEBbXuFaQ/65VyFnRMf
0r32j/w3h2JRThGvjZR6u54/BXizKpFJPYhBkgs6i4uiLb9KJj9lvp9pWDUuAqR6
UEl5PAXAeG1JHmt9jn9vQF9EwkfwnYOEMAGp97woeimXgUAkdohSOQ1ZRQjKq0pW
C3EoWE0U72qYy7ab09hE
=SUoj
-----END PGP SIGNATURE-----

--Signature=_Thu__24_Apr_2014_11_51_16_+1000_1mQoBjeUuOBysgmb--
