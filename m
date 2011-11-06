From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the origin tree
Date: Mon, 7 Nov 2011 10:12:02 +1100
Message-ID: <20111107101202.96fcb76d580e5265bd99aeee@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__7_Nov_2011_10_12_02_+1100_Bu3e=1AuJqKkLT07"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__7_Nov_2011_10_12_02_+1100_Bu3e=1AuJqKkLT07
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Linus,

Starting with the origin tree, today's linux-next build (powerpc
ppc64_defconfig) failed like this:

drivers/net/ethernet/intel/ixgbe/ixgbe_main.c: In function 'ixgbe_set_inter=
rupt_capability':
drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:4724:3: error: implicit decla=
ration of function 'ixgbe_disable_sriov'
drivers/net/ethernet/intel/ixgbe/ixgbe_main.c: In function 'ixgbe_remove':
drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:7773:3: error: implicit decla=
ration of function 'ixgbe_check_vf_assignment'

Caused by commit 9487dc844054 ("ixgbe: Fix compiler warnings") which hid
the declarations of ixgbe_disable_sriov() and ixgbe_check_vf_assignment()
when CONFIG_PCI_IOV is not defined.

I have reverted that commit for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__7_Nov_2011_10_12_02_+1100_Bu3e=1AuJqKkLT07
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJOtxRCAAoJEECxmPOUX5FE0YoP/3K3tJkPzrzI4G5HUuC9r7hu
leD55/bXhI87iuHiluFLZHFhTGagbjIGQkWF3fXY/lNz3R/qU+E5Z+RmkP9pJ3p+
wTI52FK76l9LwTUqfj4Yjyt7DWV+5fCMKBJ0WhBwSy7BQzXnq+CccwWbrod7bxKa
jwKTRdFOMH+C9FtTGhavL06rqfrFbupIGe2dK9hfsjrnHW2JrorClHly0/gVvcqt
5Q2XfVAX+NkVcbwCAZ34XKS5R3eBU1hpb6N5JfX28x555GwjPzVIcANWRh6RtFSn
A+TvQ42Lt/pvrIsPWrwvUouBMuXbOOLz38iU1OLM9HFLhLMd7z83Ux/sEJ0c+Z8l
YZePi6yQdG3gAU5sstd99PKqpGH1dauiweyTEWOSWOGGpjhbhAclifnwpovuUwgZ
7Rh+kh29dHkNll23XaDiQc3npSyplMVPCH5Eb1FUfbFoysvKTsc7NqqUKxnlzHZJ
Jxjxmif/ker3ULNV3bhVvOAVJ3s5Ewc6SYO/xvAjpaxSLy5cdcPy9eB8SyzYTWds
qE7vdLL6ttyXGHes/oT590qfB76pEgkHKA5lF5GAkhfCp1jPiBFXH0V3F7F3tdw8
xh5XPI3TJPOLmfyjgBp45X4BJOFC5OlkdbR4tPynFjfh1rkubcD9R+UGZV78qQvJ
KjzmXbyuopzLQw27tJnB
=kUQX
-----END PGP SIGNATURE-----

--Signature=_Mon__7_Nov_2011_10_12_02_+1100_Bu3e=1AuJqKkLT07--
