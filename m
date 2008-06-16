From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: r8169 rx descriptors
Date: Mon, 16 Jun 2008 13:37:43 +0300
Message-ID: <20080616103524.M79928@visp.net.lb>
References: <20080615211030.M80450@visp.net.lb> <20080615220410.GA10522@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:58448 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbYFPKh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 06:37:58 -0400
In-Reply-To: <20080615220410.GA10522@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Jun 2008 00:04:10 +0200, Francois Romieu wrote
> Denys Fedoryshchenko <denys@visp.net.lb> :
> [...]
> > Why in Linux source:
> > 
> > #define NUM_TX_DESC     64      /* Number of Tx descriptor registers */
> > #define NUM_RX_DESC     256     /* Number of Rx descriptor registers */
> 
> One do not necessarily gain much from a huge Rx / Tx ring. You can
> increase NUM_RX_DESC though.
> 
> > Is it possible to do them changeable over ethtool -g ?
> 
> Yes.
> 
> > Maybe NetBSD developers signed NDA and have access to datasheets?
> 
> A NDA is not needed. You can get in touch with Edward Hsu
> <edward_hsu@realtek.com.tw> if you have some questions.
> 
> It can help for the moderately documented irq mitigation register.
> 
> > Also i seen in one patch from Realtek , something similar to
> > -#define RX_DMA_BURST    6       /* Maximum PCI burst, '6' is 1024 */
> > +#define RX_DMA_BURST    7       /* Maximum PCI burst, '6' is 1024 */
> > 
> > Why it is reverted or not applied?
> 
> I do not always apply Realtek's changes blindly. This one could make 
> a difference though.
> 
> > In sources from Realtek website it is 
> > #define RX_DMA_BURST	7	/* Maximum PCI burst, '7' is unlimited */
> > #define TX_DMA_BURST	7	/* Maximum PCI burst, '7' is unlimited */
> > 
> > I will try to change burst settings on my router, and waiting comments about
> 
> Apparently 1) you are experiencing Rx fifo overflows 2) your mean packet
> stands at 300 bytees. I'd try to lower RX_FIFO_THRESH first then 
> lower TX_DMA_BURST.
After lowering RX_FIFO_THRESH to 5 (i tried 6, also crashed), it crashes after
few seconds. Maybe it is not real bug, just driver not supposed to handle
lower values. But maybe it's triggering some bug?

If it is interesting here is panic message from RX_FIFO_THRESH set to 5:

Jun 16 13:32:20 10.22.22.3 [   18.025132] BUG: unable to handle kernel
Jun 16 13:32:20 10.22.22.3 NULL pointer dereference
Jun 16 13:32:20 10.22.22.3 at 000000ac
Jun 16 13:32:20 10.22.22.3 [   18.025254] IP:
Jun 16 13:32:20 10.22.22.3 [<c02469ba>] dev_kfree_skb_irq+0x6/0x3c
Jun 16 13:32:20 10.22.22.3 [   18.025351] Oops: 0002 [#1]
Jun 16 13:32:20 10.22.22.3 SMP
Jun 16 13:32:20 10.22.22.3
Jun 16 13:32:20 10.22.22.3 [   18.025455] Modules linked in:
Jun 16 13:32:20 10.22.22.3 netconsole
Jun 16 13:32:20 10.22.22.3 configfs
Jun 16 13:32:20 10.22.22.3 iTCO_wdt
Jun 16 13:32:20 10.22.22.3 coretemp
Jun 16 13:32:20 10.22.22.3 hwmon
Jun 16 13:32:20 10.22.22.3 i2c_i801
Jun 16 13:32:20 10.22.22.3 i2c_core
Jun 16 13:32:20 10.22.22.3 e1000e
Jun 16 13:32:20 10.22.22.3 iptable_filter
Jun 16 13:32:20 10.22.22.3 ip_tables
Jun 16 13:32:20 10.22.22.3 x_tables
Jun 16 13:32:20 10.22.22.3 8021q
Jun 16 13:32:20 10.22.22.3 tun
Jun 16 13:32:20 10.22.22.3 tulip
Jun 16 13:32:20 10.22.22.3 r8169
Jun 16 13:32:20 10.22.22.3 sky2
Jun 16 13:32:20 10.22.22.3 via_velocity
Jun 16 13:32:20 10.22.22.3 via_rhine
Jun 16 13:32:20 10.22.22.3 sis900
Jun 16 13:32:20 10.22.22.3 ne2k_pci
Jun 16 13:32:20 10.22.22.3 8390
Jun 16 13:32:20 10.22.22.3 skge
Jun 16 13:32:20 10.22.22.3 tg3
Jun 16 13:32:20 10.22.22.3 8139too
Jun 16 13:32:20 10.22.22.3 e1000
Jun 16 13:32:20 10.22.22.3 e100
Jun 16 13:32:20 10.22.22.3 usb_storage
Jun 16 13:32:20 10.22.22.3 mtdblock
Jun 16 13:32:20 10.22.22.3 mtd_blkdevs
Jun 16 13:32:20 10.22.22.3 usbhid
Jun 16 13:32:20 10.22.22.3 uhci_hcd
Jun 16 13:32:20 10.22.22.3 ehci_hcd
Jun 16 13:32:20 10.22.22.3 ohci_hcd
Jun 16 13:32:20 10.22.22.3 usbcore
Jun 16 13:32:20 10.22.22.3 [last unloaded: nf_conntrack]
Jun 16 13:32:20 10.22.22.3
Jun 16 13:32:20 10.22.22.3 [   18.026103]
Jun 16 13:32:20 10.22.22.3 [   18.026103] Pid: 7, comm: events/0 Not tainted
(2.6.26-rc6-git2-build-0029 #17)
Jun 16 13:32:20 10.22.22.3 [   18.026103] EIP: 0060:[<c02469ba>] EFLAGS:
00010206 CPU: 0
Jun 16 13:32:20 10.22.22.3 [   18.026103] EIP is at dev_kfree_skb_irq+0x6/0x3c
Jun 16 13:32:20 10.22.22.3 [   18.026103] EAX: 00000000 EBX: f748a000 ECX:
00000000 EDX: f748b028
Jun 16 13:32:20 10.22.22.3 [   18.026103] ESI: f748a500 EDI: 00000bd9 EBP:
c08d4f88 ESP: c08d4f84
Jun 16 13:32:20 10.22.22.3 [   18.026103]  DS: 007b ES: 007b FS: 00d8 GS: 0000
SS: 0068
Jun 16 13:32:20 10.22.22.3 [   18.026103] Process events/0 (pid: 7,
ti=c08d4000 task=f7c31810 task.ti=f7c3d000)
Jun 16 13:32:20 10.22.22.3
Jun 16 13:32:20 10.22.22.3 [   18.026103] Stack:
Jun 16 13:32:20 10.22.22.3 f748a000
Jun 16 13:32:20 10.22.22.3 c08d4fbc
Jun 16 13:32:20 10.22.22.3 f8955eff
Jun 16 13:32:20 10.22.22.3 f748b028
Jun 16 13:32:20 10.22.22.3 00000040
Jun 16 13:32:20 10.22.22.3 f748a50c
Jun 16 13:32:20 10.22.22.3 f8894000
Jun 16 13:32:20 10.22.22.3 00000000
Jun 16 13:32:20 10.22.22.3
Jun 16 13:32:20 10.22.22.3 [   18.026103]
Jun 16 13:32:20 10.22.22.3 30000a29
Jun 16 13:32:20 10.22.22.3 f748b02c
Jun 16 13:32:20 10.22.22.3 00000089
Jun 16 13:32:20 10.22.22.3 f748a50c
Jun 16 13:32:20 10.22.22.3 00000040
Jun 16 13:32:20 10.22.22.3 00000000
Jun 16 13:32:20 10.22.22.3 c08d4fe0
Jun 16 13:32:20 10.22.22.3 c0248096
Jun 16 13:32:20 10.22.22.3
Jun 16 13:32:20 10.22.22.3 [   18.026103]
Jun 16 13:32:20 10.22.22.3 c1fdf3f4
Jun 16 13:32:20 10.22.22.3 0000000a
Jun 16 13:32:20 10.22.22.3 c08d4ff8
Jun 16 13:32:20 10.22.22.3
Jun 16 13:32:20 10.22.22.3 rtl8169_poll+0x94/0x152 [r8169]
Jun 16 13:32:20 10.22.22.3 ?
Jun 16 13:32:20 10.22.22.3 net_rx_action+0x8f/0x199
Jun 16 13:32:20 10.22.22.3 ?
Jun 16 13:32:20 10.22.22.3 do_softirq+0x55/0x89
Jun 16 13:32:20 10.22.22.3 [   18.026103]  [<c013e23e>]
Jun 16 13:32:20 10.22.22.3 ?
Jun 16 13:32:20 10.22.22.3 handle_fasteoi_irq+0x0/0xaa
Jun 16 13:32:20 10.22.22.3 [   18.026103]  [<c0122878>]
Jun 16 13:32:20 10.22.22.3 ?
Jun 16 13:32:20 10.22.22.3 irq_exit+0x38/0x6b
Jun 16 13:32:20 10.22.22.3 [   18.026103]  [<c0105ef2>]
Jun 16 13:32:20 10.22.22.3 ?
Jun 16 13:32:20 10.22.22.3 do_IRQ+0xa0/0xb6
Jun 16 13:32:20 10.22.22.3 [   18.026103]  [<c01041d7>]
Jun 16 13:32:20 10.22.22.3 ?
Jun 16 13:32:20 10.22.22.3 common_interrupt+0x23/0x28
Jun 16 13:32:20 10.22.22.3 [   18.026103]  [<c0241cb7>]
Jun 16 13:32:20 10.22.22.3 [   18.026103]  [<c0241ce3>]
Jun 16 13:32:20 10.22.22.3 kfree_skb+0x29/0x2b
Jun 16 13:32:20 10.22.22.3 [   18.026103]  [<f8955896>]
Jun 16 13:32:20 10.22.22.3 ?
Jun 16 13:32:20 10.22.22.3 rtl8169_tx_clear+0x4a/0x78 [r8169]
Jun 16 13:32:20 10.22.22.3 [   18.026103]  [<f89573e1>]
Jun 16 13:32:20 10.22.22.3 ?
Jun 16 13:32:20 10.22.22.3 rtl8169_reset_task+0x3f/0xd1 [r8169]
Jun 16 13:32:20 10.22.22.3 [   18.026103]  [<f89573a2>]
Jun 16 13:32:20 10.22.22.3 ?
Jun 16 13:32:20 10.22.22.3 rtl8169_reset_task+0x0/0xd1 [r8169]
Jun 16 13:32:20 10.22.22.3 [   18.026103]  [<c012b16d>]
Jun 16 13:32:20 10.22.22.3 worker_thread+0x0/0x85
Jun 16 13:32:20 10.22.22.3 [   18.026103]  [<c012dc15>]
Jun 16 13:32:20 10.22.22.3 ?
Jun 16 13:32:20 10.22.22.3 autoremove_wake_function+0x0/0x33
Jun 16 13:32:20 10.22.22.3 [   18.026103]  [<c012db42>]
Jun 16 13:32:20 10.22.22.3 ?
Jun 16 13:32:20 10.22.22.3 kthread+0x3b/0x61
Jun 16 13:32:20 10.22.22.3 [   18.026103]  [<c012db07>]
Jun 16 13:32:20 10.22.22.3 ?
Jun 16 13:32:20 10.22.22.3 kthread+0x0/0x61
Jun 16 13:32:20 10.22.22.3 [   18.026103]  [<c0104417>]
Jun 16 13:32:20 10.22.22.3 ?
Jun 16 13:32:20 10.22.22.3 kernel_thread_helper+0x7/0x10
Jun 16 13:32:20 10.22.22.3 [   18.026103]  =======================
Jun 16 13:32:20 10.22.22.3 [   18.026103] Code:
Jun 16 13:32:20 10.22.22.3 89
Jun 16 13:32:20 10.22.22.3 34
Jun 16 13:32:20 10.22.22.3 38
Jun 16 13:32:20 10.22.22.3 80
Jun 16 13:32:20 10.22.22.3 63
Jun 16 13:32:20 10.22.22.3 64
Jun 16 13:32:20 10.22.22.3 f3
Jun 16 13:32:20 10.22.22.3 31
Jun 16 13:32:20 10.22.22.3 c0
Jun 16 13:32:20 10.22.22.3 eb
Jun 16 13:32:20 10.22.22.3 d2
Jun 16 13:32:20 10.22.22.3 31
Jun 16 13:32:20 10.22.22.3 c9
Jun 16 13:32:20 10.22.22.3 6a
Jun 16 13:32:20 10.22.22.3 20
Jun 16 13:32:20 10.22.22.3 89
Jun 16 13:32:20 10.22.22.3 d8
Jun 16 13:32:20 10.22.22.3 e8
Jun 16 13:32:20 10.22.22.3 17
Jun 16 13:32:20 10.22.22.3 b4
Jun 16 13:32:20 10.22.22.3 ff
Jun 16 13:32:20 10.22.22.3 ff
Jun 16 13:32:20 10.22.22.3 5a
Jun 16 13:32:20 10.22.22.3 85
Jun 16 13:32:20 10.22.22.3 c0
Jun 16 13:32:20 10.22.22.3 74
Jun 16 13:32:20 10.22.22.3 c7
Jun 16 13:32:20 10.22.22.3 8d
Jun 16 13:32:20 10.22.22.3 65
Jun 16 13:32:20 10.22.22.3 f4
Jun 16 13:32:20 10.22.22.3 5b
Jun 16 13:32:20 10.22.22.3 5e
Jun 16 13:32:20 10.22.22.3 5f
Jun 16 13:32:20 10.22.22.3 5d
Jun 16 13:32:20 10.22.22.3 c3
Jun 16 13:32:20 10.22.22.3 55
Jun 16 13:32:20 10.22.22.3 89
Jun 16 13:32:20 10.22.22.3 c1
Jun 16 13:32:20 10.22.22.3 89
Jun 16 13:32:20 10.22.22.3 e5
Jun 16 13:32:20 10.22.22.3 53
Jun 16 13:32:20 10.22.22.3 unparseable log message: "<f0> "
Jun 16 13:32:20 10.22.22.3 ff
Jun 16 13:32:20 10.22.22.3 88
Jun 16 13:32:20 10.22.22.3 ac
Jun 16 13:32:20 10.22.22.3 00
Jun 16 13:32:20 10.22.22.3 00
Jun 16 13:32:20 10.22.22.3 00
Jun 16 13:32:20 10.22.22.3 0f
Jun 16 13:32:20 10.22.22.3 94
Jun 16 13:32:20 10.22.22.3 c0
Jun 16 13:32:20 10.22.22.3 84
Jun 16 13:32:20 10.22.22.3 c0
Jun 16 13:32:20 10.22.22.3 74
Jun 16 13:32:20 10.22.22.3 25
Jun 16 13:32:20 10.22.22.3 9c
Jun 16 13:32:20 10.22.22.3 5b
Jun 16 13:32:20 10.22.22.3 fa
Jun 16 13:32:20 10.22.22.3 64
Jun 16 13:32:20 10.22.22.3 8b
Jun 16 13:32:20 10.22.22.3 15
Jun 16 13:32:20 10.22.22.3 00
Jun 16 13:32:20 10.22.22.3
Jun 16 13:32:20 10.22.22.3 [   18.026103] EIP: [<c02469ba>]
Jun 16 13:32:20 10.22.22.3 dev_kfree_skb_irq+0x6/0x3c
Jun 16 13:32:20 10.22.22.3 SS:ESP 0068:c08d4f84
Jun 16 13:32:20 10.22.22.3 [   18.032435] Kernel panic - not syncing: Fatal
exception in interrupt
Jun 16 13:32:20 10.22.22.3 [   18.032507] Rebooting in 70 seconds..



> 
> -- 
> Ueimor
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

