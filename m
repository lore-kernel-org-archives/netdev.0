From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next-2.6] netlink: netlink_recvmsg() fix
Date: Fri, 13 Aug 2010 16:00:24 +0200
Message-ID: <1281708024.3760.12.camel@jlt3.sipsolutions.net>
References: <1279699529.3707.5.camel@jlt3.sipsolutions.net>
	 <1279700420.2452.15.camel@edumazet-laptop>
	 <1279701835.2452.17.camel@edumazet-laptop>
	 <20100725.215548.112589000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:34450 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934446Ab0HMOA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Aug 2010 10:00:26 -0400
In-Reply-To: <20100725.215548.112589000.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-07-25 at 21:55 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 21 Jul 2010 10:43:55 +0200
>=20
> > [PATCH net-next-2.6 v3] netlink: netlink_recvmsg() fix
> >=20
> > commit 1dacc76d0014=20
> > (net/compat/wext: send different messages to compat tasks)
> > introduced a race condition on netlink, in case MSG_PEEK is used.
> >=20
> > An skb given by skb_recv_datagram() might be shared, we must copy i=
t
> > before any modification, or risk fatal corruption.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Applied, thanks Eric.

I keep getting errors like below in 2.6.35+wireless-testing. Not saying
that it's this patch's fault, but it is the only thing I remember
touching that area.

[10548.768754] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[10548.773474] BUG kmalloc-4096: Object already free
[10548.775342] --------------------------------------------------------=
---------------------
[10548.775344]=20
[10548.778505] INFO: Allocated in wireless_send_event+0x1f2/0x410 age=3D=
1 cpu=3D0 pid=3D28521
[10548.778505] INFO: Freed in skb_release_data+0xd0/0xe0 age=3D2 cpu=3D=
2 pid=3D27730
[10548.778505] INFO: Slab 0xffffea0003fa4b80 objects=3D7 used=3D1 fp=3D=
0xffff880122f12090 flags=3D0x80000000000040c3
[10548.778505] INFO: Object 0xffff880122f12090 @offset=3D8336 fp=3D0xff=
ff880122f11048
[10548.778505]=20
[10548.778505] Bytes b4 0xffff880122f12080:  6c a3 0f 00 01 00 00 00 5a=
 5a 5a 5a 5a 5a 5a 5a l=EF=BF=BD......ZZZZZZZZ
=2E..
[10548.778505]   Object 0xffff880122f13080:  6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkkkk=EF=BF=BD
[10548.778505]  Redzone 0xffff880122f13090:  bb bb bb bb bb bb bb bb   =
                      =EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD       =20
[10548.778505]  Padding 0xffff880122f130d0:  5a 5a 5a 5a 5a 5a 5a 5a   =
                      ZZZZZZZZ       =20
[10548.778505] Pid: 916, comm: avahi-daemon Tainted: G        W   2.6.3=
5-wl-67184-g1595c70-dirty #12
[10548.778505] Call Trace:
[10548.778505]  [<ffffffff81133993>] print_trailer+0x103/0x160
[10548.778505]  [<ffffffff81133a31>] object_err+0x41/0x50
[10548.778505]  [<ffffffff81135b0f>] __slab_free+0x24f/0x3b0
[10548.778505]  [<ffffffff81135da2>] kfree+0x132/0x1a0
[10548.778505]  [<ffffffff81383710>] skb_release_data+0xd0/0xe0
[10548.778505]  [<ffffffff813831be>] __kfree_skb+0x1e/0xa0
[10548.778505]  [<ffffffff813832c2>] kfree_skb+0x42/0xb0
[10548.778505]  [<ffffffff813ac3f2>] netlink_recvmsg+0x422/0x480
[10548.778505]  [<ffffffff8137afdd>] sock_recvmsg+0xfd/0x130
[10548.778505]  [<ffffffff8137c1e4>] __sys_recvmsg+0x144/0x2e0
[10548.778505]  [<ffffffff8137c629>] sys_recvmsg+0x49/0x80
[10548.778505]  [<ffffffff8100b132>] system_call_fastpath+0x16/0x1b
[10548.778505] FIX kmalloc-4096: Object at 0xffff880122f12090 not freed


johannes

