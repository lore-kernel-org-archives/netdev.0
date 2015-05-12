From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 12 May 2015 11:49:51 +1000
Message-ID: <20150512114951.50d77ffc@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/28xK03G1d_kCTqeskAie_8E"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/28xK03G1d_kCTqeskAie_8E
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
include/net/codel.h between commit a5d280904050 ("codel: fix
maxpacket/mtu confusion") from the net tree and commit 80ba92fa1a92
("codel: add ce_threshold attribute") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc include/net/codel.h
index 1e18005f7f65,8c0f78f209e8..000000000000
--- a/include/net/codel.h
+++ b/include/net/codel.h
@@@ -119,14 -119,14 +119,16 @@@ static inline u32 codel_time_to_us(code
  /**
   * struct codel_params - contains codel parameters
   * @target:	target queue size (in time units)
+  * @ce_threshold:  threshold for marking packets with ECN CE
   * @interval:	width of moving time window
 + * @mtu:	device mtu, or minimal queue backlog in bytes.
   * @ecn:	is Explicit Congestion Notification enabled
   */
  struct codel_params {
  	codel_time_t	target;
+ 	codel_time_t	ce_threshold;
  	codel_time_t	interval;
 +	u32		mtu;
  	bool		ecn;
  };
 =20
@@@ -166,14 -167,16 +169,18 @@@ struct codel_stats=20
  	u32		maxpacket;
  	u32		drop_count;
  	u32		ecn_mark;
+ 	u32		ce_mark;
  };
 =20
+ #define CODEL_DISABLED_THRESHOLD INT_MAX
+=20
 -static void codel_params_init(struct codel_params *params)
 +static void codel_params_init(struct codel_params *params,
 +			      const struct Qdisc *sch)
  {
  	params->interval =3D MS2TIME(100);
  	params->target =3D MS2TIME(5);
+ 	params->ce_threshold =3D CODEL_DISABLED_THRESHOLD;
 +	params->mtu =3D psched_mtu(qdisc_dev(sch));
  	params->ecn =3D false;
  }
 =20

--Sig_/28xK03G1d_kCTqeskAie_8E
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVUVw/AAoJEMDTa8Ir7ZwVurgP/A7slXYrgnbjM0KMaA090qoi
Y/6sWtyFBc8IEgDVu04T5GLo8ngI8LX7qQd2h4oOYH+dEV1iZRfTChMgaiAt1CLz
lwxewg8E61xC1+jbzft04oUnQRw0N0TXBWYIfZySq6kC092u0+d8KeyuENWxZYSi
AtVU9owpK1ZMWMOQfD+LBgUdHnqWKQKwgD02FWbHVuYjUm0DwVL6VaOmuE6bGcZ/
g/Dt3XMssDlwtNa3NS0EnxuGgxvVIJB5dsXMHhnVcEHl+BlXFcHgf8d3W7UcRvek
4hFQkwVC4AlPlDfGwtBYN35tBawzm1TvMXv+RtSPJpRFdtIPHGA4+7Arr988a5yw
vfnnc7M0aTCuHvWtlKb2LSWkZvixC9IQoUS0UiYMvrwbKEV9JOHTF4JQ1vWo5iT4
gQBa1lJHxlWZhMiuzsnvRhu/DDiugQKfmtXmMaY/xR6j4K1t9Wi9be9sCNd2poCe
HxkeJoVY7f+lgW3GI7BOmWMze6RBwqVqwCaSqdrS1NPwyV9zsh/kVNQxV8DsW14F
6j126pgoWuXjiUz4/UFQ8K/OVEv6f77ebnA+R7sq//Qq6ZCgKuRbUJ0SCN+Fj+yr
d0PnIy8hy6PWptDm+hyw640eGsvUcLsHsySdNNQQx8csP1ZWjn7McJD0DEQKaCjB
L5K20t7vbZE6w/LdvR01
=UWQU
-----END PGP SIGNATURE-----

--Sig_/28xK03G1d_kCTqeskAie_8E--
