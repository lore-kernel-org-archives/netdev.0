From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: CONFIG_FIXED_PHY breaks fec on arm/mx51
Date: Thu, 5 Aug 2010 17:17:32 +0200
Message-ID: <20100805151732.GA14527@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bryan Wu <bryan.wu@canonical.com>,
	Andy Whitcroft <apw@canonical.com>,
	Amit Kucheria <amit.kucheria@canonical.com>,
	Stefan Bader <stefan.bader@canonical.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:54149 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756019Ab0HEPRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 11:17:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

when I enable CONFIG_FIXED_PHY my mx51evm board fails to initialize the
fec network device.  The relevant kernel log is:

	...
	Fixed MDIO Bus: probed
	FEC Ethernet Driver
	------------[ cut here ]------------
	WARNING: at /ptx/work/octopus/WORK_2_A/ukl/backup/gsrc/linux-2.6/fs/sy=
sfs/dir.c:451 sysfs_add_one+0x6c/0x8c()
	sysfs: cannot create duplicate filename '/class/mdio_bus/0'
	Modules linked in:
	Backtrace:=20
	[<c0026484>] (dump_backtrace+0x0/0x10c) from [<c02b6158>] (dump_stack+=
0x18/0x1c)
	 r7:df839d60 r6:c00db380 r5:c03434df r4:000001c3
	[<c02b6140>] (dump_stack+0x0/0x1c) from [<c003750c>] (warn_slowpath_co=
mmon+0x58/0x88)
	[<c00374b4>] (warn_slowpath_common+0x0/0x88) from [<c00375e0>] (warn_s=
lowpath_fmt+0x38/0x40)
	 r8:df84a480 r7:ffffffef r6:df839db0 r5:df811000 r4:df8dc600
	[<c00375a8>] (warn_slowpath_fmt+0x0/0x40) from [<c00db380>] (sysfs_add=
_one+0x6c/0x8c)
	 r3:df811000 r2:c0343523
	[<c00db314>] (sysfs_add_one+0x0/0x8c) from [<c00dc398>] (sysfs_do_crea=
te_link+0xfc/0x1c8)
	 r7:df8e8648 r6:00000000 r5:df8dc600 r4:df8dc570
	[<c00dc29c>] (sysfs_do_create_link+0x0/0x1c8) from [<c00dc490>] (sysfs=
_create_link+0x14/0x18)
	[<c00dc47c>] (sysfs_create_link+0x0/0x18) from [<c01e1918>] (device_ad=
d+0x198/0x520)
	[<c01e1780>] (device_add+0x0/0x520) from [<c01e1cc0>] (device_register=
+0x20/0x24)
	[<c01e1ca0>] (device_register+0x0/0x24) from [<c01ffbfc>] (mdiobus_reg=
ister+0x90/0x178)
	 r4:df8e8600
	[<c01ffb6c>] (mdiobus_register+0x0/0x178) from [<c02b5f50>] (fec_probe=
+0x39c/0x48c)
	[<c02b5bb4>] (fec_probe+0x0/0x48c) from [<c01e4fb4>] (platform_drv_pro=
be+0x20/0x24)
	[<c01e4f94>] (platform_drv_probe+0x0/0x24) from [<c01e3ec8>] (driver_p=
robe_device+0xb0/0x188)
	[<c01e3e18>] (driver_probe_device+0x0/0x188) from [<c01e400c>] (__driv=
er_attach+0x6c/0x90)
	 r7:df839f00 r6:c03abe0x58/0x98)
	 r6:c03abe08 r5:c01e3fa0 r4:00000000
	[<c01e3668>] (bus_for_each_dev+0x0/0x98) from [<c01e3d24>] (driver_att=
ach+0x20/0x28)
	 r7:df8db1e0 r6:c03abe08 r5:c03abe08 r4:c001e498
	[<c01e3d04>] (driver_attach+0x0/0x28) from [<c01e2f2c>] (bus_add_drive=
r+0xa4/0x228)
	[<c01e2e88>] (bus_add_driver+0x0/0x228) from [<c01e4338>] (driver_regi=
ster+0xc8/0x154)
	[<c01e4270>] (driver_register+0x0/0x154) from [<c01e5410>] (platform_d=
river_register+0x4c/0x60)
	 r8:00000000 r7:00000000 r6:c00187a8 r5:c001e4f8 r4:c001e498
	[<c01e53c4>] (platform_driver_register+0x0/0x60) from [<c00187c4>] (fe=
c_enet_module_init+0x1c/0x28)
	[<c00187a8>] (fec_enet_module_init+0x0/0x28) from [<c0022384>] (do_one=
_initcall+0x64/0x1c4)
	[<c0022320>] (do_one_initcall+0x0/0x1c4) from [<c00085f4>] (kernel_ini=
t+0xa0/0x154)
	 r7:00000013 r6:c003a7dc r5:c001e4f8 r4:c001e498
	[<c0008554>] (kernel_init+0x0/0x154) from [<c003a7dc>] (do_exit+0x0/0x=
564)
	 r5:c0008554 r4:00000000
	---[ end trace 1220371fd8e97d24 ]---
	mii_bus 0 failed to register
	...

As far as I understand the problem this is just that both drivers
(drivers/net/phy/fixed.c and drivers/net/fec.c) try to register a
mdio_bus with the same number.  There isn't a mechanism to circumvent
this problem, e.g. some auto-increment logic that just isn't used, is
there?

The people from Ubuntu had the same problem (Cc:d):
http://kernel.ubuntu.com/git?p=3Dubuntu/ubuntu-lucid.git;a=3Dcommitdiff=
;h=3D0e5e6e2a981eeab61dcc184d51ab769a33af6589

(I used Linus' tree as of today (3a09b1be53d2) plus a few unrelated
patches with mx51_defconfig.)

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
