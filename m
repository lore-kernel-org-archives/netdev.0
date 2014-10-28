From: Fabio Estevam <festevam@gmail.com>
Subject: fec: suspend/resume broken on 3.18-rc2
Date: Tue, 28 Oct 2014 15:18:54 -0200
Message-ID: <CAOMZO5C5znc2ZD5GoPKC7qQPoFGaJf47BoTMY0HQtEbW46d4dw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Russell King <linux@arm.linux.org.uk>,
	Shawn Guo <shawn.guo@linaro.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Duan Fugang-B38611 <B38611@freescale.com>,
	Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:56800 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751526AbaJ1RS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 13:18:56 -0400
Received: by mail-la0-f49.google.com with SMTP id ge10so1023380lab.8
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2014 10:18:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am running 3.18-rc2 on a mx6sx sdb board and noticed that fec
suspend/resume is broken (works fine on 3.17 though):

root@freescale /$ echo enabled > /sys/class/tty/ttymxc0/power/wakeup
root@freescale /$ echo mem > /sys/power/state
[   12.383292] PM: Syncing filesystems ... done.
[   12.423555] Freezing user space processes ... (elapsed 0.003 seconds) done.
[   12.434382] Freezing remaining freezable tasks ... (elapsed 0.003
seconds) done.
[   12.510232] PM: suspend of devices complete after 58.151 msecs
[   12.516258] PM: suspend devices took 0.080 seconds
[   12.530579] PM: late suspend of devices complete after 9.454 msecs
[   12.546818] PM: noirq suspend of devices complete after 9.806 msecs
[   12.553328] Disabling non-boot CPUs ...
[   12.568077] PM: noirq resume of devices complete after 9.212 msecs
[   12.582440] PM: early resume of devices complete after 6.426 msecs
[   12.593831] fec 2188000.ethernet eth0: rcv is not +last
[   12.599237] Unable to handle kernel NULL pointer dereference at
virtual address 00000000
[   12.607438] pgd = 80004000
[   12.610187] [00000000] *pgd=00000000
[   12.613834] Internal error: Oops: 17 [#1] SMP ARM
[   12.618583] Modules linked in:
[   12.621706] CPU: 0 PID: 2 Comm: kthreadd Not tainted
3.18.0-rc2-00043-gf7e87a4-dirty #178
[   12.629943] task: be0789c0 ti: be088000 task.ti: be088000
[   12.635398] PC is at memcpy+0x80/0x330
[   12.639197] LR is at gro_pull_from_frag0+0x34/0xa8
[   12.644034] pc : [<802a6b60>]    lr : [<80539b8c>]    psr: 00000153
[   12.644034] sp : be089b34  ip : 00000010  fp : be089b6c
[   12.655577] r10: 00000000  r9 : 0000000e  r8 : 8094d9c0
[   12.660842] r7 : 8094d9c0  r6 : 00000012  r5 : bd9e5040  r4 : bd89d9c0
[   12.667412] r3 : 00000804  r2 : fffffff2  r1 : 00000000  r0 : bd9e483c
[   12.673987] Flags: nzcv  IRQs on  FIQs off  Mode SVC_32  ISA ARM
Segment kernel
[   12.681432] Control: 10c5387d  Table: bd99804a  DAC: 00000015
[   12.687228] Process kthreadd (pid: 2, stack limit = 0xbe088240)
[   12.693197] Stack: (0xbe089b34 to 0xbe08a000)
[   12.697601] 9b20:
bd9e5040 00000012 8094d9c0
[   12.705850] 9b40: 8094d9c0 bd9e483c bd89d9c0 80539b8c 00000000
bd89d9c0 be338710 00000003
[   12.714097] 9b60: be089bc4 be089b70 8053b0f4 80539b64 00000000
00000000 8053b1b4 811a0f80
[   12.722344] 9b80: 000007c1 befa4c80 be338000 00000002 be089bcc
8094d9c0 00000000 bd89d9c0
[   12.730588] 9ba0: be338710 00000000 bf084000 bd89d9c0 be338000
00000001 be089bdc be089bc8
[   12.738833] 9bc0: 8053b8e0 8053b08c bf084000 00000080 be089c5c
be089be0 80414f14 8053b8c4
[   12.747077] 9be0: 00000000 00000000 be338710 be338600 00000040
be338694 00000000 00000000
[   12.755320] 9c00: 80984c74 bd0c0900 00000000 00000000 00000000
be33a000 be33807c be338074
[   12.763565] 9c20: 00000040 00000001 80060d50 80060c18 0000012c
0000012c be7c41c0 80946100
[   12.771810] 9c40: be7c41c8 00000040 00000003 be338710 be089c94
be089c60 8053b628 80414ad8
[   12.780053] 9c60: 80060d50 ffff8fbc 00000008 00000000 8094608c
be088000 00000003 00000100
[   12.788297] 9c80: 00000003 80946080 be089cdc be089c98 8002d008
8053b568 be089cbc be089ca8
[   12.796542] 9ca0: 00000001 00208040 ffff8fbb 0000000a be089cdc
be088000 8094cd78 80940e6c
[   12.804786] 9cc0: be088000 00000000 be00a400 00000001 be089cf4
be089ce0 8002d448 8002cef4
[   12.813032] 9ce0: 00000180 00000000 be089d24 be089cf8 80069e40
8002d3a4 be089d50 c080e10c
[   12.821277] 9d00: 00000086 be089d50 8094cef0 c080e100 bd02e180
00000000 be089d4c be089d28
[   12.829521] 9d20: 8000875c 80069dd8 be0789c0 800b3f20 80000153
ffffffff be089d84 809aa580
[   12.837766] 9d40: be089e54 be089d50 80012b64 80008740 00000000
00000001 809a8940 00000000
[   12.846009] 9d60: 002000d0 809a8940 00000000 00000000 809aa580
bd02e180 00000000 be089e54
[   12.854254] 9d80: 00200010 be089d98 00080008 800b3f20 80000153
ffffffff 00000000 81157f4c
[   12.862498] 9da0: be0789c0 8096a990 80ad76a0 0000000c be088000
be7c3b50 be089e5c be089dc8
[   12.870744] 9dc0: 8005e760 8005dd08 be0789c0 00000000 00000458
802c749c 00000000 be7c3ba8
[   12.878988] 9de0: 00000002 00000000 00000458 00000000 be089e0c
be089e00 80ad8360 be078e18
[   12.887232] 9e00: 0000000c 00000000 806a02e8 00000001 00002edb
00000000 be001880 00000010
[   12.895476] 9e20: be089e64 be089e30 800e78ac 00800711 be088000
be0789c0 00000000 809aa580
[   12.903722] 9e40: bd02e180 ffffffff be089e64 be089e58 800b48a8
800b3ee8 be089ef4 be089e68
[   12.911967] 9e60: 80027a50 800b4894 80ad76a0 0000005c be088000
8095c8c0 be089f1c be089e88
[   12.920210] 9e80: 8005e760 8005dd08 be089ecc be089e98 80047bdc
806a02f8 00000000 00000000
[   12.928453] 9ea0: 80047b98 00000000 00000000 be3fef80 800433d8
00000000 80add860 be078e18
[   12.936696] 9ec0: 0000005c 00000000 8069aec0 00800711 be3fef80
00000000 00000000 00000000
[   12.944942] 9ee0: 00000001 be088000 be089f64 be089ef8 80028f1c
8002798c 00000000 00000000
[   12.953186] 9f00: 00000001 00000000 00000001 be088000 be089f54
be089f20 8006049c 8005e3b8
[   12.961429] 9f20: 00000001 00000000 be0789c0 8095c8b0 bd1a5c40
8095c8b0 8095c8d0 be3fef94
[   12.969677] 9f40: be3fef80 8095c8b0 8095c8d0 00000000 00000001
be088000 be089f7c be089f68
[   12.977921] 9f60: 8002925c 80028e80 00000000 be3fef94 be089fac
be089f80 80043d24 80029238
[   12.986165] 9f80: ffffffff 00000000 80043c48 00000000 00000000
00000000 00000000 00000000
[   12.994411] 9fa0: 00000000 be089fb0 8000ece8 80043c54 00000000
00000000 00000000 00000000
[   13.002653] 9fc0: 00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000
[   13.010897] 9fe0: 00000000 00000000 00000000 00000000 00000013
00000000 beff3ab1 beff3c11
[   13.019129] Backtrace:
[   13.021659] [<80539b58>] (gro_pull_from_frag0) from [<8053b0f4>]
(dev_gro_receive+0x74/0x3e8)
[   13.030245]  r6:00000003 r5:be338710 r4:bd89d9c0 r3:00000000
[   13.036069] [<8053b080>] (dev_gro_receive) from [<8053b8e0>]
(napi_gro_receive+0x28/0xa8)
[   13.044303]  r10:00000001 r9:be338000 r8:bd89d9c0 r7:bf084000
r6:00000000 r5:be338710
[   13.052314]  r4:bd89d9c0
[   13.054927] [<8053b8b8>] (napi_gro_receive) from [<80414f14>]
(fec_enet_rx_napi+0x448/0xadc)
[   13.063423]  r5:00000080 r4:bf084000
[   13.067099] [<80414acc>] (fec_enet_rx_napi) from [<8053b628>]
(net_rx_action+0xcc/0x1b4)
[   13.075246]  r10:be338710 r9:00000003 r8:00000040 r7:be7c41c8
r6:80946100 r5:be7c41c0
[   13.083257]  r4:0000012c
[   13.085865] [<8053b55c>] (net_rx_action) from [<8002d008>]
(__do_softirq+0x120/0x268)
[   13.093754]  r10:80946080 r9:00000003 r8:00000100 r7:00000003
r6:be088000 r5:8094608c
[   13.101766]  r4:00000000
[   13.104368] [<8002cee8>] (__do_softirq) from [<8002d448>]
(irq_exit+0xb0/0x104)
[   13.111731]  r10:00000001 r9:be00a400 r8:00000000 r7:be088000
r6:80940e6c r5:8094cd78
[   13.119738]  r4:be088000
[   13.122345] [<8002d398>] (irq_exit) from [<80069e40>]
(__handle_domain_irq+0x74/0xc8)
[   13.130233]  r4:00000000 r3:00000180
[   13.133907] [<80069dcc>] (__handle_domain_irq) from [<8000875c>]
(gic_handle_irq+0x28/0x68)
[   13.142317]  r10:00000000 r9:bd02e180 r8:c080e100 r7:8094cef0
r6:be089d50 r5:00000086
[   13.150328]  r4:c080e10c r3:be089d50
[   13.153997] [<80008734>] (gic_handle_irq) from [<80012b64>]
(__irq_svc+0x44/0x5c)
[   13.161539] Exception stack(0xbe089d50 to 0xbe089d98)
[   13.166638] 9d40:                                     00000000
00000001 809a8940 00000000
[   13.174884] 9d60: 002000d0 809a8940 00000000 00000000 809aa580
bd02e180 00000000 be089e54
[   13.183126] 9d80: 00200010 be089d98 00080008 800b3f20 80000153 ffffffff
[   13.189785]  r8:809aa580 r7:be089d84 r6:ffffffff r5:80000153
r4:800b3f20 r3:be0789c0
[   13.197725] [<800b3edc>] (__alloc_pages_nodemask) from [<800b48a8>]
(alloc_kmem_pages_node+0x20/0x28)
[   13.207008]  r10:ffffffff r9:bd02e180 r8:809aa580 r7:00000000
r6:be0789c0 r5:be088000
[   13.215018]  r4:00800711
[   13.217635] [<800b4888>] (alloc_kmem_pages_node) from [<80027a50>]
(copy_process.part.52+0xd0/0x1440)
[   13.226938] [<80027980>] (copy_process.part.52) from [<80028f1c>]
(do_fork+0xa8/0x3b8)
[   13.234913]  r10:be088000 r9:00000001 r8:00000000 r7:00000000
r6:00000000 r5:be3fef80
[   13.242922]  r4:00800711
[   13.245528] [<80028e74>] (do_fork) from [<8002925c>]
(kernel_thread+0x30/0x38)
[   13.252803]  r10:be088000 r9:00000001 r8:00000000 r7:8095c8d0
r6:8095c8b0 r5:be3fef80
[   13.260813]  r4:be3fef94
[   13.263419] [<8002922c>] (kernel_thread) from [<80043d24>]
(kthreadd+0xdc/0x14c)
[   13.270889] [<80043c48>] (kthreadd) from [<8000ece8>]
(ret_from_fork+0x14/0x2c)
[   13.278254]  r10:00000000 r9:00000000 r8:00000000 r7:00000000
r6:00000000 r5:80043c48
[   13.286263]  r4:00000000 r3:ffffffff
[   13.289930] Code: e320f000 e4913004 e4914004 e4915004 (e4916004)
[   13.296165] ---[ end trace bc69878b7a8d6f78 ]---
[   13.300839] Kernel panic - not syncing: Fatal exception in interrupt
[   13.307258] ---[ end Kernel panic - not syncing: Fatal exception in interrupt

Haven't started debugging this yet, but just wanted to report in case
this sounds familiar to someone.

Regards,

Fabio Estevam
