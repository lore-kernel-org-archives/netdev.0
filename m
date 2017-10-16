From: Andrei Vagin <avagin@gmail.com>
Subject: Re: net-next: WARNING: CPU: 0 PID: 1544 at net/ipv4/tcp_input.c:889
Date: Mon, 16 Oct 2017 16:11:47 -0700
Message-ID: <CANaxB-z=3y+_Eihq-NGRr7YtnyBBNtRo2r4WgKVgTzcJMwTzvw@mail.gmail.com>
References: <CANaxB-ymK1yfoK2312JZQH5h2=+50YBfO9oEnE1MJ=n=S_461Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f42.google.com ([209.85.213.42]:53293 "EHLO
        mail-vk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757322AbdJPXLt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 19:11:49 -0400
Received: by mail-vk0-f42.google.com with SMTP id k195so811379vke.10
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 16:11:49 -0700 (PDT)
In-Reply-To: <CANaxB-ymK1yfoK2312JZQH5h2=+50YBfO9oEnE1MJ=n=S_461Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Could you take a look at this warning? It may be related with your
recent patches. First time we saw this warning 7 days ago
(net-next/master) and now we see it regularly.

I printed tp->fackets_out and state->reord  before the warnings and
here are values for them:
tp->fackets_out = -1 state->reord = 4

In my case, this warning is triggered for connections which have been
restored by CRIU.

Let me know if you need any other information. I can reproduce this
bugs for an hour.

Thanks,
Andrei

On Mon, Oct 9, 2017 at 11:07 AM, Andrei Vagin <avagin@gmail.com> wrote:
> Hello,
>
> We run CRIU tests on a daily basis for net-next and today they
> triggered a following warning:
>
>
> [   58.827039] ------------[ cut here ]------------
> [   58.827078] WARNING: CPU: 0 PID: 1544 at net/ipv4/tcp_input.c:889
> tcp_update_reordering+0x9f/0xb0
> [   58.827083] Modules linked in:
> [   58.827095] CPU: 0 PID: 1544 Comm: sshd Not tainted 4.14.0-rc3+ #1
> [   58.827101] Hardware name: Google Google Compute Engine/Google
> Compute Engine, BIOS Google 01/01/2011
> [   58.827106] task: ffff90f2633dcc80 task.stack: ffffb0e302800000
> [   58.827112] RIP: 0010:tcp_update_reordering+0x9f/0xb0
> [   58.827117] RSP: 0018:ffffb0e302803b28 EFLAGS: 00010282
> [   58.827126] RAX: 00000000fffffffd RBX: ffff90f29136e840 RCX: 0000000000000003
> [   58.827131] RDX: 0000000000000000 RSI: 00000000fffffffd RDI: ffff90f29136de80
> [   58.827136] RBP: ffffb0e302803b28 R08: 0000000000000044 R09: 00000000e59da6c6
> [   58.827142] R10: ffffb0e302803b68 R11: 00000000e59da70a R12: 00000000e59da6c6
> [   58.827147] R13: ffff90f29136e848 R14: ffff90f29136de80 R15: 0000000000000002
> [   58.827153] FS:  00007f52e8452840(0000) GS:ffff90f29fc00000(0000)
> knlGS:0000000000000000
> [   58.827158] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   58.827163] CR2: 000014727db10a10 CR3: 00000001d0967000 CR4: 00000000001406f0
> [   58.827172] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [   58.827177] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> [   58.827182] Call Trace:
> [   58.827191]  tcp_sacktag_write_queue+0x54d/0x860
> [   58.827206]  tcp_ack+0xa71/0x1360
> [   58.827229]  tcp_rcv_established+0x1da/0x560
> [   58.827241]  tcp_v4_do_rcv+0x139/0x1d0
> [   58.827251]  __release_sock+0x6d/0x110
> [   58.827260]  release_sock+0x30/0xb0
> [   58.827267]  tcp_sendmsg+0x37/0x50
> [   58.827276]  inet_sendmsg+0x45/0x1e0
> [   58.827287]  sock_sendmsg+0x38/0x50
> [   58.827295]  sock_write_iter+0x7e/0xd0
> [   58.827311]  __vfs_write+0xd4/0x150
> [   58.827325]  vfs_write+0xcd/0x1d0
> [   58.827332]  ? trace_hardirqs_on_caller+0x11f/0x190
> [   58.827341]  SyS_write+0x49/0xa0
> [   58.827353]  entry_SYSCALL_64_fastpath+0x23/0xc2
> [   58.827360] RIP: 0033:0x7f52e6186710
> [   58.827365] RSP: 002b:00007fffd37723b8 EFLAGS: 00000246 ORIG_RAX:
> 0000000000000001
> [   58.827375] RAX: ffffffffffffffda RBX: 000000002e3e9273 RCX: 00007f52e6186710
> [   58.827380] RDX: 0000000000000044 RSI: 0000557474a3e160 RDI: 0000000000000003
> [   58.827385] RBP: 00007f52e7237240 R08: 0000000000000006 R09: 0000000000000001
> [   58.827390] R10: 0000000000004da8 R11: 0000000000000246 R12: 000000005bb2be1e
> [   58.827396] R13: 00000000e9218d7d R14: 0000000059b77fb7 R15: 00000000505bdd2c
> [   58.827414] Code: b8 1d 00 00 00 c0 ea 04 84 d2 74 0b 89 d0 c1 e0
> 1e c1 f8 1f 83 c0 1c 48 8b 57 30 48 98 48 8b 92 00 02 00 00 65 48 ff
> 04 c2 5d c3 <0f> ff 5d c3 0f 1f 00 66 2e 0f 1f 84 00 00 00 00 00 0f 1f
> 44 00
> [   58.827724] ---[ end trace b8d78168bbc71c1f ]---
>
> Here is a fill log:
> https://travis-ci.org/avagin/linux/jobs/285457708
