From: Liu Bo <bo.li.liu@oracle.com>
Subject: e1000 crash on 3.15.0-rc4
Date: Wed, 7 May 2014 13:32:46 +0800
Message-ID: <20140507053245.GB15783@localhost.localdomain>
Reply-To: bo.li.liu@oracle.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: e1000-devel@lists.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'm using qemu to load kernel of 3.15.0-rc4, and with CONFIG_E1000=y,
everying is ok, but with CONFIG_E1000=m, I got the following crash:

[...]
[    6.020409] tsc: Refined TSC clocksource calibration: 2491.912 MHz
[    6.074925] floppy: Unknown symbol mutex_lock (err 0)
[    6.128579] virtio_blk: Unknown symbol mutex_lock (err 0)
[    6.141264] i2c_core: Unknown symbol mutex_lock (err 0)
[    6.167490] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
[    6.168240] e1000: Copyright (c) 1999-2006 Intel Corporation.
[    6.171078] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 10
[    6.190295] BUG: spinlock bad magic on CPU#3, systemd-udevd/208
[    6.190686]  lock: e1000_eeprom_lock+0x0/0xffffffffffff81b6 [e1000], .magic:
00000000, .owner: <none>/-1, .owner_cpu: 0
[    6.191402] CPU: 3 PID: 208 Comm: systemd-udevd Not tainted 3.15.0-rc4+ #107
[    6.191800] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs
01/01/2011
[    6.192457]  ffffffffa00aee4a ffff88005f2fd968 ffffffff817901cb
0000000000000007
[    6.193454]  0000000000000000 ffff88005f2fd988 ffffffff8178b460
ffffffffa00aee4a
[    6.194893]  ffffffff81a3bcfb ffff88005f2fd9a8 ffffffff8178b48b
ffffffffa00aee4a
[    6.196842] Call Trace:
[    6.197523]  [<ffffffff817901cb>] dump_stack+0x4e/0x68
[    6.198287]  [<ffffffff8178b460>] spin_dump+0x91/0x96
[    6.199269]  [<ffffffff8178b48b>] spin_bug+0x26/0x2b
[    6.199944]  [<ffffffff810c8bfe>] do_raw_spin_lock+0x13e/0x160
[    6.202632]  [<ffffffff81798491>] _raw_spin_lock+0x41/0x50
[    6.203287]  [<ffffffffa009ebd9>] ? e1000_read_eeprom+0x39/0x240 [e1000]
[    6.203966]  [<ffffffffa009ebd9>] e1000_read_eeprom+0x39/0x240 [e1000]
[    6.204741]  [<ffffffffa00a0bc0>] e1000_validate_eeprom_checksum+0x40/0xd0
[e1000]
[    6.205893]  [<ffffffffa009d5b8>] ? e1000_reset_hw+0xb8/0x340 [e1000]
[    6.206658]  [<ffffffffa0097c8b>] e1000_probe+0x6bb/0xe50 [e1000]
[    6.207520]  [<ffffffff8142f28e>] local_pci_probe+0x4e/0xa0
[    6.208248]  [<ffffffff814e79d7>] ? get_device+0x17/0x30
[    6.209085]  [<ffffffff8142f599>] pci_device_probe+0xd9/0x120
[    6.209792]  [<ffffffff814ec95d>] driver_probe_device+0x9d/0x3d0
[    6.210661]  [<ffffffff814ecd3b>] __driver_attach+0xab/0xb0
[    6.211423]  [<ffffffff814ecc90>] ? driver_probe_device+0x3d0/0x3d0
[    6.212304]  [<ffffffff814ea8dd>] bus_for_each_dev+0x5d/0xa0
[    6.213086]  [<ffffffff814ec29e>] driver_attach+0x1e/0x20
[    6.213717]  [<ffffffff814ebec7>] bus_add_driver+0x127/0x250
[    6.214538]  [<ffffffffa00b5000>] ? 0xffffffffa00b4fff
[    6.215307]  [<ffffffff814ed434>] driver_register+0x64/0xf0
[    6.215921]  [<ffffffffa00b5000>] ? 0xffffffffa00b4fff
[    6.216550]  [<ffffffff8142e5a4>] __pci_register_driver+0x64/0x70
[    6.217271]  [<ffffffffa00b5051>] e1000_init_module+0x51/0x1000 [e1000]
[    6.218152]  [<ffffffff8100032a>] do_one_initcall+0xda/0x180
[    6.218794]  [<ffffffff81043d13>] ? set_memory_nx+0x43/0x50
[    6.219596]  [<ffffffff8178b7cf>] ? set_section_ro_nx+0x6d/0x74
[    6.220408]  [<ffffffff810f7b16>] load_module+0x1c86/0x2680
[    6.221225]  [<ffffffff810f3a60>] ? module_unload_free+0xf0/0xf0
[    6.222109]  [<ffffffff810f85e7>] SyS_init_module+0xd7/0x120
[    6.222827]  [<ffffffff817a1ed2>] system_call_fastpath+0x16/0x1b
[    6.507708] BUG: unable to handle kernel NULL pointer dereference at
(null)
[    6.508083] IP: [<ffffffff81400ac2>] memcpy+0x12/0x110
[    6.508083] PGD 0 
[    6.508083] Oops: 0002 [#1] SMP 
[    6.508083] Modules linked in: e1000(+)
[    6.508083] CPU: 3 PID: 208 Comm: systemd-udevd Not tainted 3.15.0-rc4+ #107
[    6.508083] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs
01/01/2011
[    6.508083] task: ffff88001ee94420 ti: ffff88005f2fc000 task.ti:
ffff88005f2fc000
[    6.508083] RIP: 0010:[<ffffffff81400ac2>]  [<ffffffff81400ac2>]
memcpy+0x12/0x110
[    6.508083] RSP: 0018:ffff88005f2fdaa0  EFLAGS: 00010206
[    6.508083] RAX: 0000000000000000 RBX: ffff88004f3f7000 RCX: 0000000000000006
[    6.508083] RDX: 0000000000000006 RSI: ffff880021488cdc RDI: 0000000000000000
[    6.508083] RBP: ffff88005f2fdb28 R08: 0000000000000003 R09: 0000000000000000
[    6.508083] R10: ffff88001ee94420 R11: 0000000000000000 R12: 0000000000000043
[    6.508083] R13: ffff880021488be8 R14: ffff880021488000 R15: ffff880021488cdc
[    6.508083] FS:  00007f542c158840(0000) GS:ffff880051d80000(0000)
knlGS:0000000000000000
[    6.508083] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    6.508083] CR2: 0000000000000000 CR3: 000000005f31c000 CR4: 00000000000006e0
[    6.508083] Stack:
[    6.508083]  ffffffffa0097ccb ffff88005f2fdac8 0000000000000002
0000000000000286
[    6.508083]  ffff88004f3f71a0 ffff880021488880 ffff88004f3f7098
ffff88005f2fdaf8
[    6.508083]  0000000000000286 0000000000000001 0000000000000004
ffff88005f2fdb28
[    6.508083] Call Trace:
[    6.508083]  [<ffffffffa0097ccb>] ? e1000_probe+0x6fb/0xe50 [e1000]
[    6.508083]  [<ffffffff8142f28e>] local_pci_probe+0x4e/0xa0
[    6.508083]  [<ffffffff814e79d7>] ? get_device+0x17/0x30
[    6.508083]  [<ffffffff8142f599>] pci_device_probe+0xd9/0x120
[    6.508083]  [<ffffffff814ec95d>] driver_probe_device+0x9d/0x3d0
[    6.508083]  [<ffffffff814ecd3b>] __driver_attach+0xab/0xb0
[    6.508083]  [<ffffffff814ecc90>] ? driver_probe_device+0x3d0/0x3d0
[    6.508083]  [<ffffffff814ea8dd>] bus_for_each_dev+0x5d/0xa0
[    6.508083]  [<ffffffff814ec29e>] driver_attach+0x1e/0x20
[    6.508083]  [<ffffffff814ebec7>] bus_add_driver+0x127/0x250
[    6.508083]  [<ffffffffa00b5000>] ? 0xffffffffa00b4fff
[    6.508083]  [<ffffffff814ed434>] driver_register+0x64/0xf0
[    6.508083]  [<ffffffffa00b5000>] ? 0xffffffffa00b4fff
[    6.508083]  [<ffffffff8142e5a4>] __pci_register_driver+0x64/0x70
[    6.508083]  [<ffffffffa00b5051>] e1000_init_module+0x51/0x1000 [e1000]
[    6.508083]  [<ffffffff8100032a>] do_one_initcall+0xda/0x180
[    6.508083]  [<ffffffff81043d13>] ? set_memory_nx+0x43/0x50
[    6.508083]  [<ffffffff8178b7cf>] ? set_section_ro_nx+0x6d/0x74
[    6.508083]  [<ffffffff810f7b16>] load_module+0x1c86/0x2680
[    6.508083]  [<ffffffff810f3a60>] ? module_unload_free+0xf0/0xf0
[    6.508083]  [<ffffffff810f85e7>] SyS_init_module+0xd7/0x120
[    6.508083]  [<ffffffff817a1ed2>] system_call_fastpath+0x16/0x1b
[    6.508083] Code: 4e 48 83 c4 08 5b 5d c3 90 e8 eb fb ff ff eb e6 90 90 90 90
90 90 90 90 90 48 89 f8 48 89 d1 48 c1 e9 03 83 e2 07 f3 48 a5 89 d1 <f3> a4 c3
20 4c 8b 06 4c 8b 4e 08 4c 8b 56 10 4c 8b 5e 18 48 8d 
[    6.508083] RIP  [<ffffffff81400ac2>] memcpy+0x12/0x110
[    6.508083]  RSP <ffff88005f2fdaa0>
[    6.508083] CR2: 0000000000000000
[    6.508083] ---[ end trace 14c0661a8d561d06 ]---
[    6.508083] BUG: sleeping function called from invalid context at
kernel/locking/rwsem.c:20
[    6.508083] in_atomic(): 1, irqs_disabled(): 1, pid: 208, name: systemd-udevd
[    6.508083] INFO: lockdep is turned off.
[    6.508083] irq event stamp: 30639
[    6.508083] hardirqs last  enabled at (30639): [<ffffffff81798cdf>]
_raw_spin_unlock_irqrestore+0x3f/0x70
[    6.508083] hardirqs last disabled at (30638): [<ffffffff81798581>]
_raw_spin_lock_irqsave+0x21/0x60
[    6.508083] softirqs last  enabled at (30616): [<ffffffff810740bd>]
__do_softirq+0x1ed/0x310
[    6.508083] softirqs last disabled at (30611): [<ffffffff810744c5>]
irq_exit+0xb5/0xc0
[    6.508083] CPU: 3 PID: 208 Comm: systemd-udevd Tainted: G      D
3.15.0-rc4+ #107
[    6.508083] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs
01/01/2011
[    6.508083]  0000000000000009 ffff88005f2fd6b8 ffffffff817901cb
0000000000000007
[    6.508083]  ffff88001ee94420 ffff88005f2fd6d8 ffffffff8109cd89
ffff88005f2fd758
[    6.508083]  ffff88001ee5d158 ffff88005f2fd708 ffffffff81797324
0000000000000086
[    6.508083] Call Trace:
[    6.508083]  [<ffffffff817901cb>] dump_stack+0x4e/0x68
[    6.508083]  [<ffffffff8109cd89>] __might_sleep+0xe9/0x120
[    6.508083]  [<ffffffff81797324>] down_read+0x24/0x70
[    6.508083]  [<ffffffff81081c04>] exit_signals+0x24/0x130
[    6.508083]  [<ffffffff81097f86>] ? blocking_notifier_call_chain+0x16/0x20
[    6.508083]  [<ffffffff81071407>] do_exit+0xb7/0xaa0
[    6.508083]  [<ffffffff810d5ffc>] ? kmsg_dump+0xfc/0x110
[    6.508083]  [<ffffffff810d5f25>] ? kmsg_dump+0x25/0x110
[    6.508083]  [<ffffffff8179a135>] oops_end+0x95/0xe0
[    6.508083]  [<ffffffff81789dd2>] no_context+0x28c/0x2b7
[    6.508083]  [<ffffffff81789fc2>] __bad_area_nosemaphore+0x1c5/0x1e4
[    6.508083]  [<ffffffff81789ff4>] bad_area_nosemaphore+0x13/0x15
[    6.508083]  [<ffffffff8179ca12>] __do_page_fault+0xd2/0x550
[    6.508083]  [<ffffffff810e0658>] ? rcu_irq_exit+0x68/0xb0
[    6.508083]  [<ffffffff8179931c>] ? retint_restore_args+0xe/0xe
[    6.508083]  [<ffffffff813ffb8a>] ? delay_tsc+0x3a/0x80
[    6.508083]  [<ffffffff8140107d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[    6.508083]  [<ffffffff8179ce9c>] do_page_fault+0xc/0x10
[    6.508083]  [<ffffffff81799552>] page_fault+0x22/0x30
[    6.508083]  [<ffffffff81400ac2>] ? memcpy+0x12/0x110
[    6.508083]  [<ffffffffa0097ccb>] ? e1000_probe+0x6fb/0xe50 [e1000]
[    6.508083]  [<ffffffff8142f28e>] local_pci_probe+0x4e/0xa0
[    6.508083]  [<ffffffff814e79d7>] ? get_device+0x17/0x30
[    6.508083]  [<ffffffff8142f599>] pci_device_probe+0xd9/0x120
[    6.508083]  [<ffffffff814ec95d>] driver_probe_device+0x9d/0x3d0
[    6.508083]  [<ffffffff814ecd3b>] __driver_attach+0xab/0xb0
[    6.508083]  [<ffffffff814ecc90>] ? driver_probe_device+0x3d0/0x3d0
[    6.508083]  [<ffffffff814ea8dd>] bus_for_each_dev+0x5d/0xa0
[    6.508083]  [<ffffffff814ec29e>] driver_attach+0x1e/0x20
[    6.508083]  [<ffffffff814ebec7>] bus_add_driver+0x127/0x250
[    6.508083]  [<ffffffffa00b5000>] ? 0xffffffffa00b4fff
[    6.508083]  [<ffffffff814ed434>] driver_register+0x64/0xf0
[    6.508083]  [<ffffffffa00b5000>] ? 0xffffffffa00b4fff
[    6.508083]  [<ffffffff8142e5a4>] __pci_register_driver+0x64/0x70
[    6.508083]  [<ffffffffa00b5051>] e1000_init_module+0x51/0x1000 [e1000]
[    6.508083]  [<ffffffff8100032a>] do_one_initcall+0xda/0x180
[    6.508083]  [<ffffffff81043d13>] ? set_memory_nx+0x43/0x50
[    6.508083]  [<ffffffff8178b7cf>] ? set_section_ro_nx+0x6d/0x74
[    6.508083]  [<ffffffff810f7b16>] load_module+0x1c86/0x2680
[    6.508083]  [<ffffffff810f3a60>] ? module_unload_free+0xf0/0xf0
[    6.508083]  [<ffffffff810f85e7>] SyS_init_module+0xd7/0x120
[    6.508083]  [<ffffffff817a1ed2>] system_call_fastpath+0x16/0x1b
[    6.508083] note: systemd-udevd[208] exited with preempt_count 67
[...]

----------------------

Is this a regression?

thanks,
-liubo
