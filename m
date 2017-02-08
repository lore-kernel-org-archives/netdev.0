From: Fabio Estevam <festevam@gmail.com>
Subject: Kernel crashes in phy_attach_direct()
Date: Wed, 8 Feb 2017 10:58:57 -0200
Message-ID: <CAOMZO5C58--W1q+i26-+DBcton0Bk_o3zVfyuumM+Y=OemQ_Aw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f171.google.com ([74.125.82.171]:35520 "EHLO
        mail-ot0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753007AbdBHNAE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 08:00:04 -0500
Received: by mail-ot0-f171.google.com with SMTP id 65so111876214otq.2
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 04:58:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am getting the following kernel crash with linux-next 20170208
running on a imx53-qsb board.

Any ideas?

Thanks

Unable to handle kernel NULL pointer dereference at virtual address 00000008
 pgd = c0004000
 [00000008] *pgd=00000000
 Internal error: Oops: 5 [#1] SMP ARM
 Modules linked in:
 CPU: 0 PID: 1 Comm: swapper/0 Not tainted
4.10.0-rc7-next-20170208-00001-ga13938c-dirty #230
 Hardware name: Freescale i.MX53 (Device Tree Support)
 task: df868000 task.stack: df85e000
 PC is at phy_attach_direct+0x48/0x1a0
 LR is at phy_connect_direct+0x1c/0x54
 pc : [<c05eb634>]    lr : [<c05eb874>]    psr: 60000013
 sp : df85fc58  ip : df85fc88  fp : df85fc84
 r10: 00000000  r9 : 00000006  r8 : dfb32800
 r7 : 00000000  r6 : df83c000  r5 : de124800  r4 : de124800
 r3 : 00000000  r2 : c0e3f580  r1 : df940410  r0 : 00000000
 Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
 Control: 10c5387d  Table: 70004019  DAC: 00000051
 Process swapper/0 (pid: 1, stack limit = 0xdf85e210)
 Stack: (0xdf85fc58 to 0xdf860000)
 fc40:                                                       00000006 de124800
 fc60: de124800 c05f5228 c05f5228 00000006 c1647b14 00000200 df85fca4 df85fc88
 fc80: c05eb874 c05eb5f8 df85fd18 de124800 df83c000 c05f5228 df85fccc df85fca8
 fca0: c05eb8f4 c05eb864 00000000 df83c000 df85fcdb 00000000 dfaf6818 c1647b14
 fcc0: df85fd74 df85fcd0 c05f4258 c05eb8b8 00000000 c05f2cfc 3683c62c 63656633
 fce0: 2e303030 65687465 74656e72 0000312d 000003e8 000000c8 c0172258 c0171b08
 fd00: 000003e8 000000c8 014000c0 df801c00 014000c0 00000000 65663336 30303063
 fd20: 6874652e 656e7265 3a312d74 c0003030 df85fd74 df85fd40 c021f3fc c0999568
 fd40: df85fd74 c05f7fac c05f3368 e09aa000 df83c000 dfaf6000 00000000 e09aa000
 fd60: df83c000 dfaf6000 df85fdac df85fd78 c05f800c c05f415c 00000001 df83c62c
 fd80: df85fdac df83c000 00000000 c0a68b18 df83c030 00000000 c0d6ab34 c1647b14
 fda0: df85fdd4 df85fdb0 c0789de8 c05f7d98 df85fdd4 df83c000 df83c000 00000001
 fdc0: 00001003 00001002 df85fdfc df85fdd8 c078a0a0 c0789d44 df83c000 df83c138
 fde0: 00001002 00001002 00000000 c0d6ab34 df85fe24 df85fe00 c078a184 c078a01c
 fe00: c0d6ab34 df83c000 00000001 00001002 0000016b c0d6ab34 df85fedc df85fe28
 fe20: c0d54f50 c078a170 00000000 00000001 c0d5f858 c0d00618 df85fe84 df85fe48
 fe40: c0d6ac61 c01727d8 00000001 00000002 00000000 c07eed64 00000000 c07eedd0
 fe60: 60000013 df868000 c0e6c9c4 c0e6c9c4 c0e6c9e4 00000000 c0e6c9c4 00000000
 fe80: c0e6c9c4 c0e6c9e4 df85feac df85fe98 c099e8a0 c01770cc c0e09d08 c0e6c9e4
 fea0: df85fecc df85feb0 c07eedd0 c099e884 ffffe000 ffffe000 c0d54d54 c0d5f854
 fec0: c0ccd430 00000000 c0d5f858 c0d00618 df85ff4c df85fee0 c0101934 c0d54d60
 fee0: c0d00634 c040eea4 dfffcb00 c0a22e58 df85ff4c df85ff00 c01470c0 c0d00624
 ff00: 00000000 00000000 00000007 00000007 00000000 c0ccd430 c0bcebdc 00000000
 ff20: c0e17e34 00000007 c0e75000 c0d71cc4 c0e75000 c0d5f854 c0ccd430 000000eb
 ff40: df85ff94 df85ff50 c0d00e6c c01018fc 00000007 00000007 00000000 c0d00618
 ff60: 00000000 00000008 c0996d7c 00000000 c0996d7c 00000000 00000000 00000000
 ff80: 00000000 00000000 df85ffac df85ff98 c0996d8c c0d00d50 00000000 c0996d7c
 ffa0: 00000000 df85ffb0 c0107df0 c0996d88 00000000 00000000 00000000 00000000
 ffc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
 ffe0: 00000000 00000000 00000000 00000000 00000013 00000000 00000000 00000000
 Backtrace:
 [<c05eb5ec>] (phy_attach_direct) from [<c05eb874>]
(phy_connect_direct+0x1c/0x54)
 r10:00000200 r9:c1647b14 r8:00000006 r7:c05f5228 r6:c05f5228 r5:de124800
 r4:de124800 r3:00000006
 [<c05eb858>] (phy_connect_direct) from [<c05eb8f4>] (phy_connect+0x48/0x80)
 r7:c05f5228 r6:df83c000 r5:de124800 r4:df85fd18
 [<c05eb8ac>] (phy_connect) from [<c05f4258>] (fec_enet_mii_probe+0x108/0x170)
 r9:c1647b14 r8:dfaf6818 r7:00000000 r6:df85fcdb r5:df83c000 r4:00000000
 [<c05f4150>] (fec_enet_mii_probe) from [<c05f800c>] (fec_enet_open+0x280/0x34c)
 r6:dfaf6000 r5:df83c000 r4:e09aa000
 [<c05f7d8c>] (fec_enet_open) from [<c0789de8>] (__dev_open+0xb0/0x118)
 r10:c1647b14 r9:c0d6ab34 r8:00000000 r7:df83c030 r6:c0a68b18 r5:00000000
 r4:df83c000
 [<c0789d38>] (__dev_open) from [<c078a0a0>] (__dev_change_flags+0x90/0x154)
 r7:00001002 r6:00001003 r5:00000001 r4:df83c000
 [<c078a010>] (__dev_change_flags) from [<c078a184>]
(dev_change_flags+0x20/0x50)
 r9:c0d6ab34 r8:00000000 r7:00001002 r6:00001002 r5:df83c138 r4:df83c000
 [<c078a164>] (dev_change_flags) from [<c0d54f50>] (ip_auto_config+0x1fc/0xfe4)
 r9:c0d6ab34 r8:0000016b r7:00001002 r6:00000001 r5:df83c000 r4:c0d6ab34
 [<c0d54d54>] (ip_auto_config) from [<c0101934>] (do_one_initcall+0x44/0x178)
 r10:c0d00618 r9:c0d5f858 r8:00000000 r7:c0ccd430 r6:c0d5f854 r5:c0d54d54
 r4:ffffe000
 [<c01018f0>] (do_one_initcall) from [<c0d00e6c>]
(kernel_init_freeable+0x128/0x1e8)
 r8:000000eb r7:c0ccd430 r6:c0d5f854 r5:c0e75000 r4:c0d71cc4
 [<c0d00d44>] (kernel_init_freeable) from [<c0996d8c>] (kernel_init+0x10/0x118)
 r10:00000000 r9:00000000 r8:00000000 r7:00000000 r6:00000000 r5:c0996d7c
 r4:00000000
 [<c0996d7c>] (kernel_init) from [<c0107df0>] (ret_from_fork+0x14/0x24)
 r5:c0996d7c r4:00000000
 Code: ebef0412 e3500000 0a00004c e594307c (e5930008)
 ---[ end trace 494dc60949caf878 ]---
