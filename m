From: Amit Kucheria <amit.kucheria@verdurent.com>
Subject: Conflict when compiling-in CONFIG_FIXED_PHY
Date: Wed, 8 Sep 2010 23:13:16 +0300
Message-ID: <AANLkTi=J0gUzcj2O_MNCj=X-ZdgXgxG_ED57L7YQM+z9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:33377 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753636Ab0IHUNR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 16:13:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

When CONFIG_FIXED_PHY is compiled-in along with another driver (such
as CONFIG_FEC) that makes a call to mdiobus_register(), there is a
conflict in creation of mdio_bus class with id '0' as show in the boot
log below.

I am not sure what the real fix should be - to prevent compiling-in of
FIXED_PHY with such drivers in Kconfig or a smarter mechanism to
assign the bus id (idr?).

Regards,
Amit

--------------- Boot Log ---------------------

Fixed MDIO Bus: probed
FEC Ethernet Driver
------------[ cut here ]------------
WARNING: at /home/amit/work/sources/linux-amit-upstream.git/fs/sysfs/dir.c:451
sysfs_add_one+0x6c/0x8c()
sysfs: cannot create duplicate filename '/class/mdio_bus/0'
Modules linked in:
Backtrace:
[<c0027fd0>] (dump_backtrace+0x0/0x110) from [<c0277788>] (dump_stack+0x18/0x1c)
 r7:df839d50 r6:c00d54d0 r5:c02fa7ef r4:000001c3
[<c0277770>] (dump_stack+0x0/0x1c) from [<c0033ba4>]
(warn_slowpath_common+0x54/0x6c)
[<c0033b50>] (warn_slowpath_common+0x0/0x6c) from [<c0033c60>]
(warn_slowpath_fmt+0x38/0x40)
 r9:00000000 r8:df84e7e0 r7:ffffffef r6:df839da0 r5:df811000
r4:df9058d0
[<c0033c28>] (warn_slowpath_fmt+0x0/0x40) from [<c00d54d0>]
(sysfs_add_one+0x6c/0x8c)
 r3:df811000 r2:c02fa82e
[<c00d5464>] (sysfs_add_one+0x0/0x8c) from [<c00d6454>]
(sysfs_do_create_link+0xfc/0x1c8)
 r7:df8fd648 r6:00000000 r5:df9058d0 r4:df905840
[<c00d6358>] (sysfs_do_create_link+0x0/0x1c8) from [<c00d654c>]
(sysfs_create_link+0x14/0x18)
[<c00d6538>] (sysfs_create_link+0x0/0x18) from [<c01b12ac>]
(device_add+0x190/0x498)
[<c01b111c>] (device_add+0x0/0x498) from [<c01b15d0>]
(device_register+0x1c/0x20)
[<c01b15b4>] (device_register+0x0/0x20) from [<c01cd7b8>]
(mdiobus_register+0x90/0x178)
 r5:df8fd604 r4:df8fd600
[<c01cd728>] (mdiobus_register+0x0/0x178) from [<c02775d0>]
(fec_probe+0x3a4/0x494)
 r9:00000000 r8:df8ab320 r7:df8ab000 r6:df8ab320 r5:df8ab000
r4:df8fd600
[<c027722c>] (fec_probe+0x0/0x494) from [<c01b475c>]
(platform_drv_probe+0x20/0x24)
[<c01b473c>] (platform_drv_probe+0x0/0x24) from [<c01b3740>]
(driver_probe_device+0xb0/0x164)
[<c01b3690>] (driver_probe_device+0x0/0x164) from [<c01b385c>]
(__driver_attach+0x68/0x8c)
 r7:df8fe660 r6:c035046c r5:c033f434 r4:c033f400
[<c01b37f4>] (__driver_attach+0x0/0x8c) from [<c01b2f48>]
(bus_for_each_dev+0x50/0x84)
 r7:df8fe660 r6:c035046c r5:c01b37f4 r4:00000000
[<c01b2ef8>] (bus_for_each_dev+0x0/0x84) from [<c01b3584>]
(driver_attach+0x20/0x28)
 r6:c035046c r5:c035046c r4:c001c870
[<c01b3564>] (driver_attach+0x0/0x28) from [<c01b2820>]
(bus_add_driver+0xa4/0x224)
[<c01b277c>] (bus_add_driver+0x0/0x224) from [<c01b3b70>]
(driver_register+0xb0/0x138)
[<c01b3ac0>] (driver_register+0x0/0x138) from [<c01b4bc4>]
(platform_driver_register+0x4c/0x60)
 r9:00000000 r8:c0016e1c r7:00000013 r6:c0036c84 r5:c000855c
r4:c001c870
[<c01b4b78>] (platform_driver_register+0x0/0x60) from [<c0016e38>]
(fec_enet_module_init+0x1c/0x28)
[<c0016e1c>] (fec_enet_module_init+0x0/0x28) from [<c001f3d8>]
(do_one_initcall+0xd0/0x1a4)
[<c001f308>] (do_one_initcall+0x0/0x1a4) from [<c00085f8>]
(kernel_init+0x9c/0x154)
[<c000855c>] (kernel_init+0x0/0x154) from [<c0036c84>] (do_exit+0x0/0x574)
 r5:c000855c r4:00000000
---[ end trace 418edbd6819ced66 ]---
mii_bus 0 failed to register
