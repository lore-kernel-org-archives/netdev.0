From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net tree
Date: Tue, 20 May 2014 10:59:52 +1000
Message-ID: <20140520105952.73f6adab@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/KnBHmZDs9tZ6Gey/dRoMe6q"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Vlad Yasevich <vyasevic@redhat.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/KnBHmZDs9tZ6Gey/dRoMe6q
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net tree, today's linux-next build (powerpc
ppc64_defconfig) failed like this:


In file included from arch/powerpc/net/bpf_jit_comp.c:16:0:
include/linux/if_vlan.h: In function 'vlan_get_encap_level':
include/linux/if_vlan.h:491:2: error: implicit declaration of function 'vla=
n_dev_priv' [-Werror=3Dimplicit-function-declaration]
  return vlan_dev_priv(dev)->nest_level;
  ^
include/linux/if_vlan.h:491:27: error: invalid type argument of '->' (have =
'int')
  return vlan_dev_priv(dev)->nest_level;
                           ^

Caused by commit 44a4085538c8 ("bonding: Fix stacked device detection
in arp monitoring").

vlan_dev_priv() is protected by:

#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)

but the newly added call in vlan_get_encap_level() is not.

I have used the net tree from next-20140519 for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/KnBHmZDs9tZ6Gey/dRoMe6q
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTeqkNAAoJEMDTa8Ir7ZwVO4oP/3oXziwWreT3K+Tf7FiZ9HaH
Kfj3b1sJYFkyn5eRNoBs5I0YncwYyufq3LfBP/LNrlWum7ZfaXw2cjdjSkRKt/vZ
hZizhlGPix5AmfJCIGvxyHej1ib4lwpG/Kmrrqzn4AaweMflLD8Aq2aIQ+X02LaH
7Tpy+xAvdsUoBXgjIBt+mFKk+DCeOb3NyZa2q7lgv3k4JmVREYOaG/x6t65yBhea
4GFeobaHiTBAAyBhuilrQWV7pHFndUKkKTr9eZqKtAecrOueSR44x8AJlKO36E7V
hYOYc9GrtYq87DzT+v+IFqNNER40Ua1VwvTXh8UTHNUpKoHp0CEwYkUsv3esJfCO
1kEmnAHFTTy9e+esO7rJEV627u/RIN9hik+LAGdD35vOZKr8nzeuVIDQdW8GyQY9
Npuzo5WNOqCISOWXULeKVDjiQdsqsjzFjGhffbX1M/piKxNwgC2M68xthFwfX9En
MQs9gCrhlI0+aQSzeIedMWZzyDTm8ZW4ELzgI0ocHVNA+I0y7c5kwzBsbjWerVmo
fKZxSPv/ovx1FKskpq2wQcneH8Jd67ZcxIu+kVvh/dxfmSx4VnNDAVHp+nI6GV4p
fUHVElRkFGTTcmYTa0gN8vrbh5dAfTkgUux3Ykea3FwKFUjs90Keur/YX8McgMWX
kCc9LgwIlXtRipx+43dy
=upfj
-----END PGP SIGNATURE-----

--Sig_/KnBHmZDs9tZ6Gey/dRoMe6q--
