From: Ed Tomlinson <edt@aei.ca>
Subject: [2.6.30-rc1] NULL pointer dereference
Date: Tue, 7 Apr 2009 22:06:28 -0400
Message-ID: <200904072206.29396.edt@aei.ca>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757516AbZDHCGv@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I got tired of rebuilding the drm and radeon modules to support my R600 card so I decided to
try .30-rc.  It lasted about 30 minutes then I got the exception below when start a freenet node.

The ipv6 interface is supplied by www.sixxs.org but my tunnel broker is currently down so aside
from the local link address on eth0 (and locl) there are no ipv6 intefaces on my box.

Hope this helps,
Ed Tomlinson

[ 1982.214334] BUG: unable to handle kernel NULL pointer dereference at 0000000000000062
[ 1982.215132] IP: [<ffffffff805d7d61>] ipv4_rcv_saddr_equal+0x61/0x70
[ 1982.215132] PGD 1495d6067 PUD 0
[ 1982.215132] Oops: 0000 [#1] PREEMPT SMP
[ 1982.215132] last sysfs file: /sys/devices/pci0000:00/0000:00:01.0/0000:01:05.0/enable
[ 1982.215132] CPU 1
[ 1982.215132] Modules linked in: btrfs zlib_deflate zlib_inflate crc32c libcrc32c radeon drm bridge stp rfcomm llc bnep l2cap bluet]
[ 1982.338205] Pid: 21779, comm: java Not tainted 2.6.30-rc1-crc #1 System Product Name
[ 1982.338205] RIP: 0010:[<ffffffff805d7d61>]  [<ffffffff805d7d61>] ipv4_rcv_saddr_equal+0x61/0x70
[ 1982.338205] RSP: 0018:ffff880122d21d28  EFLAGS: 00010246
[ 1982.338205] RAX: 0000000000000000 RBX: 0000000000001000 RCX: 00000000000e1000
[ 1982.338205] RDX: 0000000000000000 RSI: ffff8801250da840 RDI: ffff880147cf8000
[ 1982.338205] RBP: ffff880122d21d38 R08: 0000000000000000 R09: 000000000100007f
[ 1982.338205] R10: ffff88015f4a85c8 R11: 0000000000000001 R12: ffff8801250da840
[ 1982.338205] R13: ffff8801250da8d8 R14: 0000000000000000 R15: ffff880147cf8000
[ 1982.338205] FS:  00007f2da29f6950(0000) GS:ffff880028059000(0000) knlGS:0000000000000000
[ 1982.338205] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1982.338205] CR2: 0000000000000062 CR3: 000000013f1f1000 CR4: 00000000000006e0
[ 1982.338205] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1982.338205] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1982.338205] Process java (pid: 21779, threadinfo ffff880122d20000, task ffff8801310ec4a0)
[ 1982.840593] Stack:
[ 1982.840593]  ffff880122d21d58 0000000057ae6420 ffff880122d21d98 ffffffffa033847b
[ 1982.847599]  0000000000007918 00000000805bafe5 ffff880147cf85a8 00000000ffffffff
[ 1982.847599]  0000000057ae6420 ffff8801250da858 ffff880147cf8000 ffff88015f279180
[ 1982.847599] Call Trace:
[ 1982.847599]  [<ffffffffa033847b>] ipv6_rcv_saddr_equal+0x1bb/0x250 [ipv6]
[ 1982.847599]  [<ffffffffa03505a8>] inet6_csk_bind_conflict+0x88/0xd0 [ipv6]
[ 1982.847599]  [<ffffffff805bb18e>] inet_csk_get_port+0x1ee/0x400
[ 1982.847599]  [<ffffffffa0319b7f>] inet6_bind+0x1cf/0x3a0 [ipv6]
[ 1982.847599]  [<ffffffff8056d17c>] ? sockfd_lookup_light+0x3c/0xd0
[ 1982.847599]  [<ffffffff8056ed49>] sys_bind+0x89/0x100
[ 1982.847599]  [<ffffffff80613ea2>] ? trace_hardirqs_on_thunk+0x3a/0x3c
[ 1982.847599]  [<ffffffff8020bf9b>] system_call_fastpath+0x16/0x1b
[ 1982.847599] Code: 39 c2 0f 94 c0 0f b6 d0 eb 05 ba 01 00 00 00 89 d0 48 8b 55 f8 65 48 33 14 25 28 00 00 00 75 14 c9 c3 48 8b 86
[ 1982.847599] RIP  [<ffffffff805d7d61>] ipv4_rcv_saddr_equal+0x61/0x70
[ 1982.847599]  RSP <ffff880122d21d28>
[ 1982.847599] CR2: 0000000000000062
[ 1983.173477] ---[ end trace a12cea0f8928336a ]---
[ 1983.187700] Kernel panic - not syncing: Fatal exception in interrupt
[ 1983.207275] Pid: 21779, comm: java Tainted: G      D    2.6.30-rc1-crc #1
[ 1983.228189] Call Trace:
[ 1983.235712]  [<ffffffff8060f5a1>] panic+0xc1/0x190
[ 1983.250470]  [<ffffffff8020c96d>] ? restore_args+0x0/0x30
[ 1983.267104]  [<ffffffff80252fcb>] ? oops_exit+0x3b/0x60
[ 1983.283201]  [<ffffffff80616046>] oops_end+0xb6/0xd0
[ 1983.283205]  [<ffffffff80230970>] no_context+0x110/0x290
[ 1983.283208]  [<ffffffff80230c7d>] __bad_area_nosemaphore+0x18d/0x230
[ 1983.283212]  [<ffffffff80618129>] ? sub_preempt_count+0x69/0x70
[ 1983.283216]  [<ffffffff8061468a>] ? _spin_lock_irqsave+0x3a/0x70
