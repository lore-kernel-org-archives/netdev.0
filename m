From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Subject: [2.6.24-mm1] TCP/IPv6 connect() oopses at twothirdsMD4Transform()
Date: Tue, 05 Feb 2008 10:28:43 +0900
Message-ID: <200802050128.m151ShPX088549@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:56662 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757613AbYBEB2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 20:28:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Kernel config is at http://I-love.SAKURA.ne.jp/tmp/config-2.6.24-mm1

2.6.24 works fine.

Regards.
----------
BUG: unable to handle kernel paging request at 25476bec
IP: [<c0211c28>] twothirdsMD4Transform+0x78/0x37c
*pde = 00000000 
Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
last sysfs file: /sys/devices/pci0000:00/0000:00:10.0/host0/target0:0:1/0:0:1:0/type
Modules linked in: nfsd lockd sunrpc exportfs pcnet32

Pid: 2148, comm: a.out Not tainted (2.6.24-mm1 #1)
EIP: 0060:[<c0211c28>] EFLAGS: 00010286 CPU: 0
EIP is at twothirdsMD4Transform+0x78/0x37c
EAX: 00084000 EBX: 08000000 ECX: 80000000 EDX: db45ddec
ESI: 00000000 EDI: 52806380 EBP: db45dddc ESP: db45ddc8
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process a.out (pid: 2148, ti=db45d000 task=deaf9250 task.ti=db45d000)
Stack: 80000000 def6ef9c 00006380 c0759d60 db45de1c db45de28 c0211fd2 00000040 
       c0759d40 00000000 00000000 00000000 01000000 52806380 1f2e00ba fffa249f 
       5a696b37 8dbe1970 cf7579d0 3b0cc350 a54b10a8 def6e9a0 00000000 def6ef8c 
Call Trace:
 [<c0211fd2>] ? secure_tcpv6_sequence_number+0x58/0x7a
 [<c0322247>] ? tcp_v6_connect+0x46d/0x4e3
 [<c02ade07>] ? lock_sock_nested+0x56/0x5e
 [<c02ecbae>] ? inet_stream_connect+0x1c/0x163
 [<c02ecc24>] ? inet_stream_connect+0x92/0x163
 [<c02ab14b>] ? sys_connect+0x72/0x98
 [<c013b945>] ? lock_release_holdtime+0x4e/0x54
 [<c0115250>] ? do_page_fault+0x1c5/0x3fc
 [<c013e858>] ? __lock_release+0x4b/0x51
 [<c0115250>] ? do_page_fault+0x1c5/0x3fc
 [<c02ab9f5>] ? sys_socketcall+0x6f/0x15e
 [<c0103ae7>] ? restore_nocheck+0x12/0x15
 [<c0103a86>] ? syscall_call+0x7/0xb
 =======================
Code: 31 c1 03 0c ba 8b 7a 0c 01 ce 8b 4d ec c1 c6 0b 31 d9 21 f1 31 d9 03 0c ba 8b 7a 10 01 c8 8b 4d ec c1 c0 13 31 f1 21 c1 33 4d ec <03> 0c ba 8b 7a 14 01 cb 89 c1 c1 c3 03 31 f1 21 d9 31 f1 03 0c 
EIP: [<c0211c28>] twothirdsMD4Transform+0x78/0x37c SS:ESP 0068:db45ddc8
---[ end trace 160518059a282c77 ]---
