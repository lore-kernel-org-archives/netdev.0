From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 23 Mar 2015 14:08:41 +1100
Message-ID: <20150323140841.0b807b95@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_//aICTucY+xLsjne6JNWB4N1"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_//aICTucY+xLsjne6JNWB4N1
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/netfilter/nf_tables_core.c between commit 4017a7ee693d ("netfilter:
restore rule tracing via nfnetlink_log") from the net tree and commit
01ef16c2dd2e ("netfilter: nf_tables: minor tracing cleanups") from the
net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/netfilter/nf_tables_core.c
index 2d298dccb6dd,77165bf023f3..000000000000
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@@ -21,6 -21,48 +21,48 @@@
  #include <net/netfilter/nf_tables.h>
  #include <net/netfilter/nf_log.h>
 =20
+ enum nft_trace {
+ 	NFT_TRACE_RULE,
+ 	NFT_TRACE_RETURN,
+ 	NFT_TRACE_POLICY,
+ };
+=20
+ static const char *const comments[] =3D {
+ 	[NFT_TRACE_RULE]	=3D "rule",
+ 	[NFT_TRACE_RETURN]	=3D "return",
+ 	[NFT_TRACE_POLICY]	=3D "policy",
+ };
+=20
+ static struct nf_loginfo trace_loginfo =3D {
+ 	.type =3D NF_LOG_TYPE_LOG,
+ 	.u =3D {
+ 		.log =3D {
+ 			.level =3D 4,
+ 			.logflags =3D NF_LOG_MASK,
+ 	        },
+ 	},
+ };
+=20
+ static void __nft_trace_packet(const struct nft_pktinfo *pkt,
+ 			       const struct nft_chain *chain,
+ 			       int rulenum, enum nft_trace type)
+ {
+ 	struct net *net =3D dev_net(pkt->in ? pkt->in : pkt->out);
+=20
 -	nf_log_packet(net, pkt->xt.family, pkt->ops->hooknum, pkt->skb, pkt->in,
 -		      pkt->out, &trace_loginfo, "TRACE: %s:%s:%s:%u ",
 -		      chain->table->name, chain->name, comments[type],
 -		      rulenum);
++	nf_log_trace(net, pkt->xt.family, pkt->ops->hooknum, pkt->skb, pkt->in,
++		     pkt->out, &trace_loginfo, "TRACE: %s:%s:%s:%u ",
++		     chain->table->name, chain->name, comments[type],
++		     rulenum);
+ }
+=20
+ static inline void nft_trace_packet(const struct nft_pktinfo *pkt,
+ 				    const struct nft_chain *chain,
+ 				    int rulenum, enum nft_trace type)
+ {
+ 	if (unlikely(pkt->skb->nf_trace))
+ 		__nft_trace_packet(pkt, chain, rulenum, type);
+ }
+=20
  static void nft_cmp_fast_eval(const struct nft_expr *expr,
  			      struct nft_data data[NFT_REG_MAX + 1])
  {

--Sig_//aICTucY+xLsjne6JNWB4N1
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVD4O+AAoJEMDTa8Ir7ZwVI74P/1HJ4Lvx1MbMhq3LaaovIjVr
XW+Np8Gb9cr10eYTmcXaThNQ18uYJmuUznSyUceqnFKSeqy+PNLqR7hlRlR0iiRA
tZmIJx3XhzXH9QdxLsO2EJHjBgYJxmrpgnjA8cU7wwFXEl/e+EjPv3C7lpIMifgA
rsRCFv1H0TuSgE1e/xzc7Pkn5qrzZBrHOEAQJyhoUeCAGL738g8bd2NXs7zv05Pb
7a7mSPAzyNHQ13ZJuZ4MSqNWmVVx9kxzv+uVWz/k4Z/AP9BMjh2pieuYEtH9dDfg
cmKgyGbl0oBbh3aLTbnubnIrs24Ywxn/0ojuv58QJq8ePZqExUy+hbUHG8nMBc0s
TDPgn30YI4fNpq09oGyGPQ+q1cba3/jzgMNCjwuw0foLfhS6fn9vkJgrJYfEVUms
9Bi05AixB9zufboXSHWpTRenh8A55Kno/BLLFAtDVqy40IAbcEfFiwlzxd5TrZgl
91kxezMqqOGoLD5Q4ZrUU+Gf2itVzI1ZlzPEop8PMCNQFBLtB6fbWfB6yy9Ns7M1
kFlhYIGzlql1oQu8A+ewA2eg7rR+got+PY7vo/eu4dfZJ6Xu9iYVDiBwK995XYry
/BErib1qxkRcoy2HWvEeK5gT+c09aUGw8kNwQ7LoFPkLkDWB6QCnSz6p8fJ43uZB
HY+qOq4y0cfvyKTG3CT3
=G4Gf
-----END PGP SIGNATURE-----

--Sig_//aICTucY+xLsjne6JNWB4N1--
