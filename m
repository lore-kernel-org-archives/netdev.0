From: Luca Tettamanti <kronos.it@gmail.com>
Subject: [2.6.33-rc5] kernel BUG at include/net/netns/generic.h:41!
Date: Fri, 29 Jan 2010 10:48:22 +0100
Message-ID: <20100129094822.GA8294@nb-core2.darkstar.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:57639 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754275Ab0A2Js2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 04:48:28 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
with recent kernels I'm seeing this BUG - triggered by racoon - at boot:

NET: Registered protocol family 15
------------[ cut here ]------------
kernel BUG at /home/kronos/src/linux-2.6.git/include/net/netns/generic.h:43!
invalid opcode: 0000 [#1] PREEMPT SMP 
last sysfs file: /sys/kernel/uevent_seqnum
CPU 1 
Pid: 1941, comm: racoon Not tainted 2.6.33-rc5-00271-gbe8cde8-dirty #238 F3Sa      /F3Sa                
RIP: 0010:[<ffffffffa03035be>]  [<ffffffffa03035be>] pfkey_create+0x36/0x18b [af_key]
RSP: 0018:ffff88013ddebe98  EFLAGS: 00010246
RAX: ffff88013f894480 RBX: ffff88013f44de40 RCX: 0000000000000000
RDX: 0000000000000002 RSI: ffff88013f44de40 RDI: 0000000000000001
RBP: ffff88013ddebeb8 R08: ffff88013ddea000 R09: dead000000200200
R10: dead000000100100 R11: ffff88013ddebd80 R12: 0000000000000000
R13: ffffffff81771860 R14: 0000000000000002 R15: 0000000000000000
FS:  00007f02c3e1f710(0000) GS:ffff880028300000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000794f38 CR3: 000000013d98d000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process racoon (pid: 1941, threadinfo ffff88013ddea000, task ffff88013dffd880)
Stack:
 000000000000000f ffff88013f44de40 0000000000000003 ffffffffa0304a80
<0> ffff88013ddebf28 ffffffff81220802 ffff88013ddebee8 00007f02c3a22e80
<0> ffffffff00000001 ffff88013ddebf60 ffffffff81771860 0000000200000001
Call Trace:
 [<ffffffff81220802>] __sock_create+0x242/0x3dd
 [<ffffffff812209e9>] sock_create+0x2b/0x2d
 [<ffffffff81220b91>] sys_socket+0x26/0x57
 [<ffffffff8129fe0f>] ? page_fault+0x1f/0x30
 [<ffffffff81002a2b>] system_call_fastpath+0x16/0x1b
Code: 49 89 fd 41 54 bf 01 00 00 00 53 44 8b 25 27 19 00 00 48 89 f3 e8 4f f1 f9 e0 49 8b 85 48 08 00 00 45 85 e4 74 05 44 3b 20 76 04 <0f> 0b eb fe 4d 63 e4 4e 8b 64 e0 10 bf 01 00 00 00 e8 aa f0 f9 
RIP  [<ffffffffa03035be>] pfkey_create+0x36/0x18b [af_key]
 RSP <ffff88013ddebe98>
---[ end trace 78cabe73779ec9df ]---
note: racoon[1941] exited with preempt_count 1

It looks like a bug I reported a while ago[1] and which was fixed by Eric. The
fix is still in place, but the bug has resurfaced recently, probably in .33.
It's quiet elusive, i.e. it happens maybe once every 5 boots; restarting racoon
doesn't seem to trigger it...

Luca
[1] http://bugzilla.kernel.org/show_bug.cgi?id=13838
