From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the tip tree with the net-next tree
Date: Thu, 11 Apr 2013 14:03:06 +1000
Message-ID: <20130411140306.e5c3366fea7ac2f7aadd77ff@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__11_Apr_2013_14_03_06_+1000_aLriROILgGdq=io+"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <dborkman@redhat.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Borislav Petkov <bp@suse.de>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__11_Apr_2013_14_03_06_+1000_aLriROILgGdq=io+
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the tip tree got a conflict in tools/Makefile
between commit e306e2c13b8c ("filter: add minimal BPF JIT image
disassembler") from the net-next tree and commit 85c66be101e1 ("perf
tools: Introduce tools/lib/lk library") from the tip tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc tools/Makefile
index c73c635,6aaeb6c..0000000
--- a/tools/Makefile
+++ b/tools/Makefile
@@@ -35,7 -34,13 +35,13 @@@ help
  cpupower: FORCE
  	$(call descend,power/$@)
 =20
- cgroup firewire lguest perf usb virtio vm net: FORCE
 -cgroup firewire guest usb virtio vm: FORCE
++cgroup firewire guest usb virtio vm net: FORCE
+ 	$(call descend,$@)
+=20
+ liblk: FORCE
+ 	$(call descend,lib/lk)
+=20
+ perf: liblk FORCE
  	$(call descend,$@)
 =20
  selftests: FORCE
@@@ -63,7 -68,13 +69,13 @@@ install: cgroup_install cpupower_instal
  cpupower_clean:
  	$(call descend,power/cpupower,clean)
 =20
- cgroup_clean firewire_clean lguest_clean perf_clean usb_clean virtio_clea=
n vm_clean net_clean:
 -cgroup_clean firewire_clean lguest_clean usb_clean virtio_clean vm_clean:
++cgroup_clean firewire_clean lguest_clean usb_clean virtio_clean vm_clean =
net_clean:
+ 	$(call descend,$(@:_clean=3D),clean)
+=20
+ liblk_clean:
+ 	$(call descend,lib/lk,clean)
+=20
+ perf_clean: liblk_clean
  	$(call descend,$(@:_clean=3D),clean)
 =20
  selftests_clean:

--Signature=_Thu__11_Apr_2013_14_03_06_+1000_aLriROILgGdq=io+
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRZjX6AAoJEECxmPOUX5FEdXMP/3S6l+AezrpDV8tbcvaDgQE4
JXPftURvrnM3SThx2iQ3PVCCIBv001lGMHSAKOeKjXQ2Ma/u7K2iylMbY2MC448W
eb2wh0RjGDBoe6PeMvXnktJqFLtsUO2gKVNamAs0HQw9WLV0/IhKnMbRzys7pN9l
CLPqPAftTfjweLX5/MEXQxCzFPFHyDtO3fUOi0mtRbytcBX82/3G0BsBWRknK8pe
+g13g8KiUQAngAWUkbNelEw5ElfqHe3A5EHVphkLV4L2nIvvuCDk1z7ngRV9D1Jl
iY32fNUOziK8t2dEgdAuBsRz5McCJLEErurgbbYbpQ+WekD5Y7vkspaagvAcw01D
0ZKhnrKwpYQcIUJEiN4vPVlibNJ56Bjdyqaemr9NLtjzp80Sxzyhgpe3OlNduSpP
6fUftPitOEZLL52MWChfs76cTL2T8xM4dCmjKneZ4GZaJj3P/YlZ7AsHlo653ibV
mIxI0JUKtqIDgUAydcn+5dMIdBv/+m5TeOcgcFMw0nd+WeFNl4or3LU6u3Dp/uuW
FU+OdtkSNRRBIz1eJ6ySHjYmgRd1z0FbqsL/5YuNWHgUj3FajzBzgcNNWZbjiD2B
kLPJh8hXj594U8ivinIQiN5K20A/FKSqZlpFfgcR2k7m9GRe/FgeFslI+J3SrEwM
RJlJWIdmGj0XxTe9oQso
=D4ct
-----END PGP SIGNATURE-----

--Signature=_Thu__11_Apr_2013_14_03_06_+1000_aLriROILgGdq=io+--
