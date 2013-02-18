From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH v4 1/1 net-next] net: fec: add napi support to improve proformance
Date: Mon, 18 Feb 2013 16:09:37 -0300
Message-ID: <CAOMZO5DihkwnSD2kYhmgG9B5QUPW7khn2qvXUYszb2nCPygHXA@mail.gmail.com>
References: <1359433903-15605-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: lznuaa@gmail.com, shawn.guo@linaro.org, B38611@freescale.com,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, s.hauer@pengutronix.de,
	=?UTF-8?B?TWFyZWsgVmHFoXV0?= <marex@denx.de>
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f175.google.com ([209.85.220.175]:46625 "EHLO
	mail-vc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754700Ab3BRTJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 14:09:38 -0500
Received: by mail-vc0-f175.google.com with SMTP id fw7so3801626vcb.34
        for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 11:09:37 -0800 (PST)
In-Reply-To: <1359433903-15605-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Frank,

On Tue, Jan 29, 2013 at 2:31 AM, Frank Li <Frank.Li@freescale.com> wrote:
> Add napi support
>
> Before this patch
>
>  iperf -s -i 1
>  ------------------------------------------------------------
>  Server listening on TCP port 5001
>  TCP window size: 85.3 KByte (default)
>  ------------------------------------------------------------
>  [  4] local 10.192.242.153 port 5001 connected with 10.192.242.138 port 50004
>  [ ID] Interval       Transfer     Bandwidth
>  [  4]  0.0- 1.0 sec  41.2 MBytes   345 Mbits/sec
>  [  4]  1.0- 2.0 sec  43.7 MBytes   367 Mbits/sec
>  [  4]  2.0- 3.0 sec  42.8 MBytes   359 Mbits/sec
>  [  4]  3.0- 4.0 sec  43.7 MBytes   367 Mbits/sec
>  [  4]  4.0- 5.0 sec  42.7 MBytes   359 Mbits/sec
>  [  4]  5.0- 6.0 sec  43.8 MBytes   367 Mbits/sec
>  [  4]  6.0- 7.0 sec  43.0 MBytes   361 Mbits/sec
>
> After this patch
>  [  4]  2.0- 3.0 sec  51.6 MBytes   433 Mbits/sec
>  [  4]  3.0- 4.0 sec  51.8 MBytes   435 Mbits/sec
>  [  4]  4.0- 5.0 sec  52.2 MBytes   438 Mbits/sec
>  [  4]  5.0- 6.0 sec  52.1 MBytes   437 Mbits/sec
>  [  4]  6.0- 7.0 sec  52.1 MBytes   437 Mbits/sec
>  [  4]  7.0- 8.0 sec  52.3 MBytes   439 Mbits/sec
>
> Signed-off-by: Frank Li <Frank.Li@freescale.com>
> Signed-off-by: Fugang Duan <B38611@freescale.com>

This patch causes the following crash on a mx53qsb board:

53fbc000.serial: ttymxc0 at MMIO 0x53fbc000 (irq = 47) is a IMX
console [ttymxc0] enabled
brd: module loaded
loop: module loaded
Unable to handle kernel NULL pointer dereference at virtual address 00000002
pgd = 80004000
[00000002] *pgd=00000000
Internal error: Oops: 5 [#1] SMP ARM
Modules linked in:
CPU: 0    Not tainted  (3.8.0-rc7-next-20130218+ #1192)
PC is at fec_enet_interrupt+0xd0/0x354
LR is at fec_enet_interrupt+0xb8/0x354
pc : [<8034592c>]    lr : [<80345914>]    psr: 60000193
sp : df855c20  ip : df855c20  fp : df855c74
r10: 00000516  r9 : 1e000000  r8 : 00000000
r7 : 00000000  r6 : 00000000  r5 : 00000001  r4 : df93f800
r3 : df93fdf4  r2 : 00000000  r1 : 00000000  r0 : df93fd34
Flags: nZCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
Control: 10c5387d  Table: 70004019  DAC: 00000017
Process swapper/0 (pid: 1, stack limit = 0xdf854238)
Stack: (0xdf855c20 to 0xdf856000)
5c20: 800a3f24 80255140 dfa4d740 df93fd8c df93fdf4 df93fd84 df855c8c df855c48
5c40: 800a53f4 800a3eb4 807503c8 dfa4d580 00000001 00000000 00000000 00000067
5c60: 80709611 df808e40 df855cac df855c78 8006f3e4 80345868 dfa4d700 20000008
5c80: df855cc4 df808e40 00000001 df854000 00000067 00000000 8075ab7c 00000002
5ca0: df855cc4 df855cb0 8006f57c 8006f39c df808e40 00000001 df855cdc df855cc8
5cc0: 80072068 8006f538 00000067 806bdba8 df855cf4 df855ce0 8006ed50 80071fc4
5ce0: 00000170 806c8ba0 df855d1c df855cf8 8000ee74 8006ed34 00000010 00000000
5d00: 8070a0f8 00000040 00000001 df855d48 df855d44 df855d20 80008548 8000ee2c
5d20: 80420794 60000113 ffffffff df855d7c dfa4d4c0 e0898080 df855df4 df855d48
5d40: 8000e100 800084dc df93f800 df93fd84 80345300 00000040 df93f800 df89f800
5d60: 00000000 df89f810 dfa4d4c0 8075ab7c e0898080 df855df4 00000000 df855d90
5d80: 80346390 80420794 60000113 ffffffff 00000000 df93f800 df855dc4 00000000
5da0: 00000000 8026b6ec 00000000 00000000 00000000 df93fc40 00000000 04000000
5dc0: b5e2019f 00000001 df855de4 807589c0 806fa000 df89f810 00000000 806fa000
5de0: 8067420c 807096c0 df855e04 df855df8 802b7c6c 80345f1c df855e2c df855e08
5e00: 802b68b4 802b7c58 00000000 df89f810 806fa000 df89f844 00000000 000000a1
5e20: df855e4c df855e30 802b6a58 802b67c8 802b69c4 806fa000 802b69c4 00000000
5e40: df855e74 df855e50 802b4fe4 802b69d0 df834158 df897834 df83416c 806fa000
5e60: 806ef7b0 dfa42c80 df855e84 df855e78 802b63d4 802b4f94 df855eb4 df855e88
5e80: 802b5f6c 802b63c0 80626878 00000000 df855eb4 806fa000 00000006 00000000
5ea0: 807096c0 000000a1 df855edc df855eb8 802b6f80 802b5e98 df854000 00000006
5ec0: 00000000 807096c0 000000a1 807096c0 df855eec df855ee0 802b7e90 802b6f0c
5ee0: df855efc df855ef0 8069b7e8 802b7e50 df855f54 df855f00 80008710 8069b7e0
5f00: df855f54 df855f10 8069b7d4 00000000 00000000 00000006 00000006 80671a4c
5f20: 00000000 8062be70 df855f54 806b00e8 00000006 806b00c8 807096c0 000000a1
5f40: 8067420c 806bbdcc df855f94 df855f58 80674978 800086dc 00000006 00000006
5f60: 8067420c 77b9bbee ffe4a7fa 00000000 804f0aec 00000000 00000000 00000000
5f80: 00000000 00000000 df855fac df855f98 804f0afc 80674880 ffffffff 00000000
5fa0: 00000000 df855fb0 8000e618 804f0af8 00000000 00000000 00000000 00000000
5fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
5fe0: 00000000 00000000 00000000 00000000 00000013 00000000 ebfdf63e 9fb47bf3
Backtrace:
[<8034585c>] (fec_enet_interrupt+0x0/0x354) from [<8006f3e4>]
(handle_irq_event_percpu+0x54/0x19c)
[<8006f390>] (handle_irq_event_percpu+0x0/0x19c) from [<8006f57c>]
(handle_irq_event+0x50/0x70)
[<8006f52c>] (handle_irq_event+0x0/0x70) from [<80072068>]
(handle_level_irq+0xb0/0x124)
 r5:00000001 r4:df808e40
[<80071fb8>] (handle_level_irq+0x0/0x124) from [<8006ed50>]
(generic_handle_irq+0x28/0x38)
 r5:806bdba8 r4:00000067
[<8006ed28>] (generic_handle_irq+0x0/0x38) from [<8000ee74>]
(handle_IRQ+0x54/0xb4)
 r4:806c8ba0 r3:00000170
[<8000ee20>] (handle_IRQ+0x0/0xb4) from [<80008548>] (tzic_handle_irq+0x78/0xa8)
 r8:df855d48 r7:00000001 r6:00000040 r5:8070a0f8 r4:00000000
r3:00000010
[<800084d0>] (tzic_handle_irq+0x0/0xa8) from [<8000e100>] (__irq_svc+0x40/0x54)
Exception stack(0xdf855d48 to 0xdf855d90)
5d40:                   df93f800 df93fd84 80345300 00000040 df93f800 df89f800
5d60: 00000000 df89f810 dfa4d4c0 8075ab7c e0898080 df855df4 00000000 df855d90
5d80: 80346390 80420794 60000113 ffffffff
[<80345f10>] (fec_probe+0x0/0xa34) from [<802b7c6c>]
(platform_drv_probe+0x20/0x24)
[<802b7c4c>] (platform_drv_probe+0x0/0x24) from [<802b68b4>]
(driver_probe_device+0xf8/0x208)
[<802b67bc>] (driver_probe_device+0x0/0x208) from [<802b6a58>]
(__driver_attach+0x94/0x98)
 r8:000000a1 r7:00000000 r6:df89f844 r5:806fa000 r4:df89f810
r3:00000000
[<802b69c4>] (__driver_attach+0x0/0x98) from [<802b4fe4>]
(bus_for_each_dev+0x5c/0x90)
 r6:00000000 r5:802b69c4 r4:806fa000 r3:802b69c4
[<802b4f88>] (bus_for_each_dev+0x0/0x90) from [<802b63d4>]
(driver_attach+0x20/0x28)
 r6:dfa42c80 r5:806ef7b0 r4:806fa000
[<802b63b4>] (driver_attach+0x0/0x28) from [<802b5f6c>]
(bus_add_driver+0xe0/0x234)
[<802b5e8c>] (bus_add_driver+0x0/0x234) from [<802b6f80>]
(driver_register+0x80/0x14c)
 r8:000000a1 r7:807096c0 r6:00000000 r5:00000006 r4:806fa000
[<802b6f00>] (driver_register+0x0/0x14c) from [<802b7e90>]
(platform_driver_register+0x4c/0x60)
[<802b7e44>] (platform_driver_register+0x0/0x60) from [<8069b7e8>]
(fec_driver_init+0x14/0x1c)
[<8069b7d4>] (fec_driver_init+0x0/0x1c) from [<80008710>]
(do_one_initcall+0x40/0x184)
[<800086d0>] (do_one_initcall+0x0/0x184) from [<80674978>]
(kernel_init_freeable+0x104/0x1d0)
[<80674874>] (kernel_init_freeable+0x0/0x1d0) from [<804f0afc>]
(kernel_init+0x10/0xec)
[<804f0aec>] (kernel_init+0x0/0xec) from [<8000e618>] (ret_from_fork+0x14/0x3c)
 r4:00000000 r3:ffffffff
Code: e2843e5f e3a08000 e2833004 e50b3044 (e1d650b2)
---[ end trace c87bb11a6f3f1b7c ]---
Kernel panic - not syncing: Fatal exception in interrupt
