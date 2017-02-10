From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: cafe8df8b9bc clashes with DSA
Date: Fri, 10 Feb 2017 09:48:24 -0800
Message-ID: <ccabc2d3-9589-f4f5-cdab-ee3ba40e8bc7@gmail.com>
References: <77093903.194093.1486748785802.JavaMail.zimbra@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        maowenan@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:35008 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751831AbdBJRtu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 12:49:50 -0500
Received: by mail-qt0-f194.google.com with SMTP id s58so5425440qtc.2
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 09:48:27 -0800 (PST)
In-Reply-To: <77093903.194093.1486748785802.JavaMail.zimbra@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/10/2017 09:46 AM, Vivien Didelot wrote:
> Hi,
> 
> With latest net-next/master, both my ZII Rev B and Rev C boards crash at
> boot. Bisecting found the bad guy: cafe8df8b9bc ("net: phy: Fix lack of
> reference count on PHY driver"). Below is the stack trace at boot:

Fixed in the "net" tree with:

6d9f66ac7fec2a6ccd649e5909806dfe36f1fc25 ("net: phy: Fix PHY module
checks and NULL deref in phy_attach_direct()"), applies fine to net-next
as well.

> 
> 	<snip>
> 	libphy: mdio_mux: probed
> 	mdio_bus 0.1:00: mdio_device_register
> 	mv88e6085 0.1:00: switch 0x352 detected: Marvell 88E6352, revision 1
> 	libphy: /mdio-mux/mdio@1/switch0@0: probed
> 	libphy: mdio_mux: probed
> 	mdio_bus 0.2:00: mdio_device_register
> 	mv88e6085 0.2:00: switch 0x352 detected: Marvell 88E6352, revision 1
> 	mmc0: host does not support reading read-only switch, assuming write-enable
> 	random: fast init done
> 	mmc0: new high speed SDHC card at address 0001
> 	mmcblk0: mmc0:0001 L1BN2 3.86 GiB 
> 	 mmcblk0: p1
> 	libphy: /mdio-mux/mdio@2/switch1@0: probed
> 	libphy: mdio_mux: probed
> 	mdio_bus 0.4:00: mdio_device_register
> 	mv88e6085 0.4:00: switch 0x1a7 detected: Marvell 88E6185, revision 2
> 	libphy: /mdio-mux/mdio@4/switch2@0: probed
> 	DSA: switch 0 0 parsed
> 	DSA: switch 0 1 parsed
> 	DSA: switch 0 2 parsed
> 	DSA: tree 0 parsed
> 	Marvell 88E1540 !mdio-mux!mdio@1:00: attached PHY driver [Marvell 88E1540] (mii_bus:phy_addr=!mdio-mux!mdio@1:00, irq=212)
> 	Marvell 88E1540 !mdio-mux!mdio@1:01: attached PHY driver [Marvell 88E1540] (mii_bus:phy_addr=!mdio-mux!mdio@1:01, irq=213)
> 	Marvell 88E1540 !mdio-mux!mdio@1:02: attached PHY driver [Marvell 88E1540] (mii_bus:phy_addr=!mdio-mux!mdio@1:02, irq=214)
> 	Marvell 88E1540 !mdio-mux!mdio@2:00: attached PHY driver [Marvell 88E1540] (mii_bus:phy_addr=!mdio-mux!mdio@2:00, irq=237)
> 	Marvell 88E1540 !mdio-mux!mdio@2:01: attached PHY driver [Marvell 88E1540] (mii_bus:phy_addr=!mdio-mux!mdio@2:01, irq=238)
> 	Marvell 88E1540 !mdio-mux!mdio@2:02: attached PHY driver [Marvell 88E1540] (mii_bus:phy_addr=!mdio-mux!mdio@2:02, irq=239)
> 	Unable to handle kernel NULL pointer dereference at virtual address 00000008
> 	pgd = 80004000
> 	[00000008] *pgd=00000000
> 	Internal error: Oops: 17 [#1] ARM
> 	Modules linked in:
> 	CPU: 0 PID: 687 Comm: kworker/0:2 Not tainted 4.10.0-rc6 #115
> 	Hardware name: Freescale Vybrid VF5xx/VF6xx (Device Tree)
> 	Workqueue: events deferred_probe_work_func
> 	task: 9ecda000 task.stack: 9eca2000
> 	PC is at phy_attach_direct+0x50/0x1a8
> 	LR is at phy_connect_direct+0x24/0x5c
> 	pc : [<8046d688>]    lr : [<8046d8e0>]    psr: 600a0013
> 	sp : 9eca3ab8  ip : 9eca3ae8  fp : 9eca3ae4
> 	r10: 00000000  r9 : 00000002  r8 : 9ed02c00
> 	r7 : 00000000  r6 : 9ed32800  r5 : 00000000  r4 : 9ed03000
> 	r3 : 00000000  r2 : 00000000  r1 : 9ec62e00  r0 : 00000000
> 	Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
> 	Control: 10c53c7d  Table: 9ed28059  DAC: 00000051
> 	Process kworker/0:2 (pid: 687, stack limit = 0x9eca2208)
> 	Stack: (0x9eca3ab8 to 0x9eca4000)
> 	3aa0:                                                       00000002 9ed03000
> 	3ac0: 00000000 80634064 00000000 9fff7724 00000000 00000000 9eca3b04 9eca3ae8
> 	3ae0: 8046d8e0 8046d644 00000002 9ed32c60 00000000 9ed32800 9eca3b24 9eca3b08
> 	3b00: 80634174 8046d8c8 00000000 9ed32800 9f6b9000 9ec70210 9eca3b64 9eca3b28
> 	3b20: 806345c0 80634120 00000001 00000001 9ed32c60 9ec62e00 9f646e00 9fff7724
> 	3b40: 9f646e00 9ec70210 00000000 9f646f08 9ec70210 9ec70210 9eca3bbc 9eca3b68
> 	3b60: 806352a8 80634354 00000000 801f1dc8 9ec70210 9f646f04 9f646f08 9f646f08
> 	3b80: 9ec7001c 00000000 00000002 00000009 9eca3bbc 9ec62e00 9ec70010 9ec7001c
> 	3ba0: 00000000 9fff7450 00000000 0000000c 9eca3bf4 9eca3bc0 8047dabc 80634b48
> 	3bc0: 00000000 8123d2e4 9eca3be4 9eca3bd8 9ec62e00 81299770 81258d50 00000000
> 	3be0: 8123d2e4 00000000 9eca3c04 9eca3bf8 8046e9ec 8047d6fc 9eca3c3c 9eca3c08
> 	3c00: 8040c2bc 8046e9d0 9eca3c24 9eca3c18 80521d10 00000001 8123d2e4 9ec62e00
> 	3c20: 9eca3c88 8129974c 00000000 00000000 9eca3c5c 9eca3c40 8040c6d4 8040c04c
> 	3c40: 00000000 9eca3c88 8040c628 00000001 9eca3c84 9eca3c60 8040a0fc 8040c634
> 	3c60: 9f5e57dc 9f73ce34 8041659c 9ec62e00 9ec62e34 8123a150 9eca3cac 9eca3c88
> 	3c80: 8040be90 8040a094 9ec62e00 00000001 9ec62e08 9ec62e00 8123a150 00000000
> 	3ca0: 9eca3cbc 9eca3cb0 8040c76c 8040bddc 9eca3cdc 9eca3cc0 8040b254 8040c75c
> 	3cc0: 81252e00 9ec62e08 9ed02840 9ec62e00 9eca3d1c 9eca3ce0 80409010 8040b1cc
> 	3ce0: 9eca3d10 9eca3cf0 80407800 8040749c 9eca3d14 9fff7450 9ec62e00 00000000
> 	3d00: 9fff730c 9ed02840 9ec62e00 00000000 9eca3d34 9eca3d20 8046eb48 80408bfc
> 	3d20: 9fff7450 9ed02800 9eca3d74 9eca3d38 8052647c 8046eb18 9ec9a890 8046f210
> 	3d40: 80803490 8125e3a8 9eca3d6c 9fff730c 00000000 9f59ac10 9ec9a890 8046f210
> 	3d60: 80803490 9ec74ed0 9eca3dbc 9eca3d78 8046f428 8052639c 00000004 9ec9a740
> 	3d80: 9f5cf780 9ec9a714 9eca3dbc 00000004 803a8d88 9f59ac10 9ec9a710 9f59ac00
> 	3da0: fffffdfb 8123a2f8 00000000 00000003 9eca3de4 9eca3dc0 8046f658 8046f2a0
> 	3dc0: 00000000 8123a2f8 00000000 9f59ac10 9f59ac10 8123a2f8 9eca3e04 9eca3de8
> 	3de0: 8040e0b0 8046f5ec 9f59ac10 81299770 81258d50 00000000 9eca3e3c 9eca3e08
> 	3e00: 8040c2bc 8040e060 80521d10 805207f4 9eca3e3c 00000001 8123a2f8 9f59ac10
> 	3e20: 9eca3e88 00000000 00000000 81252518 9eca3e5c 9eca3e40 8040c6d4 8040c04c
> 	3e40: 00000000 9eca3e88 8040c628 00000001 9eca3e84 9eca3e60 8040a0fc 8040c634
> 	3e60: 9f4901dc 9f73f834 8041659c 9f59ac10 9f59ac44 81233b28 9eca3eac 9eca3e88
> 	3e80: 8040be90 8040a094 9f59ac10 00000001 9f59ac10 9f59ac10 81233b28 81258d50
> 	3ea0: 9eca3ebc 9eca3eb0 8040c76c 8040bddc 9eca3edc 9eca3ec0 8040b254 8040c75c
> 	3ec0: 00000000 9f59ac10 81233974 81233988 9eca3efc 9eca3ee0 8040b7f8 8040b1cc
> 	3ee0: 81233990 9ece9100 8120aecc 9ffdc100 9eca3f34 9eca3f00 8012f3dc 8040b7bc
> 	3f00: 8120aecc 81210980 8120aee0 8120aecc 9ece9118 81210980 8120aee0 9eca2038
> 	3f20: 8120aecc 9ece9100 9eca3f7c 9eca3f38 8012f860 8012f2c8 9ecefb58 9f4e9e94
> 	3f40: 81210980 9eca2000 00000000 8121542d 9ece9100 9ecefb40 00000000 9ecef900
> 	3f60: 9ece9100 8012f66c 9ecefb58 9f4e9e94 9eca3fac 9eca3f80 801352e8 8012f678
> 	3f80: 9eca2000 9ecef900 801351d4 00000000 00000000 00000000 00000000 00000000
> 	3fa0: 00000000 9eca3fb0 80108cd8 801351e0 00000000 00000000 00000000 00000000
> 	3fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
> 	3fe0: 00000000 00000000 00000000 00000000 00000013 00000000 00000000 00000000
> 	Backtrace: 
> 	[<8046d638>] (phy_attach_direct) from [<8046d8e0>] (phy_connect_direct+0x24/0x5c)
> 	 r10:00000000 r9:00000000 r8:9fff7724 r7:00000000 r6:80634064 r5:00000000
> 	 r4:9ed03000 r3:00000002
> 	[<8046d8bc>] (phy_connect_direct) from [<80634174>] (dsa_slave_phy_connect+0x60/0x80)
> 	 r6:9ed32800 r5:00000000 r4:9ed32c60 r3:00000002
> 	[<80634114>] (dsa_slave_phy_connect) from [<806345c0>] (dsa_slave_create+0x278/0x3f4)
> 	 r6:9ec70210 r5:9f6b9000 r4:9ed32800 r3:00000000
> 	[<80634348>] (dsa_slave_create) from [<806352a8>] (dsa_register_switch+0x76c/0x80c)
> 	 r10:9ec70210 r9:9ec70210 r8:9f646f08 r7:00000000 r6:9ec70210 r5:9f646e00
> 	 r4:9fff7724
> 	[<80634b3c>] (dsa_register_switch) from [<8047dabc>] (mv88e6xxx_probe+0x3cc/0x444)
> 	 r10:0000000c r9:00000000 r8:9fff7450 r7:00000000 r6:9ec7001c r5:9ec70010
> 	 r4:9ec62e00
> 	[<8047d6f0>] (mv88e6xxx_probe) from [<8046e9ec>] (mdio_probe+0x28/0x34)
> 	 r9:00000000 r8:8123d2e4 r7:00000000 r6:81258d50 r5:81299770 r4:9ec62e00
> 	[<8046e9c4>] (mdio_probe) from [<8040c2bc>] (driver_probe_device+0x27c/0x474)
> 	[<8040c040>] (driver_probe_device) from [<8040c6d4>] (__device_attach_driver+0xac/0x128)
> 	 r10:00000000 r9:00000000 r8:8129974c r7:9eca3c88 r6:9ec62e00 r5:8123d2e4
> 	 r4:00000001
> 	[<8040c628>] (__device_attach_driver) from [<8040a0fc>] (bus_for_each_drv+0x74/0xa8)
> 	 r7:00000001 r6:8040c628 r5:9eca3c88 r4:00000000
> 	[<8040a088>] (bus_for_each_drv) from [<8040be90>] (__device_attach+0xc0/0x150)
> 	 r6:8123a150 r5:9ec62e34 r4:9ec62e00
> 	[<8040bdd0>] (__device_attach) from [<8040c76c>] (device_initial_probe+0x1c/0x20)
> 	 r7:00000000 r6:8123a150 r5:9ec62e00 r4:9ec62e08
> 	[<8040c750>] (device_initial_probe) from [<8040b254>] (bus_probe_device+0x94/0x9c)
> 	[<8040b1c0>] (bus_probe_device) from [<80409010>] (device_add+0x420/0x5b8)
> 	 r6:9ec62e00 r5:9ed02840 r4:9ec62e08 r3:81252e00
> 	[<80408bf0>] (device_add) from [<8046eb48>] (mdio_device_register+0x3c/0x6c)
> 	 r10:00000000 r9:9ec62e00 r8:9ed02840 r7:9fff730c r6:00000000 r5:9ec62e00
> 	 r4:9fff7450
> 	[<8046eb0c>] (mdio_device_register) from [<8052647c>] (of_mdiobus_register+0xec/0x1fc)
> 	 r5:9ed02800 r4:9fff7450
> 	[<80526390>] (of_mdiobus_register) from [<8046f428>] (mdio_mux_init+0x194/0x254)
> 	 r10:9ec74ed0 r9:80803490 r8:8046f210 r7:9ec9a890 r6:9f59ac10 r5:00000000
> 	 r4:9fff730c
> 	[<8046f294>] (mdio_mux_init) from [<8046f658>] (mdio_mux_gpio_probe+0x78/0xac)
> 	 r10:00000003 r9:00000000 r8:8123a2f8 r7:fffffdfb r6:9f59ac00 r5:9ec9a710
> 	 r4:9f59ac10
> 	[<8046f5e0>] (mdio_mux_gpio_probe) from [<8040e0b0>] (platform_drv_probe+0x5c/0xc0)
> 	 r6:8123a2f8 r5:9f59ac10 r4:9f59ac10
> 	[<8040e054>] (platform_drv_probe) from [<8040c2bc>] (driver_probe_device+0x27c/0x474)
> 	 r7:00000000 r6:81258d50 r5:81299770 r4:9f59ac10
> 	[<8040c040>] (driver_probe_device) from [<8040c6d4>] (__device_attach_driver+0xac/0x128)
> 	 r10:81252518 r9:00000000 r8:00000000 r7:9eca3e88 r6:9f59ac10 r5:8123a2f8
> 	 r4:00000001
> 	[<8040c628>] (__device_attach_driver) from [<8040a0fc>] (bus_for_each_drv+0x74/0xa8)
> 	 r7:00000001 r6:8040c628 r5:9eca3e88 r4:00000000
> 	[<8040a088>] (bus_for_each_drv) from [<8040be90>] (__device_attach+0xc0/0x150)
> 	 r6:81233b28 r5:9f59ac44 r4:9f59ac10
> 	[<8040bdd0>] (__device_attach) from [<8040c76c>] (device_initial_probe+0x1c/0x20)
> 	 r7:81258d50 r6:81233b28 r5:9f59ac10 r4:9f59ac10
> 	[<8040c750>] (device_initial_probe) from [<8040b254>] (bus_probe_device+0x94/0x9c)
> 	[<8040b1c0>] (bus_probe_device) from [<8040b7f8>] (deferred_probe_work_func+0x48/0xcc)
> 	 r6:81233988 r5:81233974 r4:9f59ac10 r3:00000000
> 	[<8040b7b0>] (deferred_probe_work_func) from [<8012f3dc>] (process_one_work+0x120/0x3b0)
> 	 r7:9ffdc100 r6:8120aecc r5:9ece9100 r4:81233990
> 	[<8012f2bc>] (process_one_work) from [<8012f860>] (worker_thread+0x1f4/0x534)
> 	 r10:9ece9100 r9:8120aecc r8:9eca2038 r7:8120aee0 r6:81210980 r5:9ece9118
> 	 r4:8120aecc
> 	[<8012f66c>] (worker_thread) from [<801352e8>] (kthread+0x114/0x144)
> 	 r10:9f4e9e94 r9:9ecefb58 r8:8012f66c r7:9ece9100 r6:9ecef900 r5:00000000
> 	 r4:9ecefb40
> 	[<801351d4>] (kthread) from [<80108cd8>] (ret_from_fork+0x14/0x3c)
> 	 r10:00000000 r9:00000000 r8:00000000 r7:00000000 r6:00000000 r5:801351d4
> 	 r4:9ecef900 r3:9eca2000
> 	Code: ebf402bc e3500000 0a00004e e5943044 (e5930008) 
> 	---[ end trace 669c1d3a208ea147 ]---
> 
> 
> Reverting cafe8df8b9bc fixes my setup.
> 
> Thanks,
> 
> 	Vivien
> 


-- 
Florian
