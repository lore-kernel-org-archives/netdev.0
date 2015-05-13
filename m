From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Wed, 13 May 2015 13:05:23 +1000
Message-ID: <20150513130523.714f64a6@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/9GVYvmhXQXJ5d/UViK6uq7J"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/9GVYvmhXQXJ5d/UViK6uq7J
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/core/net_namespace.c between commit e3d8ecb70e16 ("netns: return
RTM_NEWNSID instead of RTM_GETNSID on a get") from the net tree and
commit cab3c8ec8d57 ("netns: always provide the id to rtnl_net_fill()")
from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/core/net_namespace.c
index 572af0011997,a665bf490c88..000000000000
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@@ -600,8 -639,9 +639,9 @@@ static int rtnl_net_getid(struct sk_buf
  		goto out;
  	}
 =20
+ 	id =3D peernet2id(net, peer);
  	err =3D rtnl_net_fill(msg, NETLINK_CB(skb).portid, nlh->nlmsg_seq, 0,
- 			    RTM_NEWNSID, net, peer, -1);
 -			    RTM_GETNSID, net, id);
++			    RTM_NEWNSID, net, id);
  	if (err < 0)
  		goto err_out;
 =20

--Sig_/9GVYvmhXQXJ5d/UViK6uq7J
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVUr94AAoJEMDTa8Ir7ZwVeLkP/0aOKs10PWv0SVofj54XK2jF
uGwjDZ7IvXg8h7Y2pdXiMDLtzzzWV/907WbM3r+ei4gE5N3dIiV/RDmBRFts8lXC
rD2GjeRV6zHSQeZZGX3Tz2MxnyP2kt02WfbSmkZ5bJ0jaFTfEdjt/OhGm7U+IRlQ
r/jOy0Qb2+DTY5W5kbRkSRgysCKZCFRtZS/1a/erIuw2yyp2K0AJS+ir5Xa2aV0s
t3EbGuXvBpc20U/SRGsJccVowsiV3tcsh0oUAXyRvwvsuGbDLiiL8HkI2RiZ8LC4
JxsVEaXIl24TafJFd3WhV3uBqCuGgtSC2TQF9TW3p2Jw1pjntlQGuGa2E0YIaEo4
vjCeiz5R9pM9dzWfV3iYpIgX4zxNgQhRXz61ZiV8hMNHb/4290vzSYs45VOdlUQZ
txjqDpNxjg0E/Jn0LIenLDoRib297KVF0hbjlsLWizxkxNbYTSVIbtXmQOH//ace
eUeRyR0srC5afT7L1126PjFfGKTSnO49XoBbgpIjUoD7aD5/1XyOP/M2ZALDKTvC
mKXxAde31bdzJmysH0qqrGGa7V3L03H3drT2iwz5RhJHYjDEsvec+Dwf8AxA9ZG/
thTqEQz5sR1r/cbs1gsK/iCiAiC/RBLFTjG9QChpLJdN8iUyoWykLfhkwRp0FH9l
fouUetnODoEopRkSp06z
=r3AZ
-----END PGP SIGNATURE-----

--Sig_/9GVYvmhXQXJ5d/UViK6uq7J--
