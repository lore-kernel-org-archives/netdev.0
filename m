From: Martin Michlmayr <tbm@cyrius.com>
Subject: Clash of fixed MDIO bus and mv643xx_eth
Date: Mon, 16 Feb 2009 21:32:11 +0100
Message-ID: <20090216203210.GA20361@deprecation.cyrius.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lennert Buytenhek <buytenh@wantstofly.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sorrow.cyrius.com ([65.19.161.204]:37035 "EHLO
	sorrow.cyrius.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751566AbZBPUcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 15:32:22 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I ran into the problem below.  Lennert Buytenhek suggested turning off
CONFIG_FIXED_PHY as a workaround, which indeed works.

[42949394.480000] input: gpio-keys as /devices/platform/gpio-keys/input/input0
[42949394.820000] MV-643xx 10/100/1000 ethernet driver version 1.4
[42949394.830000] ------------[ cut here ]------------
[42949394.830000] WARNING: at fs/sysfs/dir.c:462 sysfs_add_one+0x34/0x48()
[42949394.840000] sysfs: duplicate filename '0' can not be created
[42949394.850000] Modules linked in: mv643xx_eth(+) gpio_keys usbcore(+) ext3 jbd mbcache sd_mod crc_t10dif sata_mv libata scsi_mod
[42949394.860000] [<c002c1e4>] (dump_stack+0x0/0x14) from [<c0045154>] (warn_slowpath+0x64/0x80)
[42949394.870000] [<c00450f0>] (warn_slowpath+0x0/0x80) from [<c00f66c4>] (sysfs_add_one+0x34/0x48)
[42949394.880000]  r3:c092cec0 r2:c02b4948
[42949394.880000]  r6:c7a29bf0 r5:c7307338 r4:ffffffef
[42949394.880000] [<c00f6690>] (sysfs_add_one+0x0/0x48) from [<c00f765c>] (sysfs_do_create_link+0xc8/0x174)
[42949394.890000]  r5:c7307338 r4:c73073c8
[42949394.900000] [<c00f7594>] (sysfs_do_create_link+0x0/0x174) from [<c00f7734>] (sysfs_create_link+0x14/0x18)
[42949394.910000]  r8:c0839ccc r7:00000000 r6:c0839c04 r5:c0839c40 r4:c0839c40
[42949394.920000] [<c00f7720>] (sysfs_create_link+0x0/0x18) from [<c0172904>] (device_add+0x184/0x468)
[42949394.920000] [<c0172780>] (device_add+0x0/0x468) from [<c0172c08>] (device_register+0x20/0x24)
[42949394.930000] [<c0172be8>] (device_register+0x0/0x24) from [<c017abd8>] (mdiobus_register+0x8c/0x14c)
[42949394.940000]  r4:c0839c00
[42949394.950000] [<c017ab4c>] (mdiobus_register+0x0/0x14c) from [<bf0e28b0>] (mv643xx_eth_shared_probe+0x158/0x3ac [mv643xx_eth])
[42949394.960000]  r7:bf0e5020 r6:bf0e5020 r5:c02eb7b0 r4:c0877b60
[42949394.960000] [<bf0e2758>] (mv643xx_eth_shared_probe+0x0/0x3ac [mv643xx_eth]) from [<c01759b0>] (platform_drv_probe+0x20/0x24)
[42949394.980000] [<c0175990>] (platform_drv_probe+0x0/0x24) from [<c0174bdc>] (driver_probe_device+0xf4/0x1a8)
[42949394.980000] [<c0174ae8>] (driver_probe_device+0x0/0x1a8) from [<c0174cfc>] (__driver_attach+0x6c/0x90)
[42949394.990000]  r6:c02eb204 r5:bf0e5020 r4:c02eb158
[42949395.000000] [<c0174c90>] (__driver_attach+0x0/0x90) from [<c0174110>] (bus_for_each_dev+0x4c/0x84)
[42949395.010000]  r6:c0174c90 r5:c7a29d50 r4:00000000
[42949395.010000] [<c01740c4>] (bus_for_each_dev+0x0/0x84) from [<c01749fc>] (driver_attach+0x20/0x28)
[42949395.020000]  r7:00000000 r6:c087d200 r5:bf0e5020 r4:00000000
[42949395.030000] [<c01749dc>] (driver_attach+0x0/0x28) from [<c01745ac>] (bus_add_driver+0xa8/0x218)
[42949395.040000] [<c0174504>] (bus_add_driver+0x0/0x218) from [<c0174f00>] (driver_register+0x98/0x11c)
[42949395.050000] [<c0174e68>] (driver_register+0x0/0x11c) from [<c0175b70>] (platform_driver_register+0x78/0x94)
[42949395.060000] [<c0175af8>] (platform_driver_register+0x0/0x94) from [<bf0e8018>] (mv643xx_eth_init_module+0x18/0x48 [mv643xx_eth])
[42949395.070000] [<bf0e8000>] (mv643xx_eth_init_module+0x0/0x48 [mv643xx_eth]) from [<c00272e0>] (do_one_initcall+0x68/0x1ac)
[42949395.080000]  r4:c0308fe4
[42949395.080000] [<c0027278>] (do_one_initcall+0x0/0x1ac) from [<c006abd0>] (sys_init_module+0x98/0x188)
[42949395.090000]  r7:00000000 r6:4014d000 r5:bf0e5060 r4:000083ed
[42949395.100000] [<c006ab38>] (sys_init_module+0x0/0x188) from [<c0027da0>] (ret_fast_syscall+0x0/0x2c)
[42949395.110000]  r7:00000080 r6:00008edc r5:00000000 r4:401358d0
[42949395.110000] ---[ end trace ef14c6b761e28490 ]---
[42949395.120000] mii_bus 0 failed to register
[42949395.120000] mv643xx_eth: probe of mv643xx_eth.0 failed with error -12
[42949395.130000] Unable to handle kernel NULL pointer dereference at virtual address 00000004
[42949395.140000] pgd = c71b0000
[42949395.140000] [00000004] *pgd=0731f031, *pte=00000000, *ppte=00000000
[42949395.150000] Internal error: Oops: 17 [#1]
[42949395.150000] Modules linked in: mv643xx_eth(+) gpio_keys usbcore(+) ext3 jbd mbcache sd_mod crc_t10dif sata_mv libata scsi_mod
[42949395.150000] CPU: 0    Tainted: G        W   (2.6.28-1-orion5x #1)
[42949395.150000] PC is at mv643xx_eth_probe+0x174/0x654 [mv643xx_eth]
[42949395.150000] LR is at 0xac9b0800
[42949395.150000] pc : [<bf0e2278>]    lr : [<ac9b0800>]    psr: 20000013
[42949395.150000] sp : c7a29ca0  ip : 00000004  fp : c7a29cfc
[42949395.150000] r10: c0300e30  r9 : c7a28000  r8 : c0027f48
[42949395.150000] r7 : c083d000  r6 : c083d3c0  r5 : c02ecb20  r4 : c02ecb2c
[42949395.150000] r3 : 00000001  r2 : 00000000  r1 : 00000088  r0 : 00000000
[42949395.150000] Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
[42949395.150000] Control: a005317f  Table: 071b0000  DAC: 00000015
[42949395.150000] Process modprobe (pid: 808, stack limit = 0xc7a28268)
[42949395.150000] Stack: (0xc7a29ca0 to 0xc7a2a000)
[42949395.150000] 9ca0: c00f7678 c00f695c c02eb288 c742f668 00000000 00000001 c00f6c94 c02eb2f8 
[42949395.150000] 9cc0: c02eb290 00000000 bf0e4fd0 c0027f48 c7a29cec c02eb290 bf0e4fd0 bf0e4fd0 
[42949395.150000] 9ce0: bf0e4fd0 c0027f48 c7a28000 c0300e30 c7a29d0c c7a29d00 c01759b0 bf0e2114 
[42949395.150000] 9d00: c7a29d2c c7a29d10 c0174bdc c01759a0 c7a29d2c c02eb290 bf0e4fd0 c02eb33c 
[42949395.150000] 9d20: c7a29d4c c7a29d30 c0174cfc c0174af8 c7a29d4c 00000000 c7a29d50 c0174c90 
[42949395.150000] 9d40: c7a29d74 c7a29d50 c0174110 c0174ca0 c78034d8 c02eb2d8 00000000 bf0e4fd0 
[42949395.150000] 9d60: c087d1a0 00000000 c7a29d84 c7a29d78 c01749fc c01740d4 c7a29db4 c7a29d88 
[42949395.150000] 9d80: c01745ac c01749ec bf0e372c bf0e5060 bf0e4fd0 bf0e5060 bf0e8000 00000000 
[42949395.150000] 9da0: c0027f48 00000000 c7a29ddc c7a29db8 c0174f00 c0174514 00000000 bf0e5060 
[42949395.150000] 9dc0: bf0e8000 00000000 c0027f48 00000000 c7a29dec c7a29de0 c0175b70 c0174e78 
[42949395.150000] 9de0: c7a29e04 c7a29df0 bf0e8028 c0175b08 c00f6248 c0308fe4 c7a29f7c c7a29e08 
[42949395.150000] 9e00: c00272e0 bf0e8010 c7a29e2c c7a29e18 c00bcb74 c00bca68 c73074b8 c00f6248 
[42949395.150000] 9e20: c7a29e54 c7a29e30 c7a29e74 c7a29e38 c00f6968 c0237c70 c044fa20 c0307eb0 
[42949395.150000] 9e40: c7a29e74 c7a29e50 c008ae60 c0089810 c7a29e74 00000008 c895c000 c73f89a0 
[42949395.150000] 9e60: 00000001 bf0e5060 c7a29e84 c7a29e78 c008af1c c008acac c7a29e94 00000009 
[42949395.150000] 9e80: c895c000 c73f89a0 c7a29eb4 c7a29e98 c009ecac c00a76c8 c085b948 c085b920 
[42949395.150000] 9ea0: 00000001 00000001 c7a29ec4 c7a29eb8 c009ed44 c009ebf8 c7a29f7c c7a29ec8 
[42949395.150000] 9ec0: c006a9fc c009ed18 00000000 c7a29f48 0001ba88 c895c000 c8962308 c89621f0 
[42949395.150000] 9ee0: c89622e0 00000000 c8961ecd c092c480 c89639e0 00000015 0000000c 00000000 
[42949395.150000] 9f00: 000000e6 000000e6 bf0e3740 c7a28000 00000017 c8962330 00000000 00000000 
[42949395.150000] 9f20: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
[42949395.150000] 9f40: 000083ed bf0e5060 4014d000 00000000 c0027f48 00000000 c7a29f7c c7a29f68 
[42949395.150000] 9f60: 000083ed bf0e5060 4014d000 00000000 c7a29fa4 c7a29f80 c006abd0 c0027288 
[42949395.150000] 9f80: 00000000 00008edc 401358d0 00000000 00008edc 00000080 00000000 c7a29fa8 
[42949395.150000] 9fa0: c0027da0 c006ab48 401358d0 00000000 4014d000 000083ed 0001ba88 000083ed 
[42949395.150000] 9fc0: 401358d0 00000000 00008edc 00000080 00000000 00000000 40025000 be8169e4 
[42949395.150000] 9fe0: 00000000 be81695c 0000b6b0 400e8f34 60000010 4014d000 00000000 00000000 
[42949395.150000] Backtrace: 
[42949395.150000] [<bf0e2104>] (mv643xx_eth_probe+0x0/0x654 [mv643xx_eth]) from [<c01759b0>] (platform_drv_probe+0x20/0x24)
[42949395.150000] [<c0175990>] (platform_drv_probe+0x0/0x24) from [<c0174bdc>] (driver_probe_device+0xf4/0x1a8)
[42949395.150000] [<c0174ae8>] (driver_probe_device+0x0/0x1a8) from [<c0174cfc>] (__driver_attach+0x6c/0x90)
[42949395.150000]  r6:c02eb33c r5:bf0e4fd0 r4:c02eb290
[42949395.150000] [<c0174c90>] (__driver_attach+0x0/0x90) from [<c0174110>] (bus_for_each_dev+0x4c/0x84)
[42949395.150000]  r6:c0174c90 r5:c7a29d50 r4:00000000
[42949395.150000] [<c01740c4>] (bus_for_each_dev+0x0/0x84) from [<c01749fc>] (driver_attach+0x20/0x28)
[42949395.150000]  r7:00000000 r6:c087d1a0 r5:bf0e4fd0 r4:00000000
[42949395.150000] [<c01749dc>] (driver_attach+0x0/0x28) from [<c01745ac>] (bus_add_driver+0xa8/0x218)
[42949395.150000] [<c0174504>] (bus_add_driver+0x0/0x218) from [<c0174f00>] (driver_register+0x98/0x11c)
[42949395.150000] [<c0174e68>] (driver_register+0x0/0x11c) from [<c0175b70>] (platform_driver_register+0x78/0x94)
[42949395.150000] [<c0175af8>] (platform_driver_register+0x0/0x94) from [<bf0e8028>] (mv643xx_eth_init_module+0x28/0x48 [mv643xx_eth])
[42949395.150000] [<bf0e8000>] (mv643xx_eth_init_module+0x0/0x48 [mv643xx_eth]) from [<c00272e0>] (do_one_initcall+0x68/0x1ac)
[42949395.150000]  r4:c0308fe4
[42949395.150000] [<c0027278>] (do_one_initcall+0x0/0x1ac) from [<c006abd0>] (sys_init_module+0x98/0x188)
[42949395.150000]  r7:00000000 r6:4014d000 r5:bf0e5060 r4:000083ed
[42949395.150000] [<c006ab38>] (sys_init_module+0x0/0x188) from [<c0027da0>] (ret_fast_syscall+0x0/0x2c)
[42949395.150000]  r7:00000080 r6:00008edc r5:00000000 r4:401358d0
[42949395.150000] Code: e35100ff 0a000036 e5960000 e3510000 (e5903004) 
[42949395.630000] ---[ end trace ef14c6b761e28490 ]---
[42949395.740000] usbcore: registered new device driver usb
[42949395.800000] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
udevd-event[807]: run_program: '/sbin/modprobe' abnormal exit

-- 
Martin Michlmayr
http://www.cyrius.com/
