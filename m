From: Roel Kluin <12o3l@tiscali.nl>
Subject: [BUG] in inet6_create
Date: Thu, 01 Nov 2007 21:07:52 +0100
Message-ID: <472A3218.20708@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out3.tiscali.nl ([195.241.79.178]:56561 "EHLO
	smtp-out3.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752603AbXKAUH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 16:07:56 -0400
Received: from [82.171.216.234] (helo=[192.168.1.2])
	by smtp-out3.tiscali.nl with esmtp (Tiscali http://www.tiscali.nl)
	id 1IngKX-0004wp-PI
	for <netdev@vger.kernel.org>; Thu, 01 Nov 2007 21:07:53 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I got this bug recently, I am not sure whether this is related to any previously 
reported ones. It was a recently pulled git kernel. Also I have been hacking my
kernel a bit lately, but I think that I haven't got any changes in the currently
running kernel.

FYI: my network card was not running (module not loaded, and I just started 
thunderbird)

Roel

More information needed?
--

NET: Registered protocol family 10
 BUG: unable to handle kernel NULL pointer dereference at virtual address 00000000
 printing eip: f881034f *pde = 00000000 
 Oops: 0000 [#1] 
 Modules linked in: ipv6
 
 Pid: 17080, comm: modprobe Not tainted (2.6.24-rc1 #1)
 EIP: 0060:[<f881034f>] EFLAGS: 00010293 CPU: 0
 EIP is at inet6_create+0x5f/0x340 [ipv6]
 EAX: 00000000 EBX: 00000000 ECX: f7621fd5 EDX: f8842e78
 ESI: ffffffff EDI: 0000003a EBP: ffffff9f ESP: d780de74
  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
 Process modprobe (pid: 17080, ti=d780c000 task=c3a86000 task.ti=d780c000)
 Stack: 00000000 00000246 00000246 00000003 c60e22a0 00000246 00000000 00000000 
        f88410fc ffffffea 00000003 c063f680 c028d597 00000002 00000001 c028d52c 
        c60e22a0 00000003 f8842d00 00000032 00000000 c028d6a7 0000003a f88438c0 
 Call Trace:
  [<c028d597>] __sock_create+0xf7/0x1e0
  [<c028d52c>] __sock_create+0x8c/0x1e0
  [<c028d6a7>] sock_create_kern+0x27/0x30
  [<f88457af>] icmpv6_init+0x1f/0xa0 [ipv6]
  [<f884513f>] inet6_init+0x13f/0x2f0 [ipv6]
  [<c0144f73>] sys_init_module+0x173/0x16c0
  [<c0132860>] autoremove_wake_function+0x0/0x50
  [<c0171ef1>] sys_read+0x41/0x70
  [<c010818e>] syscall_call+0x7/0xb
  =======================
 Code: c0 85 c9 0f 84 12 02 00 00 c7 44 24 18 00 00 00 00 0f bf c6 c1 e0 03 8b 98 80 2e 84 f8 8d 90 80 2e 84 f8 89 5c 24 1c 8b 44 24 1c <8b> 00 0f 18 00 90 39 d3 bd a2 ff ff ff 75 36 e9 f3 01 00 00 85 
 EIP: [<f881034f>] inet6_create+0x5f/0x340 [ipv6] SS:ESP 0068:d780de74
 BUG: unable to handle kernel NULL pointer dereference at virtual address 00000000
 printing eip: f881034f *pde = 00000000 
 Oops: 0000 [#2] 
 Modules linked in: ipv6
 
 Pid: 17078, comm: thunderbird-bin Tainted: G      D (2.6.24-rc1 #1)
 EIP: 0060:[<f881034f>] EFLAGS: 00210293 CPU: 0
 EIP is at inet6_create+0x5f/0x340 [ipv6]
 EAX: 00000000 EBX: 00000000 ECX: f7621fd5 EDX: f8842e78
 ESI: ffffffff EDI: 00000000 EBP: ffffff9f ESP: c2801f00
  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
 Process thunderbird-bin (pid: 17078, ti=c2800000 task=c20bf000 task.ti=c2800000)
 Stack: c0185024 00200246 00200246 00000001 c60e2000 00200246 00000000 00000000 
        f88410fc ffffffea 00000001 c063f680 c028d597 00000002 00000001 c028d52c 
        c60e2000 00000001 0000000a 08b095bc c2800000 c028d6e9 00000000 c2801f74 
 Call Trace:
  [<c0185024>] new_inode+0x24/0x90
  [<c028d597>] __sock_create+0xf7/0x1e0
  [<c028d52c>] __sock_create+0x8c/0x1e0
  [<c028d6e9>] sock_create+0x39/0x50
  [<c028d89c>] sys_socket+0x1c/0x50
  [<c028e248>] sys_socketcall+0x68/0x280
  [<c013da9b>] trace_hardirqs_on+0xbb/0x160
  [<c011b80d>] do_sched_setscheduler+0xad/0xc0
  [<c01081fb>] restore_nocheck+0x12/0x15
  [<c010818e>] syscall_call+0x7/0xb
  =======================
 Code: c0 85 c9 0f 84 12 02 00 00 c7 44 24 18 00 00 00 00 0f bf c6 c1 e0 03 8b 98 80 2e 84 f8 8d 90 80 2e 84 f8 89 5c 24 1c 8b 44 24 1c <8b> 00 0f 18 00 90 39 d3 bd a2 ff ff ff 75 36 e9 f3 01 00 00 85 
 EIP: [<f881034f>] inet6_create+0x5f/0x340 [ipv6] SS:ESP 0068:c2801f00
