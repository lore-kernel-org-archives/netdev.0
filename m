From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next] i40e: Fix dependencies in the i40e driver on configfs
Date: Tue, 03 Mar 2015 13:04:40 -0800
Message-ID: <1425416680.2556.92.camel@jtkirshe-mobl>
References: <1425415135-10257-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20150303.154515.1426526534548261925.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-i9wVK/dte3o5X3RuUjdm"
Cc: gregory.v.rose@intel.com, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55535 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755450AbbCCVEl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Mar 2015 16:04:41 -0500
In-Reply-To: <20150303.154515.1426526534548261925.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-i9wVK/dte3o5X3RuUjdm
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-03-03 at 15:45 -0500, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Tue,  3 Mar 2015 12:38:55 -0800
>=20
> > From: Greg Rose <gregory.v.rose@intel.com>
> >=20
> > Module dependencies are broken in the case where CONFIG_I40E=3Dy and
> > CONFIG_CONFIGFS_FS=3Dm.  This fixes the broken dependency.
> >=20
> > Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
> This doesn't fix anything, nothing tests I40E_CONFIGFS_FS:
>=20
> [davem@abraco net-next]$ make -s -j8
> scripts/Makefile.kasan:16: Cannot use CONFIG_KASAN: -fsanitize=3Dkernel-a=
ddress is not supported by compiler
> scripts/Makefile.kasan:16: Cannot use CONFIG_KASAN: -fsanitize=3Dkernel-a=
ddress is not supported by compiler
> kernel/Makefile:133: *** No X.509 certificates found ***
> kernel/Makefile:133: *** No X.509 certificates found ***
> drivers/built-in.o: In function `i40e_cfgfs_group_make_item':
> i40e_configfs.c:(.text+0x192db7): undefined reference to `config_item_ini=
t_type_name'
> drivers/built-in.o: In function `i40e_configfs_init':
> (.text+0x192df1): undefined reference to `config_group_init'
> drivers/built-in.o: In function `i40e_configfs_init':
> (.text+0x192e25): undefined reference to `configfs_register_subsystem'
> drivers/built-in.o: In function `i40e_configfs_exit':
> (.text+0x192e7a): undefined reference to `configfs_unregister_subsystem'
> make: *** [vmlinux] Error 1
> [davem@abraco net-next]$ git am --signoff diff
> Applying: i40e: Fix dependencies in the i40e driver on configfs
> [davem@abraco net-next]$ make oldconfig
> scripts/kconfig/conf --oldconfig Kconfig
> #
> # configuration written to .config
> #
> [davem@abraco net-next]$ make -s -j8
> scripts/Makefile.kasan:16: Cannot use CONFIG_KASAN: -fsanitize=3Dkernel-a=
ddress is not supported by compiler
> scripts/Makefile.kasan:16: Cannot use CONFIG_KASAN: -fsanitize=3Dkernel-a=
ddress is not supported by compiler
> kernel/Makefile:133: *** No X.509 certificates found ***
> kernel/Makefile:133: *** No X.509 certificates found ***
> drivers/built-in.o: In function `i40e_cfgfs_group_make_item':
> i40e_configfs.c:(.text+0x192db7): undefined reference to `config_item_ini=
t_type_name'
> drivers/built-in.o: In function `i40e_configfs_init':
> (.text+0x192df1): undefined reference to `config_group_init'
> drivers/built-in.o: In function `i40e_configfs_init':
> (.text+0x192e25): undefined reference to `configfs_register_subsystem'
> drivers/built-in.o: In function `i40e_configfs_exit':
> (.text+0x192e7a): undefined reference to `configfs_unregister_subsystem'
> make: *** [vmlinux] Error 1
> [davem@abraco net-next]$=20

Sorry it appears there were two issues that we needed to resolve.  The
first was the issue found with a randonconfig build where if the i40e
was compiled into the kernel and configfs was module, which this was
trying to correct.

The checks in the driver need to be changed from CONFIG_CONFIGFS_FS to
checking for CONFIG_I40E_CONFIGFS_FS, now that there is a Kconfig
option.

--=-i9wVK/dte3o5X3RuUjdm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU9iHoAAoJEOVv75VaS+3O1BQP/1wBujXkFEErwZGF3B+8/Yp/
gmMOJz4cDHq37Vb4mYEgWlf6MskikRzaQYO+5Ybj4pbZK+Hf/hCS8BZkErpGOW6B
agG1yIwbLBBpP2dZbaiaaxkP98mE8T8JYtxbjjgSjGraQ8AtdsQfcZhIhX69e5q+
3Ab52TLECLLdIAWAoRd4s7AzD4wOX1mLjRgtVfPCDkWgOc3UilLhvv6G7MU1KY5N
0jJz6dmUGie86U5xBFGmIyY2nnVRi/QW6rDGqmGwBCs2x0/Oj+eCNLm8FYlbSkuG
qsuvnPR20pXYAstEVt118asWpFnVSBgA2AyoR3JO71AWF71QUUX+MRipYtAdcP2D
P9skwTR8swSud8OhpFEigOAxMqiFHNm7W15UagmgIP1/e4QV4XJ291RVmA3XfaW1
DLmCRRWc6yRwIY/BX0JFJVba0v7J9MIqsSZ6tuqmmJCmzggdeRyafS8Lxt8OSXBo
yEq5ITE4ZmpAWvCQ+jnvvo2COM5zG+R6V5E1THIX1+/MEs2M/xOBot5FWWf0Xtnn
C/BQxtj2rSoNZLvWD40P9RfTHx8hS5kJIt0CNM0i8PWw2F0ea+K2Y5aYZF0zjpl4
Ky4+y+KX/4/o7Gk7naqc9uMGLG/T0FpQmD2hh30FhyiPzLwBKHJuC9bzNnKoaT6M
SL70Kj3A69U+owTOlmcw
=bCBA
-----END PGP SIGNATURE-----

--=-i9wVK/dte3o5X3RuUjdm--
