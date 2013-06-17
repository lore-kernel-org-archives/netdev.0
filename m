From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with Linus' tree
Date: Mon, 17 Jun 2013 12:44:41 +1000
Message-ID: <20130617124441.e2e93d3a9e48952d685afa6b@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__17_Jun_2013_12_44_41_+1000_8Hlngt7fx_6iMMlb"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Simon Wunderlich <simon@open-mesh.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__17_Jun_2013_12_44_41_+1000_8Hlngt7fx_6iMMlb
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/batman-adv/bat_iv_ogm.c between commit 7c24bbbeab41 ("batman-adv:
forward late OGMs from best next hop") from Linus' tree and commit
24a5deeb8a19 ("batman-adv: move ring_buffer helper functions in
bat_iv_ogm") from the net-next tree.

I fixed it up (as specified in your email (thanks) - see below) and can
carry the fix as necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/batman-adv/bat_iv_ogm.c
index f680ee1,d07323b..0000000
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@@ -30,20 -29,47 +29,63 @@@
  #include "network-coding.h"
 =20
  /**
 + * batadv_dup_status - duplicate status
 + * @BATADV_NO_DUP: the packet is a duplicate
 + * @BATADV_ORIG_DUP: OGM is a duplicate in the originator (but not for the
 + *  neighbor)
 + * @BATADV_NEIGH_DUP: OGM is a duplicate for the neighbor
 + * @BATADV_PROTECTED: originator is currently protected (after reboot)
 + */
 +enum batadv_dup_status {
 +	BATADV_NO_DUP =3D 0,
 +	BATADV_ORIG_DUP,
 +	BATADV_NEIGH_DUP,
 +	BATADV_PROTECTED,
 +};
 +
++/**
+  * batadv_ring_buffer_set - update the ring buffer with the given value
+  * @lq_recv: pointer to the ring buffer
+  * @lq_index: index to store the value at
+  * @value: value to store in the ring buffer
+  */
+ static void batadv_ring_buffer_set(uint8_t lq_recv[], uint8_t *lq_index,
+ 				   uint8_t value)
+ {
+ 	lq_recv[*lq_index] =3D value;
+ 	*lq_index =3D (*lq_index + 1) % BATADV_TQ_GLOBAL_WINDOW_SIZE;
+ }
+=20
+ /**
+  * batadv_ring_buffer_set - compute the average of all non-zero values st=
ored
+  * in the given ring buffer
+  * @lq_recv: pointer to the ring buffer
+  *
+  * Returns computed average value.
+  */
+ static uint8_t batadv_ring_buffer_avg(const uint8_t lq_recv[])
+ {
+ 	const uint8_t *ptr;
+ 	uint16_t count =3D 0, i =3D 0, sum =3D 0;
+=20
+ 	ptr =3D lq_recv;
+=20
+ 	while (i < BATADV_TQ_GLOBAL_WINDOW_SIZE) {
+ 		if (*ptr !=3D 0) {
+ 			count++;
+ 			sum +=3D *ptr;
+ 		}
+=20
+ 		i++;
+ 		ptr++;
+ 	}
+=20
+ 	if (count =3D=3D 0)
+ 		return 0;
+=20
+ 	return (uint8_t)(sum / count);
+ }
++
  static struct batadv_neigh_node *
  batadv_iv_ogm_neigh_new(struct batadv_hard_iface *hard_iface,
  			const uint8_t *neigh_addr,
@@@ -1013,11 -1062,10 +1085,11 @@@ static void batadv_iv_ogm_process(cons
  	struct batadv_neigh_node *orig_neigh_router =3D NULL;
  	int has_directlink_flag;
  	int is_my_addr =3D 0, is_my_orig =3D 0, is_my_oldorig =3D 0;
- 	int is_broadcast =3D 0, is_bidirect;
+ 	int is_bidirect;
  	bool is_single_hop_neigh =3D false;
  	bool is_from_best_next_hop =3D false;
 -	int is_duplicate, sameseq, simlar_ttl;
 +	int sameseq, similar_ttl;
 +	enum batadv_dup_status dup_status;
  	uint32_t if_incoming_seqno;
  	uint8_t *prev_sender;
 =20

--Signature=_Mon__17_Jun_2013_12_44_41_+1000_8Hlngt7fx_6iMMlb
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJRvngZAAoJEECxmPOUX5FEGWIP/AkJDmPSXtODqVmeV4hX5hSz
sn1BNzv01g/kG+im4V49lOFFr99wgaWc7Fv7YeFIblL0d5oZwtXA5JypdeViLPkf
jl/xkaMa8pzCa3ZQ2y+vG77b1RAmE5Gb2pYtjvAzRAoppytuRYtyPWoJV6oz+LnA
v5jo1bwgCr72thFTkgWl7s7Y5szK7fl6OLR25ypBrbS4bIAe1yBe5A9UwWPjVfQa
NGiLxoeCCcojqZw2L7bbbnB+eas1sU3HqDUOP6HvdBsuB1Lduzxj5Du6eMvLDluA
qJjkwKG/BdLnaKGs1wj8DaJvUiC99M0O/80BuH9c2vIAEow4RGQvGcC2Gzbcp+Hp
yB60CO4rZoZYyx9biLoekgEy4fdMPO/2ffLB3NAc+2g9U+291CVe6z9UhosKzWz2
JgJjRwFx925Vh28RfqFdsYjcEyWyBtjV0A3L8dsNf8dH5v4h+23hqr6xROqhQOhv
aqNFICS57F7I+Qjmyza98cZvJeXyOYAenflAnzfBFDZLA9eCdZZ2zcSkoGpfz7F5
OGNTQ0t2iJAesPN2zvsCI2+zJImYWWjuQaoy77KSP/Yr69dWuaJoHXjx+1I4cg0e
+iFBMfvLqTlYCWXyaz95wBjTWa6pAUXnB7yeqQwTsdo9THxcFjMTAWxyirfqgOcF
/PNS631pylZcbD5TlX64
=VzFl
-----END PGP SIGNATURE-----

--Signature=_Mon__17_Jun_2013_12_44_41_+1000_8Hlngt7fx_6iMMlb--
