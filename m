From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Subject: [BUG] linux-next: Tree for June 24 - kernel panic at tg3_reset_hw()
 on x86_64
Date: Tue, 24 Jun 2008 17:21:04 +0530
Message-ID: <4860DFA8.9040408@linux.vnet.ibm.com>
References: <20080624175612.cdf29651.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, kernel-testers@vger.kernel.org,
	mchan@broadcom.com, Andy Whitcroft <apw@shadowen.org>,
	Balbir Singh <balbir@linux.vnet.ibm.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20080624175612.cdf29651.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

While booting up the next-20080624 kernel on the x86_64 box, kernel panics.
Kernel panics of two different x86_64 machines are pasted below

BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
IP: [<ffffffff803be0d0>] tg3_reset_hw+0xf48/0x154b
PGD 101e9067 PUD 10098067 PMD 0 
Oops: 0000 [1] SMP 
last sysfs file: /sys/class/net/eth1/address
CPU 0 
Modules linked in: battery ac lp parport_pc parport nvram amd_rng rng_core pcspkr button i2c_amd756 i2c_core
Pid: 1922, comm: ip Not tainted 2.6.26-rc7-next-20080624-autotest #1
RIP: 0010:[<ffffffff803be0d0>]  [<ffffffff803be0d0>] tg3_reset_hw+0xf48/0x154b
RSP: 0018:ffff8100101d5d38  EFLAGS: 00010246
RAX: 000000000040a026 RBX: 000000000001f800 RCX: 0000000000000000
RDX: 0000000000000006 RSI: 0000000000005400 RDI: ffff81003d49a740
RBP: ffff81003d49a740 R08: 0000000000000002 R09: 0000000000000008
R10: 0000000000000009 R11: ffffffff8047754d R12: 0000000001000008
R13: 00000000000003fe R14: ffff81003d49a748 R15: 0000000000000000
FS:  00007f8b537c36f0(0000) GS:ffffffff806afd40(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000008 CR3: 0000000011c79000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process ip (pid: 1922, threadinfo ffff8100101d4000, task ffff81003d698be0)
Stack:  ffff81003d49a740 0000000000000074 0000000000000028 ffff000880340560
 ffff81003d49a740 ffff81003d49a800 ffff81003d49a740 0000000000001002
 0000000000000000 ffff81003d49a748 ffff81003d49a000 ffffffff803c2971
Call Trace:
 [<ffffffff803c2971>] tg3_open+0x29b/0x5ee
 [<ffffffff80317c24>] selinux_capable+0x87/0x90
 [<ffffffff8048661b>] dev_open+0x6c/0xa0
 [<ffffffff80485131>] dev_change_flags+0xa6/0x15d
 [<ffffffff804c4826>] devinet_ioctl+0x243/0x5a1
 [<ffffffff80278a9b>] handle_mm_fault+0x32b/0x6a5
 [<ffffffff804795d0>] sock_ioctl+0x1d4/0x1f8
 [<ffffffff8029eb51>] vfs_ioctl+0x21/0x6b
 [<ffffffff8029edf7>] do_vfs_ioctl+0x25c/0x275
 [<ffffffff8029ee61>] sys_ioctl+0x51/0x70
 [<ffffffff8020bd0b>] system_call_after_swapgs+0x7b/0x80


Code: ef e8 63 a0 ff ff 8b 85 88 07 00 00 a8 20 0f 84 06 01 00 00 a9 00 00 01 08 0f 85 fb 00 00 00 48 8b 8d 48 0b 00 00 be 00 54 00 00 <48> 8b 51 08 8b 42 04 48 83 c2 0c 0f c8 89 04 24 8b 01 b9 00 40 
RIP  [<ffffffff803be0d0>] tg3_reset_hw+0xf48/0x154b
 RSP <ffff8100101d5d38>
CR2: 0000000000000008
---[ end trace 9f49694bab0b33db ]---
Kernel panic - not syncing: Aiee, killing interrupt handler!
Pid: 1922, comm: ip Tainted: G      D   2.6.26-rc7-next-20080624-autotest #1

Call Trace:
 [<ffffffff8023366f>] panic+0x86/0x144
 [<ffffffff80252f75>] kallsyms_lookup+0x49/0x80
 [<ffffffff803be0d0>] tg3_reset_hw+0xf48/0x154b
 [<ffffffff802341e2>] printk+0x4e/0x56
 [<ffffffff802341e2>] printk+0x4e/0x56
 [<ffffffff80236764>] do_exit+0x71/0x67c
 [<ffffffff804fdc71>] oops_begin+0x0/0x8c
 [<ffffffff804ffb84>] do_page_fault+0x77b/0x834
 [<ffffffff804fd8b9>] error_exit+0x0/0x51
 [<ffffffff8047754d>] pci_conf1_write+0x0/0xdb
 [<ffffffff803be0d0>] tg3_reset_hw+0xf48/0x154b
 [<ffffffff803bdf9b>] tg3_reset_hw+0xe13/0x154b
 [<ffffffff803c2971>] tg3_open+0x29b/0x5ee
 [<ffffffff80317c24>] selinux_capable+0x87/0x90
 [<ffffffff8048661b>] dev_open+0x6c/0xa0
 [<ffffffff80485131>] dev_change_flags+0xa6/0x15d
 [<ffffffff804c4826>] devinet_ioctl+0x243/0x5a1
 [<ffffffff80278a9b>] handle_mm_fault+0x32b/0x6a5
 [<ffffffff804795d0>] sock_ioctl+0x1d4/0x1f8
 [<ffffffff8029eb51>] vfs_ioctl+0x21/0x6b
 [<ffffffff8029edf7>] do_vfs_ioctl+0x25c/0x275
 [<ffffffff8029ee61>] sys_ioctl+0x51/0x70
 [<ffffffff8020bd0b>] system_call_after_swapgs+0x7b/0x80

BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
IP: [<ffffffff803db3e1>] tg3_reset_hw+0xfc2/0x1559
PGD 17ff33067 PUD 17ee89067 PMD 0 
Oops: 0000 [1] SMP 
last sysfs file: /sys/devices/pci0000:00/0000:00:0a.0/0000:02:04.0/host0/target0:0:6/0:0:6:0/type
CPU 2 
Modules linked in:
Pid: 2111, comm: ifconfig Not tainted 2.6.26-rc7-next-20080624-autotest #1
RIP: 0010:[<ffffffff803db3e1>]  [<ffffffff803db3e1>] tg3_reset_hw+0xfc2/0x1559
RSP: 0000:ffff8101fe6dbbd8  EFLAGS: 00010246
RAX: 0000000000000000 RBX: 00000000000003fe RCX: 0000000000001002
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000000
RBP: ffff81007ee146c0 R08: 0000000000000002 R09: 0000000000000008
R10: 0000000000000010 R11: ffffffff80427969 R12: 0000000000005000
R13: 0000000000000000 R14: ffff8100e3136800 R15: ffff81007ee14000
FS:  0000000000000000(0000) GS:ffff81017ff0f000(0063) knlGS:00000000f7ddb460
CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
CR2: 0000000000000008 CR3: 000000017f3bb000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process ifconfig (pid: 2111, threadinfo ffff8101fe6da000, task ffff8100e2cb37a0)
Stack:  0000000000000000 000881007ee146c0 000000000000004c ffffffff80365680
 ffff81007ee146c0 0000000000000074 0000000000000028 ffff81007ee146c0
 0000000000000001 0000000000000000 0000000000000000 ffffffff803db9ab
Call Trace:
 [<ffffffff80365680>] __delay+0x1c/0x41
 [<ffffffff803db9ab>] tg3_init_hw+0x33/0x38
 [<ffffffff803dbee6>] tg3_open+0x29e/0x600
 [<ffffffff80438556>] dev_open+0x73/0xac
 [<ffffffff80438bf9>] dev_change_flags+0xa3/0x15b
 [<ffffffff8046e17e>] devinet_ioctl+0x288/0x5d8
 [<ffffffff8046fc7f>] inet_ioctl+0x8f/0xa7
 [<ffffffff8042ce22>] sock_ioctl+0x0/0x19c
 [<ffffffff8042cf9a>] sock_ioctl+0x178/0x19c
 [<ffffffff8028b899>] vfs_ioctl+0x29/0x6f
 [<ffffffff8028bb2c>] do_vfs_ioctl+0x24d/0x25c
 [<ffffffff8028bb77>] sys_ioctl+0x3c/0x61
 [<ffffffff802ad2ae>] dev_ifsioc+0xdb/0x216
 [<ffffffff802aeea3>] compat_sys_ioctl+0x2df/0x320
 [<ffffffff8021e4cb>] do_page_fault+0x44c/0x7fe
 [<ffffffff8042c696>] sock_map_fd+0x44/0x4b
 [<ffffffff8036305d>] __up_read+0x10/0x96
 [<ffffffff802226d2>] ia32_sysret+0x0/0xa


Code: 4a 01 00 00 31 c0 81 e2 00 00 01 08 0f 85 34 01 00 00 48 8b bd c8 0a 00 00 8b 8d cc 07 00 00 41 bc 00 50 00 00 8b b5 d0 0a 00 00 <48> 8b 57 08 c1 e9 0c 8b 42 04 48 83 c2 0c 0f c8 89 44 24 10 8b 
RIP  [<ffffffff803db3e1>] tg3_reset_hw+0xfc2/0x1559
 RSP <ffff8101fe6dbbd8>
CR2: 0000000000000008
---[ end trace c1b9eba54c29dd60 ]---
Kernel panic - not syncing: Aiee, killing interrupt handler!
Pid: 2111, comm: ifconfig Tainted: G      D   2.6.26-rc7-next-20080624-autotest #1

Call Trace:
 [<ffffffff8022fa37>] panic+0xc4/0x181
 [<ffffffff80230ac3>] printk+0x8d/0x95
 [<ffffffff802325a2>] do_exit+0x1d8/0x65f
 [<ffffffff8020cd8c>] __die+0x0/0xd7
 [<ffffffff8021e7d4>] do_page_fault+0x755/0x7fe
 [<ffffffff804ad9c9>] error_exit+0x0/0x51
 [<ffffffff80427969>] pci_conf1_write+0x0/0xd2
 [<ffffffff803db3e1>] tg3_reset_hw+0xfc2/0x1559
 [<ffffffff803db25f>] tg3_reset_hw+0xe40/0x1559
 [<ffffffff80365680>] __delay+0x1c/0x41
 [<ffffffff803db9ab>] tg3_init_hw+0x33/0x38
 [<ffffffff803dbee6>] tg3_open+0x29e/0x600
 [<ffffffff80438556>] dev_open+0x73/0xac
 [<ffffffff80438bf9>] dev_change_flags+0xa3/0x15b
 [<ffffffff8046e17e>] devinet_ioctl+0x288/0x5d8
 [<ffffffff8046fc7f>] inet_ioctl+0x8f/0xa7
 [<ffffffff8042ce22>] sock_ioctl+0x0/0x19c
 [<ffffffff8042cf9a>] sock_ioctl+0x178/0x19c
 [<ffffffff8028b899>] vfs_ioctl+0x29/0x6f
 [<ffffffff8028bb2c>] do_vfs_ioctl+0x24d/0x25c
 [<ffffffff8028bb77>] sys_ioctl+0x3c/0x61
 [<ffffffff802ad2ae>] dev_ifsioc+0xdb/0x216
 [<ffffffff802aeea3>] compat_sys_ioctl+0x2df/0x320
 [<ffffffff8021e4cb>] do_page_fault+0x44c/0x7fe
 [<ffffffff8042c696>] sock_map_fd+0x44/0x4b
 [<ffffffff8036305d>] __up_read+0x10/0x96
 [<ffffffff802226d2>] ia32_sysret+0x0/0xa

-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.
