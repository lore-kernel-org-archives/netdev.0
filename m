From: Jeff Chua <jeff.chua.linux@gmail.com>
Subject: ping when network down BUG: unable to handle kernel NULL pointer
 dereference at 000000000000001b
Date: Tue, 29 Mar 2011 22:54:34 +0800
Message-ID: <AANLkTinthHDRYpfNrXSiOz9t_y5HyVMpjP-dLm_bn0es@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: lkml <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I don't know when this started happening as my network was always up.
Just down, I shutdown my network, and ping a known host and
encountered this BUG.

# ifconfig eth0 down
# ping knowngoodhost

Pid: 2144, comm: ping Not tainted 2.6.38 #34 LENOVO 5413FGA/5413FGA
RIP: 0010:[<ffffffff81421047>]  [<ffffffff81421047>] dst_release+0x11/0x57
RSP: 0018:ffff880231975c28  EFLAGS: 00010286
RAX: ffffffffffffff9b RBX: ffffffffffffff9b RCX: 00000000fffffffd
RDX: 0000000000000000 RSI: 00000000000000fd RDI: ffffffffffffff9b
RBP: 00000000ffffffff R08: ffff880231975bc8 R09: ffff88023bd8e1c8
R10: 0000000000000001 R11: ffff880231975a08 R12: 0000000000000040
R13: 00000000bcc8a19b R14: 00000000ffffff9b R15: 0000000000000000
FS:  00007fa75ba60700(0000) GS:ffff88023bc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000000000001b CR3: 000000022f886000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process ping (pid: 2144, threadinfo ffff880231974000, task ffff8802330e2d00)
Stack:
 ffff880231889b00 ffff880231889b00 ffff880231975ee8 ffffffff81464f97
 ffffffff0100007f 0000000000000202 ffffffff818385b0 0000000000000002
 0000000000000000 0401000000000000 bcc8a19b00000000 0000000800000000
Call Trace:
 [<ffffffff81464f97>] ? raw_sendmsg+0x66c/0x6c1
 [<ffffffff8140b0be>] ? sock_sendmsg+0xab/0xc3
 [<ffffffff8109cf03>] ? alloc_pages_vma+0x150/0x1fa
 [<ffffffff8104bde6>] ? up+0xe/0x36
 [<ffffffff81032cd8>] ? console_unlock+0x160/0x187
 [<ffffffff8104bde6>] ? up+0xe/0x36
 [<ffffffff810484b0>] ? remove_wait_queue+0x11/0x4a
 [<ffffffff8140b12d>] ? sockfd_lookup_light+0x1a/0x52
 [<ffffffff8140ab12>] ? move_addr_to_kernel+0x26/0x37
 [<ffffffff8140b7e7>] ? sys_sendto+0x114/0x148
 [<ffffffff8103d5e1>] ? do_sigaction+0x160/0x178
 [<ffffffff814b7d12>] ? system_call_fastpath+0x16/0x1b
Code: 00 48 c7 c7 70 4c 72 81 e8 41 37 c2 ff 48 c7 c7 50 4c 72 81 5b
e9 90 60 09 00 55 53 48 89 fb 48 83 ec 08 48 85 ff 74 45 83 cd ff <f0>
0f c1 af 80 00 00 00 ff cd 79 11 be 16 01 00 00 48 c7 c7 84
RIP  [<ffffffff81421047>] dst_release+0x11/0x57
 RSP <ffff880231975c28>
CR2: 000000000000001b
---[ end trace 4b75e8b1559e0b81 ]---
