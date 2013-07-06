From: Jonas Gorski <jogo@openwrt.org>
Subject: Re: Second ethernet on kirkwood does not work when probed through
 DT
Date: Sat, 6 Jul 2013 23:39:12 +0200
Message-ID: <20130706233912.00004044@unknown>
References: <20130706215426.6e666d6af0dc6c9ea5fe32cd@openwrt.org>
	<51D88A8E.1060104@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51D88A8E.1060104@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 06 Jul 2013 23:22:22 +0200
Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com> wrote:

> On 07/06/2013 09:54 PM, Jonas Gorski wrote:
> > Hello Sebastian,
> >
> > using your DT patches[1] (on top of 3.10) I can't get the second
> > ethernet to work on my kirkwood board.
> 
> Hi Jonas,
> 
> next time please name your board, because there are plenty of it.
> Kirkwood is just the SoC used on them.

Oops, sorry. It's D-Link DIR-665, with a 6281. Currently not upstream,
but mostly supported (the switch isn't supported by DSA but works fine
without it).

 
> > in my dts file I use:
> >
> > &mdio { status = "okay"; };
> >
> > &eth0 { status = "okay"; ethernet0-port@0 { speed =<1000>; duplex
> > =<1>; }; };
> >
> 
> I guess you are using Iomega IX2 200?
> 
> > &eth1 { status = "okay"; ethernet1-port@1 { speed =<1000>; duplex
> > =<1>; }; };
> >
> > (Both macs are connected to a switch, so use a fixed link, and no
> > phy).
> >
> > Eth1 gets probed fine, but never gets a link when brought up, and
> > trying to bring it down again hangs the board hard.
> >
> > Using Florian's older patches, it is brought up fine and works (after
> > adapting the node names of course).
> >
> > Also I noticed that you named eth1's ethernet1-port node wrongly in
> > (at least) your kirkwood conversion patch[2]; you used
> >
> > &eth1 { status = "okay"; ethernet1-port@0 { must be @1--^ phy-handle
> > =<&ethphy1>; }; };
> 
> Can you please try to leave ethernet1-port@0 and match
> the one in kirkwood.dtsi?
> 
> Both "ports" need reg = <0> as there is two controllers
> with one port at 0 on Kirkwood.

kirkwood.dtsi itself says ethernet1-port@1 with reg = <1>.

Changing reg to 0 for eth1 brings:

[    9.586915] ------------[ cut here ]------------
[    9.591590] WARNING: at fs/sysfs/dir.c:530 sysfs_add_one+0x88/0xa8()
[    9.597973] sysfs: cannot create duplicate filename '/devices/platform/mv643xx_eth_port.0'
[    9.606286] Modules linked in:
[    9.609366] CPU: 0 PID: 1 Comm: swapper Not tainted 3.10.0 #12
[    9.615231] Backtrace:
[    9.617714] [<c001352c>] (dump_backtrace+0x0/0x114) from [<c00136d4>] (show_stack+0x18/0x1c)
[    9.626205]  r6:00000212 r5:c02cd6e0 r4:c782fbe0 r3:00000000
[    9.631972] [<c00136bc>] (show_stack+0x0/0x1c) from [<c010a080>] (dump_stack+0x20/0x28)
[    9.640024] [<c010a060>] (dump_stack+0x0/0x28) from [<c001bdf4>] (warn_slowpath_common+0x58/0x74)
[    9.648958] [<c001bd9c>] (warn_slowpath_common+0x0/0x74) from [<c001beb4>] (warn_slowpath_fmt+0x38/0x40)
[    9.658492]  r8:c780d288 r7:c7823000 r6:c782fc28 r5:c73c1c88 r4:c782fc04
r3:00000009
[    9.666436] [<c001be7c>] (warn_slowpath_fmt+0x0/0x40) from [<c00ccdf4>] (sysfs_add_one+0x88/0xa8)
[    9.675357]  r3:c7823000 r2:c02cd750
[    9.678964]  r4:ffffffef
[    9.681539] [<c00ccd6c>] (sysfs_add_one+0x0/0xa8) from [<c00ccfd4>] (create_dir+0x70/0xc0)
[    9.689836]  r7:c78c64d8 r6:00000000 r5:c73c1c88 r4:00002001
[    9.695577] [<c00ccf64>] (create_dir+0x0/0xc0) from [<c00cd358>] (sysfs_create_dir+0xbc/0xdc)
[    9.704165] [<c00cd29c>] (sysfs_create_dir+0x0/0xdc) from [<c010bde4>] (kobject_add_internal+0xb8/0x1e4)
[    9.713698]  r6:c07ae3b0 r5:c78c64d8 r4:c78c64d8
[    9.718375] [<c010bd2c>] (kobject_add_internal+0x0/0x1e4) from [<c010c1ec>] (kobject_add+0x80/0x98)
[    9.727487] [<c010c16c>] (kobject_add+0x0/0x98) from [<c015f6d0>] (device_add+0xd8/0x54c)
[    9.735708]  r3:00000000 r2:00000000
[    9.739315]  r6:00000000 r5:c78c64d0 r4:c78c64c0
[    9.744002] [<c015f5f8>] (device_add+0x0/0x54c) from [<c0163348>] (platform_device_add+0x14c/0x1e0)
[    9.753117] [<c01631fc>] (platform_device_add+0x0/0x1e0) from [<c0193014>] (mv643xx_eth_shared_of_add_port+0x240/0x2a8)
[    9.763962]  r8:00000e00 r7:c73b1b70 r6:0000003e r5:00000000 r4:c78c64c0
r3:00000000
[    9.771899] [<c0192dd4>] (mv643xx_eth_shared_of_add_port+0x0/0x2a8) from [<c01932a8>] (mv643xx_eth_shared_probe+0x22c/0x318)
[    9.783172]  r5:c08ea74c r4:c08ea89c
[    9.786790] [<c019307c>] (mv643xx_eth_shared_probe+0x0/0x318) from [<c0162ef0>] (platform_drv_probe+0x1c/0x20)
[    9.796860] [<c0162ed4>] (platform_drv_probe+0x0/0x20) from [<c0161df8>] (driver_probe_device+0xe4/0x210)
[    9.806493] [<c0161d14>] (driver_probe_device+0x0/0x210) from [<c0161f8c>] (__driver_attach+0x68/0x8c)
[    9.815853]  r7:00000000 r6:c07b3f64 r5:c785bdb0 r4:c785bde4
[    9.821594] [<c0161f24>] (__driver_attach+0x0/0x8c) from [<c0160714>] (bus_for_each_dev+0x58/0x90)
[    9.830600]  r6:c07b3f64 r5:c0161f24 r4:00000000 r3:00000002
[    9.836329] [<c01606bc>] (bus_for_each_dev+0x0/0x90) from [<c016192c>] (driver_attach+0x20/0x28)
[    9.845162]  r6:c07ae368 r5:c07b3f64 r4:c73ad4a0
[    9.849836] [<c016190c>] (driver_attach+0x0/0x28) from [<c01614ec>] (bus_add_driver+0xb8/0x21c)
[    9.858596] [<c0161434>] (bus_add_driver+0x0/0x21c) from [<c016227c>] (driver_register+0xa8/0x138)
[    9.867606]  r8:0000003e r7:00000000 r6:c07b3f64 r5:c033dd5c r4:c034200c
[    9.874409] [<c01621d4>] (driver_register+0x0/0x138) from [<c016301c>] (platform_driver_register+0x4c/0x60)
[    9.884216] [<c0162fd0>] (platform_driver_register+0x0/0x60) from [<c0335f48>] (mv643xx_eth_init_module+0x14/0x44)
[    9.894633] [<c0335f34>] (mv643xx_eth_init_module+0x0/0x44) from [<c0010b50>] (do_one_initcall+0x9c/0x15c)
[    9.904335]  r4:c034200c r3:00000000
[    9.907956] [<c0010ab4>] (do_one_initcall+0x0/0x15c) from [<c0322938>] (kernel_init_freeable+0xf8/0x1c4)
[    9.917512] [<c0322840>] (kernel_init_freeable+0x0/0x1c4) from [<c000c338>] (kernel_init+0x10/0x104)
[    9.926709] [<c000c328>] (kernel_init+0x0/0x104) from [<c0008a30>] (ret_from_fork+0x14/0x24)
[    9.935196]  r4:00000000 r3:00000000
[    9.938838] ---[ end trace 026e20e7bf6738e2 ]---
[    9.943497] ------------[ cut here ]------------
[    9.948142] WARNING: at lib/kobject.c:196 kobject_add_internal+0x17c/0x1e4()
[    9.955238] kobject_add_internal failed for mv643xx_eth_port.0 with -EEXIST, don't try to register things with the same name in the same directory.
[    9.968521] Modules linked in:
[    9.971611] CPU: 0 PID: 1 Comm: swapper Tainted: G        W    3.10.0 #12
[    9.978423] Backtrace:
[    9.980907] [<c001352c>] (dump_backtrace+0x0/0x114) from [<c00136d4>] (show_stack+0x18/0x1c)
[    9.989377]  r6:000000c4 r5:c02dd9d8 r4:c782fc60 r3:00000000
[    9.995120] [<c00136bc>] (show_stack+0x0/0x1c) from [<c010a080>] (dump_stack+0x20/0x28)
[   10.003181] [<c010a060>] (dump_stack+0x0/0x28) from [<c001bdf4>] (warn_slowpath_common+0x58/0x74)
[   10.012118] [<c001bd9c>] (warn_slowpath_common+0x0/0x74) from [<c001beb4>] (warn_slowpath_fmt+0x38/0x40)
[   10.021654]  r8:c07ae3a8 r7:c07ae3b0 r6:c07ae3b0 r5:c78c64d8 r4:c782fc84
r3:00000009
[   10.029582] [<c001be7c>] (warn_slowpath_fmt+0x0/0x40) from [<c010bea8>] (kobject_add_internal+0x17c/0x1e4)
[   10.039287]  r3:c02dd9c0 r2:c02ddb40
[   10.042911]  r4:c78c64d8
[   10.045470] [<c010bd2c>] (kobject_add_internal+0x0/0x1e4) from [<c010c1ec>] (kobject_add+0x80/0x98)
[   10.054578] [<c010c16c>] (kobject_add+0x0/0x98) from [<c015f6d0>] (device_add+0xd8/0x54c)
[   10.062804]  r3:00000000 r2:00000000
[   10.066411]  r6:00000000 r5:c78c64d0 r4:c78c64c0
[   10.071098] [<c015f5f8>] (device_add+0x0/0x54c) from [<c0163348>] (platform_device_add+0x14c/0x1e0)
[   10.080207] [<c01631fc>] (platform_device_add+0x0/0x1e0) from [<c0193014>] (mv643xx_eth_shared_of_add_port+0x240/0x2a8)
[   10.091049]  r8:00000e00 r7:c73b1b70 r6:0000003e r5:00000000 r4:c78c64c0
r3:00000000
[   10.098977] [<c0192dd4>] (mv643xx_eth_shared_of_add_port+0x0/0x2a8) from [<c01932a8>] (mv643xx_eth_shared_probe+0x22c/0x318)
[   10.110252]  r5:c08ea74c r4:c08ea89c
[   10.113870] [<c019307c>] (mv643xx_eth_shared_probe+0x0/0x318) from [<c0162ef0>] (platform_drv_probe+0x1c/0x20)
[   10.123938] [<c0162ed4>] (platform_drv_probe+0x0/0x20) from [<c0161df8>] (driver_probe_device+0xe4/0x210)
[   10.133571] [<c0161d14>] (driver_probe_device+0x0/0x210) from [<c0161f8c>] (__driver_attach+0x68/0x8c)
[   10.142932]  r7:00000000 r6:c07b3f64 r5:c785bdb0 r4:c785bde4
[   10.148662] [<c0161f24>] (__driver_attach+0x0/0x8c) from [<c0160714>] (bus_for_each_dev+0x58/0x90)
[   10.157670]  r6:c07b3f64 r5:c0161f24 r4:00000000 r3:00000002
[   10.163409] [<c01606bc>] (bus_for_each_dev+0x0/0x90) from [<c016192c>] (driver_attach+0x20/0x28)
[   10.172241]  r6:c07ae368 r5:c07b3f64 r4:c73ad4a0
[   10.176914] [<c016190c>] (driver_attach+0x0/0x28) from [<c01614ec>] (bus_add_driver+0xb8/0x21c)
[   10.185674] [<c0161434>] (bus_add_driver+0x0/0x21c) from [<c016227c>] (driver_register+0xa8/0x138)
[   10.194686]  r8:0000003e r7:00000000 r6:c07b3f64 r5:c033dd5c r4:c034200c
[   10.201497] [<c01621d4>] (driver_register+0x0/0x138) from [<c016301c>] (platform_driver_register+0x4c/0x60)
[   10.211301] [<c0162fd0>] (platform_driver_register+0x0/0x60) from [<c0335f48>] (mv643xx_eth_init_module+0x14/0x44)
[   10.221720] [<c0335f34>] (mv643xx_eth_init_module+0x0/0x44) from [<c0010b50>] (do_one_initcall+0x9c/0x15c)
[   10.231422]  r4:c034200c r3:00000000
[   10.235042] [<c0010ab4>] (do_one_initcall+0x0/0x15c) from [<c0322938>] (kernel_init_freeable+0xf8/0x1c4)
[   10.244588] [<c0322840>] (kernel_init_freeable+0x0/0x1c4) from [<c000c338>] (kernel_init+0x10/0x104)
[   10.253784] [<c000c328>] (kernel_init+0x0/0x104) from [<c0008a30>] (ret_from_fork+0x14/0x24)
[   10.262274]  r4:00000000 r3:00000000
[   10.265882] ---[ end trace 026e20e7bf6738e3 ]---
[   10.270553] mv643xx_eth: probe of f1076000.ethernet-controller failed with error -17



Regards
Jonas
