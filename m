From: Brenden Blanco <bblanco@plumgrid.com>
Subject: BUG: null dereference in __skb_recv_datagram
Date: Mon, 3 Aug 2015 18:57:44 -0700
Message-ID: <CAMUH3-VQaWdxnGUuJamGXQZN+Pq-4YBFcr6Yq3R6qD0=8cjG_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:36058 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753235AbbHDB6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 21:58:04 -0400
Received: by ykeo23 with SMTP id o23so29417129yke.3
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 18:58:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Folks,

I just hit this one off of latest net-next tree, git hash
58da018053531b9cb91423a64f2a762ef0fe7456

I was running a set of tests from pyroute2 project:
https://github.com/svinota/pyroute2

A simple `sudo make test skip_tests=test_stress` in there hits the
issue every time.

[  318.244596] BUG: unable to handle kernel NULL pointer dereference
at 000000000000008e
[  318.245182] IP: [<ffffffff81455e7c>] __skb_recv_datagram+0xbc/0x5a0
[  318.245762] PGD 80999d067 PUD 7fc04a067 PMD 0
[  318.246336] Oops: 0000 [#1]
[  318.262158] CPU: 3 PID: 1580 Comm: dnsmasq Not tainted 4.2.0-rc4-g58da018 #28
[  318.263143] Hardware name: MSI MS-7930/Z97S SLI PLUS (MS-7930),
BIOS V1.2 05/22/2014
[  318.264137] task: ffff880806c96200 ti: ffff8807fc090000 task.ti:
ffff8807fc090000
[  318.265136] RIP: 0010:[<ffffffff81455e7c>] [<ffffffff81455e7c>]
__skb_recv_datagram+0xbc/0x5a0
[  318.266153] RSP: 0018:ffff8807fc093b98  EFLAGS: 00010082
[  318.267158] RAX: 0000000000000296 RBX: 0000000000000000 RCX: ffff8807fc093c7c
[  318.268172] RDX: 0000000000000001 RSI: 0000000000000000 RDI: ffff88080a4b88ac
[  318.269186] RBP: ffff8807fc093c68 R08: ffff8807fc093cb0 R09: 000000007ffff000
[  318.270200] R10: ffff8807fc094000 R11: 0000000000000246 R12: ffff8807fc093c78
[  318.271217] R13: ffff88080a4b8800 R14: ffff88080a4b8898 R15: 0000000000000000
[  318.272236] FS:  00007f52a582f700(0000) GS:ffff88082ecc0000(0000)
knlGS:0000000000000000
[  318.273264] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  318.274286] CR2: 000000000000008e CR3: 0000000808240000 CR4: 00000000001406e0
[  318.275314] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  318.276323] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[  318.277311] Stack:
[  318.278282]  dead000000200200 ffff8808061e4300 ffff88080a4d9100
00000000000000db
[  318.279291]  ffff880800000000 ffff8807fc093a78 ffff880806c96200
ffff8807fc094000
[  318.280287]  ffff8807fc093c20 ffff8807fc093cb0 0000000000000000
ffff8807fc093c7c
[  318.281260] Call Trace:
[  318.282202]  [<ffffffff811e5af0>] ? poll_select_copy_remaining+0x140/0x140
[  318.283150]  [<ffffffff8145639f>] skb_recv_datagram+0x3f/0x60
[  318.284077]  [<ffffffff81492e49>] netlink_recvmsg+0x59/0x360
[  318.284984]  [<ffffffff81445543>] sock_recvmsg+0x13/0x20
[  318.285867]  [<ffffffff81448053>] ___sys_recvmsg+0xe3/0x210
[  318.286729]  [<ffffffff81212af6>] ? fsnotify+0x316/0x4a0
[  318.287569]  [<ffffffff81449367>] __sys_recvmsg+0x57/0xa0
[  318.288389]  [<ffffffff814493c2>] SyS_recvmsg+0x12/0x20
[  318.289186]  [<ffffffff81564aee>] entry_SYSCALL_64_fastpath+0x12/0x71
