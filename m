From: Dave Jones <davej@codemonkey.org.uk>
Subject: bridge deletion BUG triggered.
Date: Tue, 24 Mar 2015 21:29:14 -0400
Message-ID: <20150325012914.GA3250@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:56803 "EHLO
	arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751896AbbCYB3S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 21:29:18 -0400
Received: from arcturus.ipv6.aphlor.org ([2a03:9800:10:4a::2] helo=codemonkey.org.uk)
	by arcturus.aphlor.org with esmtpsa (TLSv1.2:AES128-GCM-SHA256:128)
	(Exim 4.80.1)
	(envelope-from <davej@codemonkey.org.uk>)
	id 1Yaa8B-0001VC-DD
	for netdev@vger.kernel.org; Wed, 25 Mar 2015 01:29:15 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm working on a dumb network ioctl fuzzer, and
seem to be able to trigger this pretty easily..


tried to remove device eth1 from br1.2
------------[ cut here ]------------
kernel BUG at net/core/dev.c:5053!
invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC 
CPU: 0 PID: 12154 Comm: brctl Not tainted 4.0.0-rc5+ #4
task: ffff8800adef4350 ti: ffff8800ad1b4000 task.ti: ffff8800ad1b4000
RIP: 0010:[<ffffffffb88923cb>]  [<ffffffffb88923cb>] __netdev_adjacent_dev_remove+0xab/0x290
RSP: 0018:ffff8800ad1b7cc8  EFLAGS: 00010202
RAX: 0000000000000026 RBX: ffff8800b3d5c0b8 RCX: 0000000000000000
RDX: ffff8800bf5cf070 RSI: ffffffffb814eda1 RDI: ffffffffb814e71f
RBP: ffff8800ad1b7cf8 R08: 0000000000000001 R09: 0000000000000001
R10: 0000000000000001 R11: 0000000000000001 R12: ffff8800ad3133e0
R13: ffff8800b3d5c000 R14: ffff8800b3d5c0e0 R15: 0000000000000000
FS:  00007fb0e1d66700(0000) GS:ffff8800bf400000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007fb0e18d0550 CR3: 00000000abd5e000 CR4: 00000000000007f0
Stack:
 ffff8800b3d5c000 ffff8800b3d5c0b0 ffff8800ad1b7cf8 ffff8800ad3133e0
 ffff8800b3d5c000 ffff8800ad2942a0 ffff8800ad1b7d18 ffffffffb88925d6
 ffff8800ad294370 ffff8800bafc0c40 ffff8800ad1b7d78 ffffffffb88927a5
Call Trace:
 [<ffffffffb88925d6>] __netdev_adjacent_dev_unlink+0x26/0x50
 [<ffffffffb88927a5>] netdev_upper_dev_unlink+0x135/0x1c0
 [<ffffffffc0d31175>] ? br_manage_promisc+0xd5/0x190 [bridge]
 [<ffffffffc0d31412>] del_nbp+0x132/0x1f0 [bridge]
 [<ffffffffc0d31525>] br_dev_delete+0x55/0xf0 [bridge]
 [<ffffffffc0d316fa>] br_del_bridge+0x7a/0xb0 [bridge]
 [<ffffffffc0d343d3>] br_ioctl_deviceless_stub+0x193/0x470 [bridge]
 [<ffffffffb8133dbe>] ? put_lock_stats.isra.18+0x1e/0x50
 [<ffffffffb8866aa1>] sock_ioctl+0x2d1/0x370
 [<ffffffffb8336d35>] do_vfs_ioctl+0x3b5/0x8f0
 [<ffffffffb815c5b4>] ? rcu_read_lock_held+0x94/0xa0
 [<ffffffffb834ae8e>] ? __fget_light+0x14e/0x190
 [<ffffffffb8337321>] SyS_ioctl+0xb1/0xf0
 [<ffffffffb8a979f2>] system_call_fastpath+0x12/0x17
Code: 48 89 35 59 7c 3a 02 4c 89 e2 4c 89 ee 48 c7 c7 f8 a5 04 b9 48 83 05 54 7c 3a 02 01 31 c0 e8 38 4a 1f 00 48 83 05 4d 7c 3a 02 01 <0f> 0b 48 83 05 4b 7c 3a 02 01 0f 1f 00 4c 89 0d 29 7c 3a 02 48 
RIP  [<ffffffffb88923cb>] __netdev_adjacent_dev_remove+0xab/0x290
 RSP <ffff8800ad1b7cc8>
---[ end trace da3f5abac9e6dfcf ]---


Another variant of the same trace showed..

tried to remove device eth1 from vlan0001

I'll try and coax it into spitting out what the
actual network configuration was before it hit these cases.

	Dave
