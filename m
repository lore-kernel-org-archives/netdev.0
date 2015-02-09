From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the akpm-current tree with the net-next
 tree
Date: Mon, 9 Feb 2015 20:31:37 +1100
Message-ID: <20150209203137.798bede8@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_//9ZvTbS6.fccI5fqQGsl++H"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Andrey Ryabinin <a.ryabinin@samsung.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Al Viro <viro@zeniv.linux.org.uk>
To: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_//9ZvTbS6.fccI5fqQGsl++H
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

Today's linux-next merge of the akpm-current tree got a conflict in
lib/Makefile between commits 9d6dbe1bbaf8 ("rhashtable: Make selftest
modular") and 57dd8a0735aa ("vhost: vhost_scsi_handle_vq() should just
use copy_from_user()") from the net-next tree and commits f3d593d650ec
("hexdump: introduce test suite") and ("lib: add kasan test module")
from the akpm-current tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc lib/Makefile
index 25c061f77df7,87e55a1219bd..000000000000
--- a/lib/Makefile
+++ b/lib/Makefile
@@@ -23,8 -23,8 +23,8 @@@ lib-y	+=3D kobject.o klist.
  obj-y	+=3D lockref.o
 =20
  obj-y +=3D bcd.o div64.o sort.o parser.o halfmd4.o debug_locks.o random32=
.o \
- 	 bust_spinlocks.o hexdump.o kasprintf.o bitmap.o scatterlist.o \
+ 	 bust_spinlocks.o kasprintf.o bitmap.o scatterlist.o \
 -	 gcd.o lcm.o list_sort.o uuid.o flex_array.o iovec.o clz_ctz.o \
 +	 gcd.o lcm.o list_sort.o uuid.o flex_array.o clz_ctz.o \
  	 bsearch.o find_last_bit.o find_next_bit.o llist.o memweight.o kfifo.o \
  	 percpu-refcount.o percpu_ida.o rhashtable.o reciprocal_div.o
  obj-y +=3D string_helpers.o
@@@ -35,7 -37,7 +37,8 @@@ obj-$(CONFIG_TEST_LKM) +=3D test_module.
  obj-$(CONFIG_TEST_USER_COPY) +=3D test_user_copy.o
  obj-$(CONFIG_TEST_BPF) +=3D test_bpf.o
  obj-$(CONFIG_TEST_FIRMWARE) +=3D test_firmware.o
 +obj-$(CONFIG_TEST_RHASHTABLE) +=3D test_rhashtable.o
+ obj-$(CONFIG_TEST_KASAN) +=3D test_kasan.o
 =20
  ifeq ($(CONFIG_DEBUG_KOBJECT),y)
  CFLAGS_kobject.o +=3D -DDEBUG

--Sig_//9ZvTbS6.fccI5fqQGsl++H
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJU2H59AAoJEMDTa8Ir7ZwVhTMQAJMmn7DV2cLEb6X2dkPZZx5R
J6Z2cGFzPmDm/pl69YS7Iks6jLZhHqAgugRYE04YpBu6Jjhr62AF6UAMaH4N2ApI
Tp/QDoI9PJJh7y/C6QKs542ppF8fA8qflbO6PGORMYbSKqwQYdmwU18ThaLTJavH
RA6vM30XzEOj1Pm44fo+gp0OaRAHUFUSmcA76yEsiEba17w3wKvyvwi4Ni530XFE
FuzY/yzx7FU+jUEBwELuos2w5j0MxBAQEfJhwkCFUXgcA4MrvsxviPlo2Mksgdo6
sOFrMOQ6FDFKPHFeUrqEVJEAfzYefveFJNfCeVDGmphst/yot65TvDD/oQK0GTSB
WyQhiJuypxL9e39b4W9YAMLlsh4CYcQmuHdfwk2MA6NKf3jBCLVlDq/iEMTnKPHH
wV/vM75GfgMrrRjEenLoxKjZBcUGt21qzPRvSzAQjudK8qPnXTr84cS1SBOaVR6A
CyztLOfFv/WQ6TV5u4XNoAKoRQHfKoudqtPueJvD38ISSoEtlZF2Uzm29Uu+hqCu
SXUIxdHQH4E+57GZyp8zqz7oqVV6uxeRj+iBXoucDwAMBS23mYlHkR3C0+varg5N
bh5OT+m9kCBQx2e6RutZm7+0mYQJC2+IkOtLfAlMAtVXmTBjMWO4RLACkkqL3Gmz
uxR+8M/0dmBPOqA3E3JA
=4cpk
-----END PGP SIGNATURE-----

--Sig_//9ZvTbS6.fccI5fqQGsl++H--
