From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: oops with ipcomp
Date: Mon, 4 Feb 2008 11:39:12 +0100
Message-ID: <3C59DB883F7B0B4D8096010D45ACCD134F20A7@exch.facton.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.facton.com ([83.236.152.122]:40293 "EHLO alpha.facton.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751263AbYBDKjT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 05:39:19 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nope! Right now it happened again, something must have changed with
2.6.24.

Unable to handle kernel paging request at ffffc200000fb000 RIP:
 [<ffffffff8031b8f0>] deflate_slow+0x40/0x400
PGD 7f845067 PUD 7f846067 PMD 7f847067 PTE 0
Oops: 0000 [1] SMP
CPU 0
Modules linked in:
Pid: 11055, comm: httpd Not tainted 2.6.24 #2
RIP: 0010:[<ffffffff8031b8f0>]  [<ffffffff8031b8f0>]
deflate_slow+0x40/0x400
RSP: 0018:ffff810039525938  EFLAGS: 00010206
RAX: 0000000000000000 RBX: ffffc200000b9000 RCX: 00000000000408d8
RDX: ffffc200000ba728 RSI: 0000000000000000 RDI: 0000000000006aa3
RBP: 00000000000008d4 R08: 0000000000003c8b R09: 0000000000001800
R10: 0000000000000010 R11: ffffc200000b94bc R12: 000000000000007d
R13: 0000000000000005 R14: 0000000000000000 R15: ffffc20000097000
FS:  00002b16cc187190(0000) GS:ffffffff805a8000(0000)
knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffffc200000fb000 CR3: 000000007c69a000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process httpd (pid: 11055, threadinfo ffff810039524000, task
ffff81007f8e6140)
Stack:  ffff81007c4aae10 ffff81007ead4400 0000000000000005
ffffc200000b9000
 ffff81006c186000 ffffffff8031c25d 0000000000000000 ffff81007ead4400
 ffff81007ead43c0 ffff81006c1860a8 0000000000000109 ffffffff802ff351
Call Trace:
 [<ffffffff8031c25d>] zlib_deflate+0x10d/0x330
 [<ffffffff802ff351>] deflate_compress+0x91/0xb0
 [<ffffffff804771b8>] ipcomp_output+0x98/0x1e0
 [<ffffffff80489ef6>] xfrm_output+0x116/0x1e0
 [<ffffffff80482dc4>] xfrm4_output_finish2+0x44/0x1e0
 [<ffffffff80483075>] xfrm4_output+0x55/0x60
 [<ffffffff80445989>] ip_queue_xmit+0x209/0x450
 [<ffffffff8049b0d0>] thread_return+0x3d/0x54d
 [<ffffffff8023b094>] lock_timer_base+0x34/0x70
 [<ffffffff80456dcf>] tcp_transmit_skb+0x40f/0x7c0
 [<ffffffff80458aae>] __tcp_push_pending_frames+0x11e/0x940
 [<ffffffff8044cb8e>] tcp_sendmsg+0x81e/0xc40
 [<ffffffff80291e3f>] dput+0x1f/0x130
 [<ffffffff80410b01>] sock_aio_write+0x111/0x120
 [<ffffffff804109f0>] sock_aio_write+0x0/0x120
 [<ffffffff8027f95b>] do_sync_readv_writev+0xcb/0x110
 [<ffffffff80246850>] autoremove_wake_function+0x0/0x30
 [<ffffffff8027fb99>] do_sync_read+0xd9/0x120
 [<ffffffff80287941>] permission+0x61/0x100
 [<ffffffff8027f7bd>] rw_copy_check_uvector+0x9d/0x130
 [<ffffffff802800a2>] do_readv_writev+0xe2/0x210
 [<ffffffff8027e1ba>] do_filp_open+0x3a/0x50
 [<ffffffff802806e3>] sys_writev+0x53/0x90
 [<ffffffff8020bb3e>] system_call+0x7e/0x83


Code: 0f b6 14 0a 31 d0 23 43 74 48 8b 53 60 89 43 68 89 c0 0f b7
RIP  [<ffffffff8031b8f0>] deflate_slow+0x40/0x400
 RSP <ffff810039525938>
CR2: ffffc200000fb000
---[ end trace 0ff90cd2723f4b1e ]---
