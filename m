From: Borislav Petkov <bp@alien8.de>
Subject: Re: r8169: INFO: trying to register non-static key.
Date: Tue, 25 Feb 2014 00:22:13 +0100
Message-ID: <20140224232212.GB18598@pd.tnic>
References: <20140224231748.GA18598@pd.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Realtek linux nic maintainers <nic_swsd@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140224231748.GA18598@pd.tnic>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oh boy, there's more of the trace which appears much further down in
dmesg and the printk timestamps are all messed up!?! See below.

On Tue, Feb 25, 2014 at 12:17:48AM +0100, Borislav Petkov wrote:
> I get this on latest -rc4 + tip/master:
> 
> [    9.172287] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> [    9.178461] r8169 0000:02:00.0: can't disable ASPM; OS doesn't have ASPM control
> [    9.186137] r8169 0000:02:00.0: irq 45 for MSI/MSI-X
> [    9.195943] INFO: trying to register non-static key.
> [    9.196031] the code is fine but needs lockdep annotation.
> [    9.196031] turning off the locking correctness validator.
> [    9.196031] CPU: 1 PID: 933 Comm: modprobe Not tainted 3.14.0-rc4+ #1
> [    9.196031] Hardware name: Acer AOA150/        , BIOS v0.3309 10/06/2008
> [    9.196031]  00000000 00000000 f5e49a48 c15aa25c c1c68b58 f5e49ac0 c10913fc c174bc50
> [    9.196031]  0001488a 79da0cc3 00000000 00000006 f5efa6d0 c1a34240 00000001 f6eab240
> [    9.196031]  f5e49aa8 c107a4e6 00000000 f6eab250 f5d43658 00000002 000d48ae 00000000
> [    9.196031] Call Trace:
> [    9.196031]  [<c15aa25c>] dump_stack+0x4b/0x75
> [    9.196031]  [<c10913fc>] __lock_acquire+0x1a0c/0x1b70
> [    9.196031]  [<c107a4e6>] ? sched_clock_local+0x46/0x150
> [    9.196031]  [<c107a8a8>] ? sched_clock_cpu+0xc8/0x140
> [    9.196031]  [<c1091bdb>] lock_acquire+0x8b/0x1b0
> [    9.196031]  [<c14fab4b>] ? dev_get_stats+0x5b/0x100
> [    9.196031]  [<f81f1db6>] rtl8169_get_stats64+0x66/0x240 [r8169]
> [    9.196031]  [<c14fab4b>] ? dev_get_stats+0x5b/0x100
> [    9.196031]  [<c14fab4b>] dev_get_stats+0x5b/0x100
> [    9.196031]  [<c151163f>] rtnl_fill_ifinfo+0x4cf/0xb30
> [    9.196031]  [<c1134c43>] ? ksize+0x13/0xa0
> [    9.196031]  [<c14f1827>] ? __alloc_skb+0x77/0x250
> [    9.196031]  [<c1511d12>] rtmsg_ifinfo+0x72/0xf0
> [    9.196031]  [<c150531e>] register_netdevice+0x45e/0x4c0
> [    9.196031]  [<c150539b>] register_netdev+0x1b/0x30
> [    9.196031]  [<f81f3e8b>] rtl_init_one+0x69b/0xbd0 [r8169]
> [    9.337799] uhci_hcd: USB Universal Host Controller Interface driver

[    9.196031]  [<c10759c7>] ? preempt_count_sub+0x67/0xf0
[    9.196031]  [<c12aca87>] pci_device_probe+0x67/0xc0
[    9.196031]  [<c11a2815>] ? sysfs_create_link+0x25/0x40
[    9.196031]  [<c13e1107>] really_probe+0x57/0x1d0
[    9.196031]  [<c12ac552>] ? pci_match_device+0xb2/0xc0
[    9.196031]  [<c13e136f>] __driver_attach+0x8f/0xa0
[    9.196031]  [<c13e12e0>] ? __device_attach+0x60/0x60
[    9.196031]  [<c13df7bf>] bus_for_each_dev+0x4f/0x80
[    9.196031]  [<c13e0cce>] driver_attach+0x1e/0x20
[    9.196031]  [<c13e12e0>] ? __device_attach+0x60/0x60
[    9.196031]  [<c13e0987>] bus_add_driver+0x147/0x200
[    9.196031]  [<c13e1929>] driver_register+0x59/0xe0
[    9.196031]  [<f82a7000>] ? 0xf82a6fff
[    9.196031]  [<c12ac67a>] __pci_register_driver+0x4a/0x50
[    9.671150] usb 3-5: new high-speed USB device number 2 using ehci-pci
[    9.196031]  [<f82a7017>] rtl8169_pci_driver_init+0x17/0x19 [r8169]
[    9.196031]  [<c10004a2>] do_one_initcall+0xf2/0x140
[    9.196031]  [<c108a38b>] ? up_read+0x1b/0x30
[    9.196031]  [<c106be82>] ? __blocking_notifier_call_chain+0x62/0xa0
[    9.196031]  [<c10c0d43>] load_module+0x1ae3/0x2290
[    9.196031]  [<c10c1576>] SyS_init_module+0x86/0xc0
[    9.196031]  [<c15b2505>] sysenter_do_call+0x12/0x36
[    9.705200] r8169 0000:02:00.0 eth0: RTL8102e at 0xf82e2000, 00:1e:68:fe:2f:2b, XID 04a00000 IRQ 45

Breakage all over the place :-(

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
