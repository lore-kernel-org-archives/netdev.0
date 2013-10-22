From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] igb: Add EEPROM IO stubs for iNVM
Date: Tue, 22 Oct 2013 03:45:53 -0700
Message-ID: <1382438753.6455.8.camel@jtkirshe-mobl>
References: <1382412123-4782-1-git-send-email-marex@denx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-fs9Gy6/10NyYaM3hT2cf"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Marek Vasut <marex@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:64218 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752340Ab3JVKp6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Oct 2013 06:45:58 -0400
In-Reply-To: <1382412123-4782-1-git-send-email-marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-fs9Gy6/10NyYaM3hT2cf
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2013-10-22 at 05:22 +0200, Marek Vasut wrote:
> Add stub functions for EEPROM operations in case where the i210 is
> used without external EEPROM. The EEPROM operations must not be set
> to NULL, since otherwise we will get a backtrace when attempting the
> command below. Once such place to trigger this is from igb_ethtool.c
> igb_set_eeprom(), where hw->nvm.ops.write() is called without first
> checking if .write() is valid . By grepping through the code, there
> are more such occasions which assume .write() to be always valid.
> Thus, instead of poluting the code with checks, add stubs. I believe
> it'd be prefferable to possibly even implement those functions, but
> my knowledge of the adapter is still limited and as far as I
> understand,
> the iNVM is programmable only once.
>=20
> Command:
>=20
> $ ethtool -E eth0 magic 0x157b8086 offset 6 value 0x1b
>=20
> Backtrace:
>=20
> Unable to handle kernel NULL pointer dereference at virtual address
> 00000000
> pgd =3D be7ac000
> [00000000] *pgd=3D4e6a6831, *pte=3D00000000, *ppte=3D00000000
> Internal error: Oops: 80000007 [#1] SMP ARM
> CPU: 2 PID: 59 Comm: ethtool Not tainted 3.12.0-rc6+ #8
> task: bf8f3600 ti: be73c000 task.ti: be73c000
> PC is at 0x0
> LR is at igb_set_eeprom+0x27c/0x3b4
> pc : [<00000000>]    lr : [<803bc780>]    psr: 20000013
> sp : be73dd80  ip : 00000000  fp : be73ddf4
> r10: 00000001  r9 : 00000003  r8 : be6d6000
> r7 : bfa64a38  r6 : be6d7000  r5 : bfa64000  r4 : be73de20
> r3 : be6d6000  r2 : 00000001  r1 : 00000003  r0 : bfa64a38
> Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
> Control: 10c53c7d  Table: 4e7ac04a  DAC: 00000015
> Process ethtool (pid: 59, stack limit =3D 0xbe73c240)
> Stack: (0xbe73dd80 to 0xbe73e000)
> dd80: 803c7e2c 803c8554 00000000 00000000 00000000 803c827c 00000004
> 00000000
> dda0: 00000000 00000000 00010800 00080008 00000008 be73ddc0 800d1a34
> 8054db6c
> ddc0: be6d6000 00000003 00ad97c8 00000001 be73c000 bfa64000 be6d7000
> 80584d58
> dde0: be73de20 00ad97d8 be73de7c be73ddf8 80465e00 803bc510 be73de14
> be6d7000
> de00: e4114bb3 00000000 be73de6c 0000000c 8055048c 80076b5c 00000002
> 00000000
> de20: 0000000c 157b8086 00000006 00000001 8094cac0 be73c000 00000000
> 00000000
> de40: be73de7c 00008946 8094cac0 7e8cfcf4 be73de98 00008946 8094cac0
> 7e8cfcf4
> de60: be73de98 be73c000 00000000 00000000 be73dee4 be73de80 80474f54
> 804656ac
> de80: 000000a8 00000200 be73dec4 be73de98 80077c7c 80076b5c 30687465
> 00000000
> dea0: 00000000 00000000 00ad97c8 00000000 00000000 00000000 be73c000
> 00008946
> dec0: fffffdfd 7e8cfcf4 7e8cfcf4 7e8cfcf4 bf18c020 00000000 be73df04
> be73dee8
> dee0: 80449c18 80474ac8 80449b94 00008946 be6b0600 00000003 be73df74
> be73df08
> df00: 800e6d10 80449ba0 be6b0600 00030002 be6b5f40 be6b5f40 be73df3c
> be73df28
> df20: 80554b2c 802b03e8 be6b5f6c be6b5f00 be73df5c be73c000 8000ea44
> be73c000
> df40: 8000eab0 bf8f3600 00000001 00008946 00000003 00000000 7e8cfcf4
> be6b0600
> df60: be73c000 00000000 be73dfa4 be73df78 800e72ac 800e6c98 be73df94
> 00000000
> df80: 80076b64 0002bd0c 00000000 0002bcc8 00000036 8000ebe4 00000000
> be73dfa8
> dfa0: 8000ea20 800e7278 0002bd0c 00000000 00000003 00008946 7e8cfcf4
> 7e8cfcf4
> dfc0: 0002bd0c 00000000 0002bcc8 00000036 00000000 00000000 00000000
> 7e8cfb84
> dfe0: 7e8cfe65 7e8cfb78 0001201c 0004535c 20000010 00000003 00000000
> 00000000
> Backtrace:
> [<803bc504>] (igb_set_eeprom+0x0/0x3b4) from [<80465e00>] (dev_ethtool
> +0x760/0x1f68)
> [<804656a0>] (dev_ethtool+0x0/0x1f68) from [<80474f54>] (dev_ioctl
> +0x498/0x86c)
> [<80474abc>] (dev_ioctl+0x0/0x86c) from [<80449c18>] (sock_ioctl
> +0x84/0x258)
> [<80449b94>] (sock_ioctl+0x0/0x258) from [<800e6d10>] (do_vfs_ioctl
> +0x84/0x5e0)
>  r6:00000003 r5:be6b0600 r4:00008946 r3:80449b94
> [<800e6c8c>] (do_vfs_ioctl+0x0/0x5e0) from [<800e72ac>] (SyS_ioctl
> +0x40/0x68)
> [<800e726c>] (SyS_ioctl+0x0/0x68) from [<8000ea20>] (ret_fast_syscall
> +0x0/0x48)
>  r8:8000ebe4 r7:00000036 r6:0002bcc8 r5:00000000 r4:0002bd0c
> Code: bad PC value
> ---[ end trace 59379e9bf8fc8437 ]---
>=20
> Signed-off-by: Marek Vasut <marex@denx.de>
> Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Cc: Aaron Brown <aaron.f.brown@intel.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: David S. Miller <davem@davemloft.net>
> ---
>  drivers/net/ethernet/intel/igb/e1000_i210.c | 46
> +++++++++++++++++++++++++++--
>  1 file changed, 43 insertions(+), 3 deletions(-)

Thanks Marek, I have added the patch to my queue.

--=-fs9Gy6/10NyYaM3hT2cf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSZldhAAoJEOVv75VaS+3OW04P/A7oUFO9CG72Ij+0u+gOS9OC
60Nd1gn3V/TEBDLFfCXpmhqPEECwpgn8wbHPgRuhxkMEmcTllj3tr2qDpvYo3pwr
9XOxQptloKfEbckRNGJuM+9R5TXtg9e4Sz6qiRgeRr1ikM7LIJAVGrbIFCVyGGtW
akpAzKEm2Am4HezkJrPjY5eH2Clhw2gWhJ0UwZLhzXDgX3/9CNE+Vsaq5f8cJCYZ
z90Ay0g05xgOCq58xM04YycoqXEvpxl5mGtP7jKt57NVx+WqFmbVB6d1RxTHuNmr
g+5Phb+cpgLij44yza7abzONFQgf9AtX/odLvbK/pEdYVzZm1+0uqqa5CMaxShql
eLg4cK/xd0wbQ1fXeEqc3OgYnOlgJpDJsUMGdOtKya7uPXbHBq/UJ9IMsyjV4Vvx
CmB1MsxoaOTuZoicBeDAkOcN7kKc00z9sHzRNjOyusOz2+MlCrzc50mLTByYg7uT
e0ETMEqfgB46WN/HMyhefVpCZZIrT0uvr42jwaGzoOKCAkp9vjrqkEuEa7SwSRIq
F9jI4rfX+cHw3Khlu/DrBymADiKKcpAYRlv+0T8XURLNsKGhMSZaCYo0Bz1cJlz0
NtC1EEafwNOd54ZrXwOqXERa/XRBp3U3ljlVdNGhXZoZA9aZ8rp5XBKKsPKo5tZW
/4flZXAvXkRxuOJ/Kgus
=LQpk
-----END PGP SIGNATURE-----

--=-fs9Gy6/10NyYaM3hT2cf--
