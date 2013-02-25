From: Greg Rose <gregory.v.rose@intel.com>
Subject: Re: igb: NULL pointer dereference
Date: Mon, 25 Feb 2013 09:10:39 -0800
Message-ID: <20130225091039.00007484@unknown>
References: <1361752504.2532.9.camel@bling.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <jeffrey.t.kirsher@intel.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Alex Williamson <alex.williamson@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1361752504.2532.9.camel@bling.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 24 Feb 2013 17:35:04 -0700
Alex Williamson <alex.williamson@redhat.com> wrote:

> On Linus' current tree I get the the oops below.  I realize I'm still
> using the deprecated max_vfs= module option, but this isn't a very
> compatible or friendly migration path.  I'm using an 82576 PF as an
> interface for connecting an iscsi root disk and I also use the VF off
> this interface for misc virtual machine assignment.  Suggestions
> welcome on migrating to sysfs based sr-iov enabling from an initramfs
> without bouncing the PF interface, but I think the below needs to be
> fixed regardless.  git bisected to:

This definitely looks like a bug.  You should be able to use both
methods without a problem.  I'll look into it and see if I can figure
out what's going on.

- Greg

> 
> commit fa44f2f185f7f9da19d331929bb1b56c1ccd1d93
> Author: Greg Rose <gregory.v.rose@intel.com>
> Date:   Thu Jan 17 01:03:06 2013 -0800
> 
>     igb: Enable SR-IOV configuration via PCI sysfs interface
>     
>     Implement callback in the driver for the new PCI bus driver
>     interface that allows the user to enable/disable SR-IOV
>     virtual functions in a device via the sysfs interface.
>     
>     Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
>     Tested-by: Aaron Brown <aaron.f.brown@intel.com>
>     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> Thanks,
> 
> Alex
> 
> 
> [    4.831907] igb: Intel(R) Gigabit Ethernet Network Driver -
> version 4.1.2-k [    4.838868] igb: Copyright (c) 2007-2012 Intel
> Corporation. [    4.844710] igb 0000:01:00.0: Maximum of 7 VFs per
> PF, using max [    4.850768] igb 0000:01:00.0: Enabling SR-IOV VFs
> using the module parameter is deprecated - please use the pci sysfs
> interface. [    4.872310] systemd[1]: Starting dracut initqueue
> hook... Startin[    4.877937] BUG: unable to handle kernel NULL
> pointer dereference at 0000000000000048 [    4.887143] IP:
> [<ffffffffa015862d>] igb_reset+0xcd/0x460 [igb] [    4.893175] PGD 0
> [    4.895267] Oops: 0002 [#1] SMP [    4.898666] Modules linked in:
> igb(+) ptp usb_storage pps_core iscsi_tcp be2iscsi bnx2i cnic uio
> cxgb4i cxgb4 cxgb3i cxgb3 mdio libcxgbi libiscsi_tcp qla4xxx
> iscsi_boot_sysfs libiscsi scsi_transport_iscsi [    4.918125] CPU 2
> [    4.919959] Pid: 207, comm: systemd-udevd Not tainted 3.8.0-rc3+
> #278 LENOVO 4157CTO/LENOVO [    4.928541] RIP:
> 0010:[<ffffffffa015862d>]  [<ffffffffa015862d>] igb_reset+0xcd/0x460
> [igb] [    4.937039] RSP: 0018:ffff880367f63b38  EFLAGS: 00010246
> [    4.942409] RAX: 00000000000000ff RBX: ffff880367020800 RCX:
> 0000000000000001 [    4.949601] RDX: 0000000000000000 RSI:
> 0000000000000202 RDI: ffff880367020800 [    4.956803] RBP:
> ffff880367f63b58 R08: ffff88036814d408 R09: 0000000000000007
> [    4.964004] R10: ffffffff813eea13 R11: 000000000000000f R12:
> ffff880367020d68 [    4.971205] R13: ffff880371267000 R14:
> 0000000000000040 R15: ffff880367020000 [    4.978398] FS:
> 00007fdebfc3b840(0000) GS:ffff88037fc80000(0000)
> knlGS:0000000000000000 [    4.986549] CS:  0010 DS: 0000 ES: 0000
> CR0: 0000000080050033 [    4.992369] CR2: 0000000000000048 CR3:
> 0000000367df3000 CR4: 00000000000007e0 [    4.999649] DR0:
> 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [    5.006893] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000400 [    5.014136] Process systemd-udevd (pid: 207,
> threadinfo ffff880367f62000, task ffff880367fa0000) [    5.023108]
> Stack: [    5.025280]  ffff880371267000 ffff880371267098
> ffff880371267000 0000000000000001 [    5.033327]  ffff880367f63bd8
> ffffffffa01593e5 ffff880371267098 ffff880367020d68 [    5.041400]
> 0000000000020000 ffff880367020800 0000000000000004 ffff880300007136
> [    5.049451] Call Trace: [    5.052050]  [<ffffffffa01593e5>]
> igb_probe+0x855/0xde0 [igb] [    5.058023]  [<ffffffff8131eddb>]
> local_pci_probe+0x4b/0x80 [    5.063925]  [<ffffffff8131f0e1>]
> pci_device_probe+0x111/0x120 [    5.070082]  [<ffffffff813e4c1b>]
> driver_probe_device+0x8b/0x390 [    5.076375]  [<ffffffff813e4fcb>]
> __driver_attach+0xab/0xb0 [    5.082303]  [<ffffffff813e4f20>] ?
> driver_probe_device+0x390/0x390 [    5.088736]  [<ffffffff813e2ca5>]
> bus_for_each_dev+0x55/0x90 [    5.094458]  [<ffffffff813e458e>]
> driver_attach+0x1e/0x20 [    5.099921]  [<ffffffff813e41c0>]
> bus_add_driver+0x1a0/0x290 [    5.105691]  [<ffffffffa0180000>] ?
> 0xffffffffa017ffff [    5.110937]  [<ffffffffa0180000>] ?
> 0xffffffffa017ffff [    5.116305]  [<ffffffff813e5697>]
> driver_register+0x77/0x170 [    5.122287]  [<ffffffffa0180000>] ?
> 0xffffffffa017ffff [    5.127786]  [<ffffffff8131e0ab>]
> __pci_register_driver+0x4b/0x50 [    5.134004]  [<ffffffffa018004f>]
> igb_init_module+0x4f/0x1000 [igb] [    5.140565]
> [<ffffffff8100215a>] do_one_initcall+0x12a/0x180 [    5.146321]
> [<ffffffff810c3f3a>] load_module+0x1a8a/0x20c0 [    5.152020]
> [<ffffffff8130f0a0>] ? ddebug_proc_open+0xc0/0xc0 [    5.157914]
> [<ffffffff810c4647>] sys_init_module+0xd7/0x120 [    5.163639]
> [<ffffffff81650ed9>] system_call_fastpath+0x16/0x1b [    5.169702]
> Code: 83 e9 10 45 85 c9 89 8b 14 08 00 00 74 4d 31 c9 66 0f 1f 44 00
> 00 48 63 d1 83 c1 01 48 8d 14 52 48 c1 e2 05 48 03 93 98 0e 00 00
> <83> 62 48 08 3b 8b 94 0e 00 00 72 df 48 89 df e8 2f da ff ff 48
> [    5.192637] RIP  [<ffffffffa015862d>] igb_reset+0xcd/0x460 [igb] g
> dracut initque[    5.198783]  RSP <ffff880367f63b38> [    5.203660]
> CR2: 0000000000000048 ue hook... [    5.207169] ---[ end trace
> 494789df673e4a4c ]---
> 
> 
