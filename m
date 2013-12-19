From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Thu, 19 Dec 2013 11:57:10 +1100
Message-ID: <20131219115710.598bdf6314b4784703a07100@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__19_Dec_2013_11_57_10_+1100_sMBsM=5Z.QfvcA=h"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Francesco Fusco <ffusco@redhat.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:45364 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751386Ab3LSA5Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 19:57:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Thu__19_Dec_2013_11_57_10_+1100_sMBsM=5Z.QfvcA=h
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (powerpc
ppc64_defconfig) failed like this:

lib/hash.c:16:43: error: expected '=3D', ',', ';', 'asm' or '__attribute__'=
 before '__read_mostly'
 static struct fast_hash_ops arch_hash_ops __read_mostly =3D {
                                           ^
lib/hash.c: In function 'arch_fast_hash':
lib/hash.c:23:9: error: 'arch_hash_ops' undeclared (first use in this funct=
ion)
  return arch_hash_ops.hash(data, len, seed);
         ^
lib/hash.c:23:9: note: each undeclared identifier is reported only once for=
 each function it appears in
lib/hash.c: In function 'arch_fast_hash2':
lib/hash.c:29:9: error: 'arch_hash_ops' undeclared (first use in this funct=
ion)
  return arch_hash_ops.hash2(data, len, seed);
         ^
lib/hash.c: In function 'hashlib_init':
lib/hash.c:35:24: error: 'arch_hash_ops' undeclared (first use in this func=
tion)
  setup_arch_fast_hash(&arch_hash_ops);
                        ^
lib/hash.c: In function 'arch_fast_hash':
lib/hash.c:24:1: warning: control reaches end of non-void function [-Wretur=
n-type]
 }
 ^
lib/hash.c: In function 'arch_fast_hash2':
lib/hash.c:30:1: warning: control reaches end of non-void function [-Wretur=
n-type]
 }
 ^

Caused by commit 71ae8aac3e19 ("lib: introduce arch optimized hash
library").  Read Rule 1 in Documentation/SubmitChecklist :-(  Hint:
__read_mostly is defined in linux/cache.h ...

I have used the net-next tree from next-20131217 again today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__19_Dec_2013_11_57_10_+1100_sMBsM=5Z.QfvcA=h
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSskRqAAoJEMDTa8Ir7ZwVMCMP/jlSDsGT/WS7270mnE4BKu5H
5TBfT16CyKGicv2x8pAgJdUrja3D0D0y1r8KHQg4UQvt5g7QR0lPSpx/ROK0xc3Z
djAHf0i0u/x+yKNHy9sSSrYbzpj7NzFF620wcOLUmUvE+g1EENGU8mbF8ibjMhix
OQOW5BUMF+BcQe5O9IKEOiQZ67N0FSvlwVZOBJjMsMrXnK1nktEvmBO40ortlIKK
fg1TukffhxsK9tZdHlrwJD95+GqV8vYS921WeAyCqM84FjXFnBa0KSvqwY8Ek5z1
NOmoGEGKnCuDrVACTgv/PNs9lpQ8fDxCUFx8JGlbV+1CzVyY73jCax86/dPjNIts
I6uyyfwTsGItncQOa7oRiPDyx9m/Mf6eCOy6WyJbwnltUncr9v1NOKVCiz4Tn1sj
vxXMRpkvLhuvVNygdFjpXajmpTA5grq35PRnSRtrUuaLDKS9pgVf2/BghRyySjPJ
22CIQ9ys9oZC+wQZMPkQxjKSrKNaV5P+ufzrB4U80zPVBJ5WSi/5KqPn9E8zUoZQ
rJMcAWLO4mtXgCNPo13i/tWPQ5DyiR0rdQmWZBsFJ9Aqu3Q5pQA7GtHqcJWx29uY
7WyIFsBudgu1a52GYeZlvPxu8kCtOoVdn7FGSs3jyeNvf47JMgBkxjVQt6C9yAMG
dNyPBqQpMit/WRT4AbWS
=4zXz
-----END PGP SIGNATURE-----

--Signature=_Thu__19_Dec_2013_11_57_10_+1100_sMBsM=5Z.QfvcA=h--
