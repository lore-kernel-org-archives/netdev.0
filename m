From: Holger Schurig <holgerschurig@gmail.com>
Subject: Re: [PATCH net-next V3 00/16] net: fec: cleanup and fixes
Date: Thu, 14 Apr 2016 12:13:46 +0200
Message-ID: <87h9f4ebvp.fsf@gmail.com>
References: <1459909562-22865-1-git-send-email-troy.kisky@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, davem@davemloft.net, fugang.duan@nxp.com,
	lznuaa@gmail.com, andrew@lunn.ch, stillcompiling@gmail.com,
	arnd@arndb.de, sergei.shtylyov@cogentembedded.com,
	gerg@uclinux.org, fabio.estevam@nxp.com, johannes@sipsolutions.net,
	l.stach@pengutronix.de, linux-arm-kernel@lists.infradead.org,
	tremyfr@gmail.com
To: Troy Kisky <troy.kisky@boundarydevices.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36386 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752430AbcDNKNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 06:13:51 -0400
Received: by mail-wm0-f66.google.com with SMTP id l6so21398505wml.3
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 03:13:50 -0700 (PDT)
In-Reply-To: <1459909562-22865-1-git-send-email-troy.kisky@boundarydevices.com> (Troy
	Kisky's message of "Tue, 5 Apr 2016 19:25:46 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do you guys that work with the FEC driver ever run with
CONFIG_DMA_API_DEBUG enabled?

I ask this Because I get this error when it's turned on when I do some
"rsync" transfer to my device:

[   58.420980] ------------[ cut here ]------------
[   58.425667] WARNING: CPU: 0 PID: 377 at /home/schurig/d/mkarm/linux-4.5/lib/dma-debug.c:1096 check_unmap+0x9d0/0xab8()
[   58.436405] fec 2188000.ethernet: DMA-API: device driver tries to free DMA memory it has not allocated [device address=0x0000000000000000] [size=66 bytes]
[   58.450248] Modules linked in: bnep usbhid imx_sdma flexcan btusb btrtl btbcm btintel smsc95xx usbnet mii bluetooth
[   58.460882] CPU: 0 PID: 377 Comm: sshd Tainted: G        W       4.5.1 #3
[   58.467671] Hardware name: Freescale i.MX6 Quad/DualLite (Device Tree)
[   58.474199] Backtrace: 
[   58.476675] [<c0012a24>] (dump_backtrace) from [<c0012c20>] (show_stack+0x18/0x1c)
[   58.484244]  r6:60000113 r5:c05a96c0 r4:00000000 r3:00000000
[   58.489964] [<c0012c08>] (show_stack) from [<c01dbc4c>] (dump_stack+0x9c/0xb0)
[   58.497197] [<c01dbbb0>] (dump_stack) from [<c001f558>] (warn_slowpath_common+0x8c/0xbc)
[   58.505286]  r6:c01f9c74 r5:00000009 r4:ee9f17f8 r3:c0596da4
[   58.511002] [<c001f4cc>] (warn_slowpath_common) from [<c001f5c0>] (warn_slowpath_fmt+0x38/0x40)
[   58.519698]  r8:00000042 r7:00000001 r6:00000000 r5:00000000 r4:c050c020
[   58.526470] [<c001f58c>] (warn_slowpath_fmt) from [<c01f9c74>] (check_unmap+0x9d0/0xab8)
[   58.534559]  r3:c0520e6c r2:c050c020
[   58.538159]  r4:00000000
[   58.540710] [<c01f92a4>] (check_unmap) from [<c01f9de0>] (debug_dma_unmap_page+0x84/0x8c)
[   58.548886]  r10:ef2ec000 r9:f09e5fa0 r8:ef0ef810 r7:00000001 r6:00000000 r5:00000042
[   58.556780]  r4:00000001
[   58.559336] [<c01f9d5c>] (debug_dma_unmap_page) from [<c02cdf00>] (fec_txq+0x140/0x31c)
[   58.567338]  r8:ef0ef810 r7:00000000 r6:00000000 r5:00000000 r4:ef2c6000
[   58.574108] [<c02cddc0>] (fec_txq) from [<c02ce2f4>] (fec_enet_napi_q1+0x98/0xe8)
[   58.581589]  r10:08000000 r9:ef2ec580 r8:00000000 r7:00000040 r6:00000000 r5:ef2ec000
[   58.589483]  r4:0c008000
[   58.592042] [<c02ce25c>] (fec_enet_napi_q1) from [<c038b3d8>] (net_rx_action+0x1fc/0x2f0)
[   58.600218]  r10:ee9f19c0 r9:00000040 r8:c059e100 r7:0000012c r6:ffffa1a3 r5:c02ce25c
[   58.608112]  r4:ef2ec580 r3:ee9f19c0
[   58.611720] [<c038b1dc>] (net_rx_action) from [<c00224c4>] (__do_softirq+0x134/0x254)
[   58.619549]  r10:c059e080 r9:40000003 r8:00000100 r7:ee9f0000 r6:c059e08c r5:00000003
[   58.627445]  r4:00000000
[   58.629995] [<c0022390>] (__do_softirq) from [<c00228a8>] (irq_exit+0xb8/0x120)
[   58.637303]  r10:ee9f1e38 r9:f4001100 r8:ef008000 r7:00000001 r6:00000000 r5:00000000
[   58.645197]  r4:c05970b8
[   58.647754] [<c00227f0>] (irq_exit) from [<c0061340>] (__handle_domain_irq+0x68/0xbc)
[   58.655583]  r4:c05970b8 r3:c0064e24
[   58.659190] [<c00612d8>] (__handle_domain_irq) from [<c00093f8>] (gic_handle_irq+0x50/0x90)
[   58.667539]  r8:f4000100 r7:ee9f1ac8 r6:f400010c r5:c059e7a0 r4:c05a9788 r3:ee9f1ac8
[   58.675350] [<c00093a8>] (gic_handle_irq) from [<c0013740>] (__irq_svc+0x40/0x54)
[   58.682833] Exception stack(0xee9f1ac8 to 0xee9f1b10)
[   58.687887] 1ac0:                   00000000 ee9c0d4c 0000000c 00000000 00000000 00000000
[   58.696067] 1ae0: ee9f1e38 ee9f1e3c ee9f1e40 edc6ac00 ee9f1e38 ee9f1e1c 00000000 ee9f1b18
[   58.704245] 1b00: ee9c0d4c c00df648 60000013 ffffffff
[   58.709295]  r9:edc6ac00 r8:ee9f1e40 r7:ee9f1afc r6:ffffffff r5:60000013 r4:c00df648
[   58.717112] [<c00df544>] (do_select) from [<c00dfcb8>] (core_sys_select+0x144/0x320)
[   58.724854]  r10:ee9f1e38 r9:ee9f1e38 r8:0000000c r7:805af838 r6:00000000 r5:805af848
[   58.732749]  r4:00000004
[   58.735300] [<c00dfb74>] (core_sys_select) from [<c00dff68>] (SyS_select+0xd4/0x120)
[   58.743042]  r10:00000000 r9:0000000c r8:805af848 r7:805af838 r6:00000000 r5:ee9f1f70
[   58.750936]  r4:00000000
[   58.753488] [<c00dfe94>] (SyS_select) from [<c000f820>] (ret_fast_syscall+0x0/0x34)
[   58.761143]  r9:ee9f0000 r8:c000f9c4 r7:0000008e r6:00000000 r5:7f5f77c0 r4:00000000
[   58.768984] ---[ end trace cb88537fdc8fa202 ]---

The amount of data transferred isn't even huge:

sent 382,979 bytes  received 28,086 bytes  32,885.20 bytes/sec
total size is 147,758,955  speedup is 359.45



This happens with:

* Kernel 4.5
* Kernel 4.5.1
* Kernel 4.5.1 with the fec-related patches from 4.6-rc3
* Kernel 4.5.1 with the fec-related patches from 4.6-rc3 and Troy's
  patch series from this thread


Should I post an extra e-mail with "BUG" in the subject?
