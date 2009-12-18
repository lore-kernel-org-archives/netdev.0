From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Subject: NetXen crash in sysfs_create_file
Date: Fri, 18 Dec 2009 13:24:28 -0700
Message-ID: <200912181324.29906.bjorn.helgaas@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Amit Kumar Salecha <amit.salecha@qlogic.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932795AbZLRUYg@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With CONFIG_NETXEN_NIC=y, I got the following crash.  Turning off
NETXEN_NIC avoided it (this machine has no NetXen NIC).

This is on bea4c899f2b5fad80099aea979780ef19f9b1987 (Linus upstream from
yesterday).

Bjorn


Linux version 2.6.32 (helgaas@bob) (gcc version 4.3.2 (Debian 4.3.2-1.1) ) #9 SMP Fri Dec 18 13:13:03 MST 2009
...
QLogic/NetXen Network Driver v4.0.65
BUG: unable to handle kernel NULL pointer dereference at 0000000000000080
IP: [<ffffffff81130dc6>] sysfs_create_file+0x9/0x27
PGD 0 
Oops: 0000 [#1] SMP 
last sysfs file: 
CPU 0 
Pid: 1, comm: swapper Not tainted 2.6.32 #9 /ProLiant DL380 G6
RIP: 0010:[<ffffffff81130dc6>]  [<ffffffff81130dc6>] sysfs_create_file+0x9/0x27
RSP: 0000:ffff88041e46bed0  EFLAGS: 00010206
RAX: 0000000000000000 RBX: ffffffff81b818e8 RCX: ffffffff81abdf98
RDX: 0000000000000000 RSI: ffffffff81a61c50 RDI: 0000000000000050
RBP: ffff88041e46bed0 R08: 0000000000000000 R09: ffffffff81b818d8
R10: 00000000fffffffe R11: ffff88041e46be00 R12: ffffffff81b30bd1
R13: 0000000000000000 R14: ffffffff81ae2068 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff880028200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000080 CR3: 0000000001a0c000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 1, threadinfo ffff88041e46a000, task ffff88081e050000)
Stack:
 ffff88041e46bee0 ffffffff81b30c13 ffff88041e46bf10 ffffffff810001f0
<0> ffff88041e46bf10 ffffffff81b818e8 0000000000000040 ffffffff81ae2060
<0> ffff88041e46bf40 ffffffff81b01671 0000000000000000 0000000000000000
Call Trace:
 [<ffffffff81b30c13>] netxen_init_module+0x42/0x72
 [<ffffffff810001f0>] do_one_initcall+0x5a/0x14a
 [<ffffffff81b01671>] kernel_init+0x166/0x1bc
 [<ffffffff810037d4>] kernel_thread_helper+0x4/0x10
 [<ffffffff81b0150b>] ? kernel_init+0x0/0x1bc
 [<ffffffff810037d0>] ? kernel_thread_helper+0x0/0x10
Code: 24 0f 94 c0 84 c0 74 0f 4c 89 e7 e8 2e 08 00 00 eb 05 bb fe ff ff ff 41 59 89 d8 5b 41 5c 41 5d c9 c3 55 48 85 ff 48 89 e5 74 0e <48> 8b 7f 30 48 85 ff 74 05 48 85 f6 75 04 0f 0b eb fe ba 02 00 
RIP  [<ffffffff81130dc6>] sysfs_create_file+0x9/0x27
 RSP <ffff88041e46bed0>
CR2: 0000000000000080
---[ end trace 15e5ef3802483def ]---
swapper used greatest stack depth: 3808 bytes left
Kernel panic - not syncing: Attempted to kill init!
Pid: 1, comm: swapper Tainted: G      D    2.6.32 #9
Call Trace:
 [<ffffffff815e8add>] panic+0xa0/0x15c
 [<ffffffff81089fd8>] ? call_rcu+0x9/0xb
 [<ffffffff8103f195>] ? put_files_struct+0xb5/0xc2
 [<ffffffff81046f2d>] ? exit_ptrace+0x33/0x12b
 [<ffffffff81040844>] do_exit+0x79/0x759
 [<ffffffff8103e1c0>] ? kmsg_dump+0x112/0x12c
 [<ffffffff815ebc09>] oops_end+0xb2/0xba
 [<ffffffff81025418>] no_context+0x1f3/0x202
 [<ffffffff8103d579>] ? __call_console_drivers+0x67/0x79
 [<ffffffff810255e1>] __bad_area_nosemaphore+0x1ba/0x1e0
 [<ffffffff8103e082>] ? vprintk+0x30c/0x338
 [<ffffffff81025615>] bad_area_nosemaphore+0xe/0x10
 [<ffffffff815ed4a7>] do_page_fault+0x186/0x2c3
 [<ffffffff81b30bd1>] ? netxen_init_module+0x0/0x72
 [<ffffffff815eb11f>] page_fault+0x1f/0x30
 [<ffffffff81b30bd1>] ? netxen_init_module+0x0/0x72
 [<ffffffff81130dc6>] ? sysfs_create_file+0x9/0x27
 [<ffffffff81b30c13>] netxen_init_module+0x42/0x72
 [<ffffffff810001f0>] do_one_initcall+0x5a/0x14a
 [<ffffffff81b01671>] kernel_init+0x166/0x1bc
 [<ffffffff810037d4>] kernel_thread_helper+0x4/0x10
 [<ffffffff81b0150b>] ? kernel_init+0x0/0x1bc
 [<ffffffff810037d0>] ? kernel_thread_helper+0x0/0x10
