From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: [BUG 2.6.30-rc1] panic when loading oprofile
Date: Wed, 13 May 2009 15:30:07 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.0905131327430.7052@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, oprofile-list@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:30627 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750760AbZEMWaH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2009 18:30:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


when starting a profile run on the latest net-next kernel, I'm currently 
trying to reproduce on 2.6.30-rc5 stock.

config available upon request, arch=x86_64, recent (F10 or newer) oprofile 
userspace.


BUG: unable to handle kernel NULL pointer dereference at (null)
IP: [<ffffffff8066080a>] nmi_watchdog_tick+0xa1/0x1d6
PGD 119895067 PUD 1198aa067 PMD 0
Oops: 0000 [#1] SMP
last sysfs file: /sys/devices/pci0000:ff/0000:ff:06.3/irq
CPU 11
Modules linked in: netconsole ixgbe igb mdio(P) dca [last unloaded: scsi_wait_scan]
Pid: 6849, comm: opcontrol Tainted: P           2.6.30-rc1-nn #2
RIP: 0010:[<ffffffff8066080a>]  [<ffffffff8066080a>] nmi_watchdog_tick+0xa1/0x1d6
RSP: 0018:ffffc20001607eb8  EFLAGS: 00010046
RAX: 0000000000000000 RBX: 0000000000160c90 RCX: 00000000000000c1
RDX: ffffc20001600000 RSI: 0000000000000400 RDI: ffffffffff5fc340
RBP: ffffc20001607ef8 R08: ffff88012f817798 R09: 0000000000000002
R10: 000000000000b118 R11: ffff88011992c018 R12: 0000000000000001
R13: 000000000000000b R14: 0000000000000001 R15: ffffc20001607f58
FS:  00007f47e32726f0(0000) GS:ffffc20001600000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000000 CR3: 000000012d9b5000 CR4: 00000000000006e0
 [<ffffffff8065f87a>] nmi+0x1a/0x20
 [<ffffffff802b0669>] ? copy_page_range+0x2a5/0x774
 <<EOE>> <0> [<ffffffff802b5404>] ? __vm_enough_memory+0x34/0x158
 [<ffffffff80245551>] dup_mm+0x304/0x40c
 [<ffffffff802f608d>] ? copy_fs_struct+0x9c/0xc3
 [<ffffffff8024608a>] copy_process+0x9ca/0x114a
 [<ffffffff8024696c>] do_fork+0x162/0x2e5
 [<ffffffff802da3c9>] ? do_pipe_flags+0x9e/0xf1
 [<ffffffff8020a664>] sys_clone+0x3c/0x57
 [<ffffffff8020c303>] stub_clone+0x13/0x20
 [<ffffffff8020c01b>] ? system_call_fastpath+0x16/0x1b
Code: 0c 48 c7 c0 f0 b6 00 00 65 48 8b 14 25 40 b6 00 00 83 3c 02 00 74 0d c7 04 02 00 00 00 00 41 bc 01  RSP <ffffc20001607eb8>
CR2: 0000000000000000
---[ end trace 4e68d1e6847f8a24 ]---
BUG: unable to handle kernel NULL pointer dereference at (null)
IP: [<ffffffff8066080a>] nmi_watchdog_tick+0xa1/0x1d6
PGD 0
Oops: 0000 [#2] SMP
last sysfs file: /sys/devices/pci0000:ff/0000:ff:06.3/irq
CPU 3
Modules linked in: netconsole ixgbe igb mdio(P) dca [last unloaded: scsi_wait_scan]
Pid: 0, comm: swapper Tainted: P      D    2.6.30-rc1-nn #2
RIP: 0010:[<ffffffff8066080a>]  [<ffffffff8066080a>] nmi_watchdog_tick+0xa1/0x1d6
RSP: 0018:ffffc20000607eb8  EFLAGS: 00010046
RAX: 0000000000000000 RBX: 00000000001608d9 RCX: 00000000000000c1
RDX: ffffc20000600000 RSI: 0000000000000400 RDI: ffffffffff5fc340
RBP: ffffc20000607ef8 R08: ffff88012f817918 R09: 0000000000000002
R10: 00000000000004d1 R11: ffff88011990c018 R12: 0000000000000001
R13: 0000000000000003 R14: 0000000000000001 R15: ffffc20000607f58
FS:  0000000000000000(0000) GS:ffffc20000600000(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 0000000000000000 CR3: 0000000000201000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffff88012ff5a000, task ffff880117fe0800)
Stack:
 ffffc20000607ef8 ffffffff802643ef 4ed2b9d5740ffea4 0000000000000000
 0000000000000000 ffffc20000607f58 0000000000000000 0000000000000003
 ffffc20000607f48 ffffffff8065fe90 0000000000000000 0000000000000000
Call Trace:
 <NMI> <0> [<ffffffff802643ef>] ? notify_die+0x3d/0x53
 [<ffffffff8065fe90>] do_nmi+0xbd/0x277
 [<ffffffff8065f87a>] nmi+0x1a/0x20
 [<ffffffff80213521>] ? mwait_idle_with_hints+0xd2/0x11d
 <<EOE>> <0> [<ffffffff8021f335>] acpi_processor_ffh_cstate_enter+0x45/0x5b
 [<ffffffff804504d2>] acpi_idle_enter_bm+0x1e7/0x323
 [<ffffffff80577b5d>] ? ladder_select_state+0x4a/0x17d
 [<ffffffff80576c18>] cpuidle_idle_call+0xa4/0xf4
 [<ffffffff8020b141>] cpu_idle+0xa4/0xe0
 [<ffffffff80657c09>] start_secondary+0x1ad/0x1c8
Code: 0c 48 c7 c0 f0 b6 00 00 65 48 8b 14 25 40 b6 00 00 83 3c 02 00 74 0d c7 04 02 00 00 00 00 41 bc 01 00 00 00 48 8b 05 96 f1 46 00 <44> 0f a3 28 19 c0 85 c0 74 35 48 c7 c7 98 f9 ac 80 e8 d9 e6 ff
RIP  [<ffffffff8066080a>] nmi_watchdog_tick+0xa1/0x1d6
 RSP <ffffc20000607eb8>
CR2: 0000000000000000
---[ end trace 4e68d1e6847f8a25 ]---
BUG: unable to handle kernel <0>Kernel panic - not syncing: Fatal exception in interrupt
NULL pointer dereferencePid: 0, comm: swapper Tainted: P      D    2.6.30-rc1-nn #2
 at (null)
Call Trace:
IP: <NMI>  [<ffffffff8066080a>] nmi_watchdog_tick+0xa1/0x1d6
PGD 0  [<ffffffff8065bc2f>] panic+0x89/0x139

Oops: 0000 [#3]  [<ffffffff8066020f>] oops_end+0xba/0xe1
SMP
 [<ffffffff8022c87e>] no_context+0x201/0x224
last sysfs file: /sys/devices/pci0000:ff/0000:ff:06.3/irq
CPU 1  [<ffffffff8022ca47>] __bad_area_nosemaphore+0x1a6/0x1e0

Modules linked in: [<ffffffff80288733>] ? ring_buffer_unlock_commit+0x2e/0x46
 netconsole ixgbe [<ffffffff8058a6f5>] ? log_sample+0x7a/0xaa
 igb mdio(P) [<ffffffff8022caa7>] bad_area_nosemaphore+0x26/0x3c
 dca [last unloaded: scsi_wait_scan] [<ffffffff80661956>] do_page_fault+0x174/0x26d

 [<ffffffff8065f67f>] page_fault+0x1f/0x30
Pid: 0, comm: swapper Tainted: P      D    2.6.30-rc1-nn #2
RIP: 0010:[<ffffffff8066080a>]  [<ffffffff8066080a>] ? nmi_watchdog_tick+0xa1/0x1d6
 [<ffffffff8066080a>] nmi_watchdog_tick+0xa1/0x1d6
RSP: 0018:ffffc20000207eb8  EFLAGS: 00010046
 [<ffffffff806607ba>] ? nmi_watchdog_tick+0x51/0x1d6
RAX: 0000000000000000 RBX: 00000000001608f8 RCX: 00000000000000c1
RDX: ffffc20000200000 RSI: 0000000000000400 RDI: ffffffffff5fc340
 [<ffffffff802643ef>] ? notify_die+0x3d/0x53
RBP: ffffc20000207ef8 R08: ffff88012f817718 R09: 0000000000000002
R10: 00000000000004d1 R11: ffff880119904018 R12: 0000000000000001
 [<ffffffff8065fe90>] do_nmi+0xbd/0x277
R13: 0000000000000001 R14: 0000000000000001 R15: ffffc20000207f58
FS:  0000000000000000(0000) GS:ffffc20000200000(0000) knlGS:0000000000000000
 [<ffffffff8065f87a>] nmi+0x1a/0x20
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 0000000000000000 CR3: 0000000000201000 CR4: 00000000000006e0
 [<ffffffff80213521>] ? mwait_idle_with_hints+0xd2/0x11d
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
 <<EOE>> <6>DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffff880117fce000, task ffff880117f6c800)
 [<ffffffff8021f335>] acpi_processor_ffh_cstate_enter+0x45/0x5b
Stack:
 ffffc20000207ef8 [<ffffffff804504d2>] acpi_idle_enter_bm+0x1e7/0x323
 ffffffff802643ef 4262d253b291dadd [<ffffffff80577b5d>] ? ladder_select_state+0x4a/0x17d
 0000000000000000
 [<ffffffff80576c18>] cpuidle_idle_call+0xa4/0xf4
 0000000000000000 ffffc20000207f58 [<ffffffff8020b141>] cpu_idle+0xa4/0xe0
 0000000000000000 0000000000000001 [<ffffffff80657c09>] start_secondary+0x1ad/0x1c8

 ffffc20000207f48 ffffffff8065fe90 0000000000000000 0000000000000000
Call Trace:
 <NMI> <0> [<ffffffff802643ef>] ? notify_die+0x3d/0x53
Rebooting in 10 seconds..<0> [<ffffffff8065fe90>] do_nmi+0xbd/0x277
 [<ffffffff8065f87a>] nmi+0x1a/0x20
 [<ffffffff8042198c>] ? acpi_os_read_port+0x42/0x6f
 <<EOE>> <0> [<ffffffff8043e93b>] acpi_hw_read_port+0x41/0x62
 [<ffffffff8043e75c>] acpi_read+0x72/0xae
 [<ffffffff8043d74a>] acpi_hw_read_multiple+0x3e/0x8b
 [<ffffffff8043da41>] acpi_hw_register_read+0x67/0x10b
 [<ffffffff8043e4d3>] acpi_read_bit_register+0x40/0x74
 [<ffffffff8045035c>] acpi_idle_enter_bm+0x71/0x323
 [<ffffffff80577b5d>] ? ladder_select_state+0x4a/0x17d
 [<ffffffff80576c18>] cpuidle_idle_call+0xa4/0xf4
 [<ffffffff8020b141>] cpu_idle+0xa4/0xe0
 [<ffffffff80657c09>] start_secondary+0x1ad/0x1c8
Code: 0c 48 c7 c0 f0 b6 00 00 65 48 8b 14 25 40 b6 00 00 83 3c 02 00 74 0d c7 04 02 00 00 00 00 41 bc 01 00 00 00 48 8b 05 96 f1 46 00 <44> 0f a3 28 19 c0 85 c0 74 35 48 c7 c7 98 f9 ac 80 e8 d9 e6 ff
RIP  [<ffffffff8066080a>] nmi_watchdog_tick+0xa1/0x1d6
 RSP <ffffc20000207eb8>
CR2: 0000000000000000
---[ end trace 4e68d1e6847f8a26 ]---
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 0, comm: swapper Tainted: P      D    2.6.30-rc1-nn #2
Call Trace:
 <NMI>  [<ffffffff8065bc2f>] panic+0x89/0x139
 [<ffffffff8066020f>] oops_end+0xba/0xe1
 [<ffffffff8022c87e>] no_context+0x201/0x224
 [<ffffffff8022ca47>] __bad_area_nosemaphore+0x1a6/0x1e0
 [<ffffffff80288733>] ? ring_buffer_unlock_commit+0x2e/0x46
 [<ffffffff8058a6f5>] ? log_sample+0x7a/0xaa
 [<ffffffff8022caa7>] bad_area_nosemaphore+0x26/0x3c
 [<ffffffff80661956>] do_page_fault+0x174/0x26d
 [<ffffffff8065f67f>] page_fault+0x1f/0x30
 [<ffffffff8066080a>] ? nmi_watchdog_tick+0xa1/0x1d6
 [<ffffffff806607ba>] ? nmi_watchdog_tick+0x51/0x1d6
 [<ffffffff802643ef>] ? notify_die+0x3d/0x53
 [<ffffffff8065fe90>] do_nmi+0xbd/0x277
 [<ffffffff8065f87a>] nmi+0x1a/0x20
 [<ffffffff8042198c>] ? acpi_os_read_port+0x42/0x6f
 <<EOE>>  [<ffffffff8043e93b>] acpi_hw_read_port+0x41/0x62
 [<ffffffff8043e75c>] acpi_read+0x72/0xae
 [<ffffffff8043d74a>] acpi_hw_read_multiple+0x3e/0x8b
 [<ffffffff8043da41>] acpi_hw_register_read+0x67/0x10b
 [<ffffffff8043e4d3>] acpi_read_bit_register+0x40/0x74
 [<ffffffff8045035c>] acpi_idle_enter_bm+0x71/0x323
 [<ffffffff80577b5d>] ? ladder_select_state+0x4a/0x17d
 [<ffffffff80576c18>] cpuidle_idle_call+0xa4/0xf4
 [<ffffffff8020b141>] cpu_idle+0xa4/0xe0
 [<ffffffff80657c09>] start_secondary+0x1ad/0x1c8
Rebooting in 10 seconds..<0>Kernel panic - not syncing: Fatal exception in interrupt
Pid: 6849, comm: opcontrol Tainted: P      D    2.6.30-rc1-nn #2
Call Trace:
 <NMI>  [<ffffffff8065bc2f>] panic+0x89/0x139
 [<ffffffff8066020f>] oops_end+0xba/0xe1
 [<ffffffff8022c87e>] no_context+0x201/0x224
 [<ffffffff8022ca47>] __bad_area_nosemaphore+0x1a6/0x1e0
 [<ffffffff80288733>] ? ring_buffer_unlock_commit+0x2e/0x46
 [<ffffffff8058a6f5>] ? log_sample+0x7a/0xaa
 [<ffffffff8022caa7>] bad_area_nosemaphore+0x26/0x3c
 [<ffffffff80661956>] do_page_fault+0x174/0x26d
 [<ffffffff8065f67f>] page_fault+0x1f/0x30
 [<ffffffff8066080a>] ? nmi_watchdog_tick+0xa1/0x1d6
 [<ffffffff806607ba>] ? nmi_watchdog_tick+0x51/0x1d6
 [<ffffffff802643ef>] ? notify_die+0x3d/0x53
 [<ffffffff8065fe90>] do_nmi+0xbd/0x277
 [<ffffffff8065f87a>] nmi+0x1a/0x20
 [<ffffffff802b0669>] ? copy_page_range+0x2a5/0x774
 <<EOE>>  [<ffffffff802b5404>] ? __vm_enough_memory+0x34/0x158
 [<ffffffff80245551>] dup_mm+0x304/0x40c
 [<ffffffff802f608d>] ? copy_fs_struct+0x9c/0xc3
 [<ffffffff8024608a>] copy_process+0x9ca/0x114a
 [<ffffffff8024696c>] do_fork+0x162/0x2e5
 [<ffffffff802da3c9>] ? do_pipe_flags+0x9e/0xf1
 [<ffffffff8020a664>] sys_clone+0x3c/0x57
 [<ffffffff8020c303>] stub_clone+0x13/0x20
 [<ffffffff8020c01b>] ? system_call_fastpath+0x16/0x1b

