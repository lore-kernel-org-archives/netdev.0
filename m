From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel crash in 2.6.39-rc2-wl
Date: Wed, 06 Apr 2011 22:54:32 +0200
Message-ID: <1302123272.2701.34.camel@edumazet-laptop>
References: <4D9CCD72.7020308@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38985 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754523Ab1DFUyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 16:54:37 -0400
Received: by wya21 with SMTP id 21so1668909wya.19
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2011 13:54:36 -0700 (PDT)
In-Reply-To: <4D9CCD72.7020308@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 06 avril 2011 =C3=A0 13:30 -0700, Ben Greear a =C3=A9crit :
> This is from today's wireless-testing kernel, with a few non-tainting
> patches related to wireless stuff.  In general, 39-rc2 seems pretty
> flaky, but on this boot, this is the first kernel splat.
>=20
> I had reloaded our user-space network-config DB, which would have del=
eted
> and created some VETH and MAC-VLAN interfaces, and a bunch of
> protocol sockets, virtual-routers (xorp with unique routing tables) e=
tc.
>=20
>=20
> BUG: unable to handle kernel paging request at 50435453
> IP: [<c04d8ac6>] __kmalloc_track_caller+0xd8/0x117
> *pde =3D 00000000
> Oops: 0000 [#1] SMP
> last sysfs file: /sys/devices/pci0000:00/0000:00:1f.2/host0/target0:0=
:1/0:0:1:0/block/sda/sda1/stat
> Modules linked in: xt_CT iptable_raw xt_DSCP xt_dscp xt_string xt_own=
er xt_NFQUEUE xt_multiport xt_mark xt_iprange xt_hashlimit xt_connmark =
xt_addrty]
>=20
> Pid: 12747, comm: xorp_rtrmgr Not tainted 2.6.39-rc2-wl+ #56 To Be Fi=
lled By O.E.M. To Be Filled By O.E.M./To be filled by O.E.M.
> EIP: 0060:[<c04d8ac6>] EFLAGS: 00210206 CPU: 0
> EIP is at __kmalloc_track_caller+0xd8/0x117
> EAX: c0b18ee0 EBX: f5402500 ECX: 0001d3c9 EDX: 00000000
> ESI: 50435453 EDI: 0001d3c8 EBP: f17ddd00 ESP: f17ddce8
>   DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> Process xorp_rtrmgr (pid: 12747, ti=3Df17dc000 task=3Df147bde0 task.t=
i=3Df17dc000)
> Stack:
>   c07869c6 000000d0 000001fc f1284fc0 000000d0 f5487f80 f17ddd1c c074=
68b9
>   00000001 00000140 f15e0000 f15e0000 00000000 f17ddd34 c07869c6 ffff=
ffff
>   f15e0000 00010000 f17ddd88 f17ddd98 c0787005 00004040 00000000 0000=
0002
> Call Trace:
>   [<c07869c6>] ? sk_stream_alloc_skb+0x2c/0xc4
>   [<c07468b9>] __alloc_skb+0x5d/0xf9
>   [<c07869c6>] sk_stream_alloc_skb+0x2c/0xc4
>   [<c0787005>] tcp_sendmsg+0x16d/0x714
>   [<c07a1776>] inet_sendmsg+0x55/0x5e
>   [<c073ef79>] __sock_sendmsg+0x56/0x5f
>   [<c073f608>] sock_sendmsg+0x98/0xac
>   [<c0461879>] ? mark_lock+0x1e/0x1de
>   [<c042b66d>] ? pick_next_highest_task_rt+0x148/0x148
>   [<c04e643e>] ? fget_light+0x30/0xa4
>   [<c073f686>] ? sockfd_lookup_light+0x1b/0x4b
>   [<c073fc0f>] sys_sendto+0xaf/0xcb
>   [<c045500b>] ? __run_hrtimer+0xbc/0x106
>   [<c04633b5>] ? lock_release_non_nested+0x86/0x1d8
>   [<c04c10a1>] ? might_fault+0x4c/0x86
>   [<c073fc48>] sys_send+0x1d/0x1f
>   [<c0740bb7>] sys_socketcall+0xe6/0x1aa
>   [<c07fa19c>] sysenter_do_call+0x12/0x38
>   [<c07f0000>] ? timer_cpu_notify+0x47/0x222
> Code: d2 75 13 8b 4d e8 8b 55 ec 50 89 d8 e8 e9 f6 ff ff 5f 89 c6 eb =
21 8b 03 64 8b 30 39 d6 75 d2 64 8b 48 04 39 f9 75 ca 8b 53 14 41 <8b> =
14 16 64
> EIP: [<c04d8ac6>] __kmalloc_track_caller+0xd8/0x117 SS:ESP 0068:f17dd=
ce8


> CR2: 0000000050435453


Thats "STCP" in ASCII




