From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: oops with ipcomp
Date: Fri, 1 Feb 2008 11:09:22 +0100
Message-ID: <3C59DB883F7B0B4D8096010D45ACCD134F209E@exch.facton.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.facton.com ([83.236.152.122]:34176 "EHLO alpha.facton.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754399AbYBAKJa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 05:09:30 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One more issue with 2.6.24, some hours after I reactivated ipcomp with
Herb's 2 patches.
The httpd log shows a http request per esp tunnel at oops time.
Don't know whether it is for network or compression guys, so I started
posting here.
Daniel

Unable to handle kernel paging request at ffffc200000fb000 RIP: 
 [<ffffffff8031b8f0>] deflate_slow+0x40/0x400
PGD 7f845067 PUD 7f846067 PMD 7f847067 PTE 0
Oops: 0000 [1] SMP 
CPU 0 
Modules linked in:
Pid: 9136, comm: httpd Not tainted 2.6.24 #2
RIP: 0010:[<ffffffff8031b8f0>]  [<ffffffff8031b8f0>]
deflate_slow+0x40/0x400
RSP: 0018:ffff81002ad35938  EFLAGS: 00010206
RAX: 0000000000000000 RBX: ffffc200000b9000 RCX: 00000000000408d8
RDX: ffffc200000ba728 RSI: 0000000000000000 RDI: 0000000000005f65
RBP: 00000000000008d4 R08: 0000000000003dae R09: 0000000000001800
R10: 0000000000000010 R11: ffffc200000b94bc R12: 00000000000001ad
R13: 0000000000000005 R14: 0000000000000000 R15: ffffc20000097000
FS:  00002b00bb68b190(0000) GS:ffffffff805a8000(0000)
knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffffc200000fb000 CR3: 000000002ac82000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process httpd (pid: 9136, threadinfo ffff81002ad34000, task
ffff81007d2d4080)
Stack:  ffff810042f3f710 ffff81007dfb0700 0000000000000005
ffffc200000b9000
 ffff81007de89000 ffffffff8031c25d 0000000000000000 ffff81007dfb0700
 ffff81007dfb06c0 ffff81007de890a8 000000000000010a ffffffff802ff351
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
 RSP <ffff81002ad35938>
CR2: ffffc200000fb000
---[ end trace cfeb10aa23b54939 ]---
