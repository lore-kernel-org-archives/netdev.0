From: =?UTF-8?B?SsOhbiBTdGFuxI1law==?= <jan.stancek@gmail.com>
Subject: Re: NULL pointer deref, selinux_socket_unix_may_send+0x34/0x90
Date: Fri, 22 Mar 2013 17:52:37 +0100
Message-ID: <CAMpz-8aJyEgesAYLgB3EPSCevDG5KcH+9S-sJUfBOnA0m_Ky1g@mail.gmail.com>
References: <CAMpz-8YY1ZFJnx5JAuGu3GBYhkbnYggEAqmVMQoHg7eqKNtyeg@mail.gmail.com>
	<2355680.noQDWa4NlY@sifl>
	<CAMpz-8bzjyBzk+mkaR-hHndtRZVyTb0LX8idEvypRV-itdSRYw@mail.gmail.com>
	<3405435.XFBqjMtCVW@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, eparis@redhat.com, sds@tycho.nsa.gov
To: Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:39055 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1160998Ab3CVQwi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 12:52:38 -0400
Received: by mail-ob0-f173.google.com with SMTP id dn14so4252238obc.18
        for <netdev@vger.kernel.org>; Fri, 22 Mar 2013 09:52:38 -0700 (PDT)
In-Reply-To: <3405435.XFBqjMtCVW@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul,

I applied your patch on top of 3.9-rc3 and ran v2 of reproducer. It
hit the issue
almost instantly:

[  249.316283] BUG: unable to handle kernel NULL pointer dereference
at 0000000000000250
[  249.325044] IP: [<ffffffff812a2d04>] selinux_socket_unix_may_send+0x=
34/0x90
[  249.332829] PGD 80a8e5067 PUD 803048067 PMD 0
[  249.337821] Oops: 0000 [#1] SMP
[  249.453113] CPU 22
[  249.455262] Pid: 6928, comm: a.out Tainted: GF
3.9.0-rc3+ #1 Intel Corporation W2600CR/W2600CR
[  249.466132] RIP: 0010:[<ffffffff812a2d04>]  [<ffffffff812a2d04>]
selinux_socket_unix_may_send+0x34/0x90
[  249.476632] RSP: 0018:ffff880826569ab8  EFLAGS: 00010246
[  249.482551] RAX: ffff880417ee4100 RBX: ffff880826569be8 RCX: 0000000=
000000007
[  249.490511] RDX: 0000000000000000 RSI: ffff880828f77d00 RDI: ffff880=
826569ad8
[  249.498472] RBP: ffff880826569b18 R08: ffff880424ada080 R09: 0000000=
000000000
[  249.506434] R10: ffff880826569a38 R11: 000000000000000f R12: ffff880=
417ee4100
[  249.514395] R13: 7fffffffffffffff R14: ffff880424ada080 R15: ffff880=
424ada370
[  249.522355] FS:  00007f6d44abf740(0000) GS:ffff88042f7c0000(0000)
knlGS:0000000000000000
[  249.531383] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  249.537792] CR2: 0000000000000250 CR3: 0000000800ffa000 CR4: 0000000=
0000407e0
[  249.545755] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000=
000000000
[  249.553716] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000=
000000400
[  249.561678] Process a.out (pid: 6928, threadinfo ffff880826568000,
task ffff880825d999a0)
[  249.570802] Stack:
[  249.573046]  ffff880424ada002 ffff880427c5bc00 ffff880417ee4100
ffff880424ada080
[  249.581339]  ffff880424ada080 000000000000000a ffff880826569af8
ffffffff8129ef36
[  249.589637]  ffff880826569b28 ffffffff81529747 ffff880826569be8
0000000011f46a34
[  249.597933] Call Trace:
[  249.600666]  [<ffffffff8129ef36>] ? security_sock_rcv_skb+0x16/0x20
[  249.607661]  [<ffffffff81529747>] ? sk_filter+0x37/0xd0
[  249.613491]  [<ffffffff8129ef16>] security_unix_may_send+0x16/0x20
[  249.620390]  [<ffffffff815b697d>] unix_dgram_sendmsg+0x48d/0x640
[  249.627094]  [<ffffffff814fd9c0>] sock_sendmsg+0xb0/0xe0
[  249.633024]  [<ffffffff812adee7>] ? ebitmap_cpy+0x47/0xd0
[  249.639048]  [<ffffffff814ff55c>] __sys_sendmsg+0x3ac/0x3c0
[  249.645267]  [<ffffffff811a3357>] ? do_sync_write+0xa7/0xe0
[  249.651487]  [<ffffffff811e31fb>] ? fsnotify+0x24b/0x340
[  249.657416]  [<ffffffff815013c9>] sys_sendmsg+0x49/0x90
[  249.663249]  [<ffffffff81630bd9>] system_call_fastpath+0x16/0x1b
[  249.669949] Code: 00 00 45 31 c9 48 89 e5 48 83 ec 60 48 8b 56 20
65 48 8b 04 25 28 00 00 00 48 89 45 f8 31 c0 48 8b 47 20 48 8d 7d c0
c6 45 a0 02 <48> 8b b2 50 02 00 00 4c 8b 80 50 02 00 00 31 c0 f3 48 ab
48 89

Regards,
Jan

On Fri, Mar 22, 2013 at 5:24 PM, Paul Moore <paul@paul-moore.com> wrote=
:
> On Friday, March 22, 2013 04:48:32 PM J=C3=A1n Stan=C4=8Dek wrote:
>> Hi Paul,
>>
>> thanks for reply, I'll try your patch and let you know.
>
> Great, thanks.
>
>> I'm not certain about cause either, but patch I sent in last email
>> makes it go away, so maybe that can help in some way.
>
> At the very least you've found a way to reproduce the problem and you=
r patch
> furthers my belief that we've got a race condition somewhere - all ve=
ry
> helpful!  It may also turn out that your patch is the "right" solutio=
n, I'd
> just like to better understand why we are seeing the race in the firs=
t place.
>
>> I made a v2 of the reproducer (attached), which triggers the issue a=
 lot
>> faster on 2 systems I tried (32 CPU and 4 CPU systems) - just in cou=
ple of
>> seconds.
>
> Excellent, while I don't have a 32 cpu system handy, I do have a 4 cp=
u system
> that I can play with.  Thanks again.
>
> -Paul
>
> --
> paul moore
> www.paul-moore.com
>
