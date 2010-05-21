From: "Fischer, Anna" <anna.fischer@hp.com>
Subject: ixgbe and SRIOV failure in driver?
Date: Fri, 21 May 2010 16:32:56 +0000
Message-ID: <0199E0D51A61344794750DC57738F58E70B08A2A20@GVW1118EXC.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

I am running a system with 3 Intel NICs. Two of them are 82598 devices, and one is a SRIOV capable 82599.

All devices use the ixgbe driver. What happens (I believe) now is that when the driver loads at first, it sees the 82598 first (because of its position in the PCI tree) and then it says "Device not IOV capable - switching off IOV."

So then it switches into non-IOV mode, and I can never enable SRIOV on my 82599, because the driver does not enable it any more for further devices.

So to get around this issue, I tried to use pciback.hide to hide the 82598 devices from the OS. That way I was hoping that the driver would switch on SRIOV on my 82599. However, then I got a kernel panic on boot (see below).

I am running Xen 4 and the Dom0 kernel is a 2.6.31 kernel.

Any help would be greatly appreciated.

Thanks,
Anna

Starting udev: (XEN) ioapic_guest_write: apic=0, pin=16, irq=16
(XEN) ioapic_guest_write: new_entry=0001a9a8
(XEN) ioapic_guest_write: old_entry=0000a9a8 pirq=16
(XEN) ioapic_guest_write: Attempt to modify IO-APIC pin for in-use IRQ!
(XEN) printk: 11 messages suppressed.
(XEN) mm.c:859:d0 Error getting mfn 40000 (pfn 5555555555555555) from L1 entry 3
(XEN) mm.c:859:d0 Error getting mfn 40001 (pfn 5555555555555555) from L1 entry 3
(XEN) mm.c:859:d0 Error getting mfn 40002 (pfn 5555555555555555) from L1 entry 3
(XEN) mm.c:859:d0 Error getting mfn 40003 (pfn 5555555555555555) from L1 entry 3
[   23.067972] BUG: unable to handle kernel paging request at ffffc90020e10010
[   23.067985] IP: [<ffffffffa00c6652>] ixgbe_init_ops_generic+0x12/0x1c0 [ixgb]
[   23.068004] PGD 220a067 PUD 220b067 PMD 3e841067 PTE 0
[   23.068004] Oops: 0000 [#1] SMP 
[   23.068004] last sysfs file: /sys/devices/pci0000:00/0000:00:1d.1/usb6/dev
[   23.068004] CPU 0 
[   23.068004] Modules linked in: ixgbe(+) e1000e usb_storage ahci libata sd_mod
[   23.068004] Pid: 1172, comm: modprobe Not tainted 2.6.31.13 #2 Montevina Plam
[   23.068004] RIP: e030:[<ffffffffa00c6652>]  [<ffffffffa00c6652>] ixgbe_init_]
[   23.068004] RSP: e02b:ffff88003d981c78  EFLAGS: 00010246
[   23.068004] RAX: ffff88003c1ed550 RBX: ffff88003c1ed550 RCX: 0000000080050008
[   23.068004] RDX: ffffc90020e00000 RSI: ffff88003c1ed7f0 RDI: ffff88003c1ed540
[   23.068004] RBP: ffff88003d981c78 R08: 0000000000000030 R09: 00000000fffffffb
[   23.068004] R10: 0000000000000000 R11: 800000000000056b R12: ffff88003c1ed540
[   23.068004] R13: ffff88003c1ed740 R14: 00000000fffffffb R15: ffff88003c1ec000
[   23.068004] FS:  00007f24a1a736e0(0000) GS:ffffc90000000000(0000) knlGS:00000
[   23.068004] CS:  e033 DS: 0000 ES: 0000 CR0: 000000008005003b
[   23.068004] CR2: ffffc90020e10010 CR3: 000000003c183000 CR4: 0000000000002660
[   23.068004] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   23.068004] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   23.068004] Process modprobe (pid: 1172, threadinfo ffff88003d980000, task f)
[   23.068004] Stack:
[   23.068004]  ffff88003d981ca8 ffffffffa00cf7f6 ffff88003c1ed540 ffff88003c1e0
[   23.068004] <0> ffff88003c1ed540 00000000fffffffb ffff88003d981cc8 ffffffffa8
[   23.068004] <0> 00000000fffffffb ffff88003fab5000 ffff88003d981d48 ffffffffa7
[   23.068004] Call Trace:
[   23.068004]  [<ffffffffa00cf7f6>] ixgbe_init_ops_82599+0x36/0x1a0 [ixgbe]
[   23.068004]  [<ffffffffa00c8818>] ixgbe_init_shared_code+0x48/0x50 [ixgbe]
[   23.068004]  [<ffffffffa00d6b37>] ixgbe_probe+0x317/0x1380 [ixgbe]
[   23.068004]  [<ffffffff812147b0>] ? pci_match_id+0x1f/0x43
[   23.068004]  [<ffffffff812147e6>] local_pci_probe+0x12/0x16
[   23.068004]  [<ffffffff812152fc>] pci_device_probe+0x5c/0x88
[   23.068004]  [<ffffffff812e23e4>] ? driver_sysfs_add+0x4d/0x73
[   23.068004]  [<ffffffff812e2535>] driver_probe_device+0xb2/0x136
[   23.068004]  [<ffffffff812e260d>] __driver_attach+0x54/0x77
[   23.068004]  [<ffffffff812e25b9>] ? __driver_attach+0x0/0x77
[   23.068004]  [<ffffffff812e25b9>] ? __driver_attach+0x0/0x77
[   23.068004]  [<ffffffff812e1bb3>] bus_for_each_dev+0x49/0x78
[   23.068004]  [<ffffffff812e2395>] driver_attach+0x1c/0x1e
[   23.068004]  [<ffffffff812e16c2>] bus_add_driver+0xba/0x220
[   23.068004]  [<ffffffff812e299a>] driver_register+0x9e/0x115
[   23.068004]  [<ffffffff81215574>] __pci_register_driver+0x50/0xad
[   23.068004]  [<ffffffffa00eb000>] ? ixgbe_init_module+0x0/0x56 [ixgbe]
[   23.068004]  [<ffffffffa00eb054>] ixgbe_init_module+0x54/0x56 [ixgbe]
[   23.068004]  [<ffffffff8100a0e7>] do_one_initcall+0x59/0x159
[   23.068004]  [<ffffffff81095311>] sys_init_module+0xcb/0x1fe
[   23.068004]  [<ffffffff81033cc2>] system_call_fastpath+0x16/0x1b
[   23.068004] Code: 5d c9 c3 48 83 c4 08 b8 ff ff ff ff 5b 41 5c 41 5d c9 c3 6 
[   23.068004] RIP  [<ffffffffa00c6652>] ixgbe_init_ops_generic+0x12/0x1c0 [ixg]
[   23.068004]  RSP <ffff88003d981c78>
[   23.068004] CR2: ffffc90020e10010
[   23.068004] ---[ end trace a981c9cfc87a2d66 ]---

------------------------------------------------------------------------------

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
