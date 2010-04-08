From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: panic in net-next almost immediately on ifup
Date: Thu, 8 Apr 2010 12:57:27 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FE4F6AC08@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8834 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932642Ab0DHS5b convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 14:57:31 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am seeing the following panic on a fresh net-next pull. 

Seems like ipv6/mcast related issue? Panic points to /net/ipv6/mcast.c:1490

[   49.375726] BUG: unable to handle kernel paging request at fffffffe81bf1048
[   49.382833] IP: [<ffffffff8143971b>] mld_sendpack+0x2bd/0x2f1
[   49.388668] PGD 1a0a067 PUD 0 
[   49.391858] Oops: 0000 [#1] SMP 
[   49.395228] last sysfs file: /sys/devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.1/devnum
[   49.403251] CPU 2 
[   49.405124] Modules linked in: e1000 [last unloaded: scsi_wait_scan]
[   49.411883] 
[   49.413416] Pid: 2235, comm: grep Not tainted 2.6.34-rc2-net-next-master #7 X8SIL/X8SIL
[   49.421442] RIP: 0010:[<ffffffff8143971b>]  [<ffffffff8143971b>] mld_sendpack+0x2bd/0x2f1
[   49.429689] RSP: 0000:ffff880001e83d50  EFLAGS: 00010202
[   49.435220] RAX: 000060fffde056e8 RBX: ffff8801b605fc00 RCX: ffff8801b605ff00
[   49.442565] RDX: ffff880001e90880 RSI: ffff880001e83aa0 RDI: ffffffff8139e741
[   49.449913] RBP: ffff880001e83de0 R08: ffffffff81a63f9c R09: 000000000000004c
[   49.457258] R10: 000000000947d5de R11: ffff880180000000 R12: ffff8801bce62800
[   49.464606] R13: fffffffe81bf0ee0 R14: 000000000000004c R15: 000000000000001c
[   49.471953] FS:  0000000000000000(0000) GS:ffff880001e80000(0000) knlGS:0000000000000000
[   49.480440] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   49.486403] CR2: fffffffe81bf1048 CR3: 00000001b61d1000 CR4: 00000000000006e0
[   49.493750] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   49.501097] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   49.508444] Process grep (pid: 2235, threadinfo ffff8801b609e000, task ffff8801bcda6320)
[   49.516928] Stack:
[   49.519168]  ffff8801b61cd010 0000004000000002 0000000000000003 000002ff00000000
[   49.526773] <0> 0000000000000000 0000000016000000 0000000000000000 0000000000000000
[   49.535106] <0> 0000008f0000003a 0000000000000000 ffff880001e83db0 ffff8801b6024500
[   49.543851] Call Trace:
[   49.546522]  <IRQ> 
[   49.548902]  [<ffffffff81439e3f>] mld_ifc_timer_expire+0x236/0x26f
[   49.555301]  [<ffffffff8102ad26>] ? task_tick_fair+0x28/0x108
[   49.561261]  [<ffffffff81439c09>] ? mld_ifc_timer_expire+0x0/0x26f
[   49.567661]  [<ffffffff81042f71>] run_timer_softirq+0x1b3/0x250
[   49.573805]  [<ffffffff810177e4>] ? apic_write+0x11/0x13
[   49.579335]  [<ffffffff8103c87d>] __do_softirq+0xda/0x195
[   49.584954]  [<ffffffff8105b3b9>] ? tick_program_event+0x25/0x27
[   49.591183]  [<ffffffff8100384c>] call_softirq+0x1c/0x28
[   49.596714]  [<ffffffff81004e47>] do_softirq+0x33/0x68
[   49.602074]  [<ffffffff8103c6fd>] irq_exit+0x36/0x78
[   49.607261]  [<ffffffff81018028>] smp_apic_timer_interrupt+0x80/0x8e
[   49.613830]  [<ffffffff81003313>] apic_timer_interrupt+0x13/0x20
[   49.620049]  <EOI> 
[   49.622011] Code: 25 80 d1 00 00 48 8d 04 02 48 ff 80 b0 00 00 00 4c 01 b0 e0 00 00 00 eb 1e 4d 85 e4 74 0d 49 8b 84 24 68 01 00 00 65 48 ff 40 60 <49> 8b 85 68 01 00 00 65 48 ff 40 60 4d 85 e4 74 14 4c 89 e7 e8 
[   49.645200] RIP  [<ffffffff8143971b>] mld_sendpack+0x2bd/0x2f1
[   49.651310]  RSP <ffff880001e83d50>
[   49.655018] CR2: fffffffe81bf1048
[   49.658556] ---[ end trace be71aeb787ca2f3b ]---
[   49.663395] Kernel panic - not syncing: Fatal exception in interrupt
[   49.669964] Pid: 2235, comm: grep Tainted: G      D    2.6.34-rc2-net-next-master #7
[   49.678104] Call Trace:
[   49.680775]  <IRQ>  [<ffffffff814b25f7>] panic+0x73/0xe8
[   49.686361]  [<ffffffff814b5268>] oops_end+0xa9/0xb9
[   49.691547]  [<ffffffff810208e5>] no_context+0x1f7/0x206
[   49.697077]  [<ffffffff81020a6d>] __bad_area_nosemaphore+0x179/0x19c
[   49.703647]  [<ffffffff81020a9e>] bad_area_nosemaphore+0xe/0x10
[   49.709783]  [<ffffffff814b70f1>] do_page_fault+0x135/0x273
[   49.715574]  [<ffffffff814b479f>] page_fault+0x1f/0x30
[   49.720935]  [<ffffffff8139e741>] ? dev_queue_xmit+0x403/0x437
[   49.726982]  [<ffffffff8143971b>] ? mld_sendpack+0x2bd/0x2f1
[   49.732858]  [<ffffffff81439e3f>] mld_ifc_timer_expire+0x236/0x26f
[   49.739255]  [<ffffffff8102ad26>] ? task_tick_fair+0x28/0x108
[   49.745219]  [<ffffffff81439c09>] ? mld_ifc_timer_expire+0x0/0x26f
[   49.751615]  [<ffffffff81042f71>] run_timer_softirq+0x1b3/0x250
[   49.757752]  [<ffffffff810177e4>] ? apic_write+0x11/0x13
[   49.763281]  [<ffffffff8103c87d>] __do_softirq+0xda/0x195
[   49.768901]  [<ffffffff8105b3b9>] ? tick_program_event+0x25/0x27
[   49.775124]  [<ffffffff8100384c>] call_softirq+0x1c/0x28
[   49.780653]  [<ffffffff81004e47>] do_softirq+0x33/0x68
[   49.786014]  [<ffffffff8103c6fd>] irq_exit+0x36/0x78
[   49.791200]  [<ffffffff81018028>] smp_apic_timer_interrupt+0x80/0x8e
[   49.797767]  [<ffffffff81003313>] apic_timer_interrupt+0x13/0x20
[   49.803987]  <EOI> 

Emil