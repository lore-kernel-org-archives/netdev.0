From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net 0/2] ipv6: Initialize rt6_info properly in ip6_blackhole_route()
Date: Thu, 15 Oct 2015 16:39:56 -0700
Message-ID: <1444952398-1505791-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:50110 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751560AbbJOXka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 19:40:30 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id t9FNalos006994
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 16:40:30 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1xh6fqp224-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 16:40:30 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 1dd351cc739611e5bbec0002c99293a0-301f9230 for <netdev@vger.kernel.org>;	Thu,
 15 Oct 2015 16:40:28 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset ensures the rt6_info's fields are initialized properly
in ip6_blackhole_route() where xfrm_policy is the primarily user.
The first patch is a prep work.  The second patch is the fix.  It
fixes d52d3997f843 ("ipv6: Create percpu rt6_info").

Here is the oops reported by Phil Sutter <phil@nwl.cc>:

BUG: unable to handle kernel NULL pointer dereference at 00000000000000a0
IP: [<ffffffff8171a95e>] __ip6_datagram_connect+0x71e/0xa20
PGD c2cb1067 PUD c2d7a067 PMD 0
Oops: 0000 [#1] PREEMPT SMP
Modules linked in: cmac nfs lockd grace sunrpc bridge stp llc nvidia(PO) snd_usb_audio snd_usbmidi_lib iTCO_wdt
CPU: 1 PID: 2964 Comm: ping6 Tainted: P           O    4.2.1-aufs #10
Hardware name: To Be Filled By O.E.M. To Be Filled By O.E.M./4Core1333-Viiv, BIOS P1.60 07/01/2008
task: ffff8800ca62bc00 ti: ffff880129a14000 task.ti: ffff880129a14000
RIP: 0010:[<ffffffff8171a95e>]  [<ffffffff8171a95e>] __ip6_datagram_connect+0x71e/0xa20
RSP: 0018:ffff880129a17da8  EFLAGS: 00010296
RAX: 000000000000000b RBX: 0000000000000000 RCX: 0000000000000006
RDX: 0000000000000007 RSI: 0000000000000246 RDI: ffff88012fc8d5a0
RBP: ffff8800cb9a9048 R08: 756e207369207472 R09: 216c6c756e207369
R10: 0000000000000665 R11: 0000000000000006 R12: ffff8800cb9a8cf8
R13: ffff8800cb9a8cf8 R14: 0000000000000000 R15: ffff8800cb9a8cc0
FS:  00007fb76ad74700(0000) GS:ffff88012fc80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000000000a0 CR3: 00000000c2dba000 CR4: 00000000000406e0
Stack:
 ffff8800cb9a9048 ffff8800cb9a8de0 ffff8800cb9feb70 ffffffff816b2c41
 00007fb70000000b ffffea0000df7200 ffff8800cb9f5cfc ffff8800cb9a8cc0
 03fffffffe068a20 ffff8800cb9a8cc0 ffffffff817097c0 0000000100000000
Call Trace:
 [<ffffffff816b2c41>] ? udp_lib_get_port+0x1a1/0x380
 [<ffffffff817097c0>] ? udpv6_rcv+0x20/0x20
 [<ffffffff8171ac82>] ? ip6_datagram_connect+0x22/0x40
 [<ffffffff8163ae9b>] ? SyS_connect+0x6b/0xb0
 [<ffffffff810767ac>] ? __do_page_fault+0x15c/0x380
 [<ffffffff8163a8d3>] ? SyS_socket+0x63/0xa0
 [<ffffffff81741957>] ? entry_SYSCALL_64_fastpath+0x12/0x6a
Code: ba ae 00 00 00 48 c7 c6 7b 71 94 81 48 c7 c7 63 71 94 81 e8 6c 0f 02 00 48 85 db 75 0e 48 c7 c7 9f 71 94 81 31 c0 e8 59 0f 02 00 <48> 83 bb a0 00 00 00 00 75 0e 48 c7 c7 ae 71 94 81 31 c0 e8 41
RIP  [<ffffffff8171a95e>] __ip6_datagram_connect+0x71e/0xa20
 RSP <ffff880129a17da8>
CR2: 00000000000000a0
