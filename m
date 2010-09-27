From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net-next rcu_dereference_check() warning
Date: Mon, 27 Sep 2010 18:45:12 +0200
Message-ID: <1285605912.3017.111.camel@edumazet-laptop>
References: <4CA0C691.1090001@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:54603 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759898Ab0I0QpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 12:45:19 -0400
Received: by eyb6 with SMTP id 6so1455535eyb.19
        for <netdev@vger.kernel.org>; Mon, 27 Sep 2010 09:45:18 -0700 (PDT)
In-Reply-To: <4CA0C691.1090001@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 27 septembre 2010 =C3=A0 09:30 -0700, Dimitris Michailidis a =C3=
=A9crit :
> With today's net-next I am getting the below.  It appears to be recen=
t, it=20
> wasn't happening with the net-next I was using last week.
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
> [ INFO: suspicious rcu_dereference_check() usage. ]
> ---------------------------------------------------
> /build/net-next-2.6/include/linux/netpoll.h:67 invoked=20
> rcu_dereference_check() without protection!
>=20
> other info that might help us debug this:
>=20
>=20
> rcu_scheduler_active =3D 1, debug_locks =3D 0
> 1 lock held by ypbind/5046:
>   #0:  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff81503139>]=20
> udp_sendmsg+0x3fd/0x5dc
>=20
> stack backtrace:
> Pid: 5046, comm: ypbind Not tainted 2.6.36-rc3+ #16
> Call Trace:
>   [<ffffffff810668e4>] lockdep_rcu_dereference+0xaa/0xb3
>   [<ffffffff814b8d09>] netif_rx+0x53/0x1cf
>   [<ffffffff810313b7>] ? get_parent_ip+0x11/0x41
>   [<ffffffff814b9068>] netif_rx_ni+0x23/0x5d
>   [<ffffffff814e57a9>] ip_dev_loopback_xmit+0xc5/0xcb
>   [<ffffffff814e593c>] ip_mc_output+0x18d/0x1a5
>   [<ffffffff814e30ec>] ip_local_out+0x62/0x66
>   [<ffffffff814e33cb>] ip_push_pending_frames+0x2db/0x337
>   [<ffffffff81501b55>] udp_push_pending_frames+0x2de/0x34c
>   [<ffffffff81503139>] ? udp_sendmsg+0x3fd/0x5dc
>   [<ffffffff8150322a>] udp_sendmsg+0x4ee/0x5dc
>   [<ffffffff8150aa74>] inet_sendmsg+0x13a/0x145
>   [<ffffffff8150a93a>] ? inet_sendmsg+0x0/0x145
>   [<ffffffff814a6d24>] sock_sendmsg+0xc0/0xd9
>   [<ffffffff8106aad4>] ? lock_release_non_nested+0xe5/0x296
>   [<ffffffff810c8fb0>] ? might_fault+0x68/0xb8
>   [<ffffffff810c8fb0>] ? might_fault+0x68/0xb8
>   [<ffffffff810c8ff9>] ? might_fault+0xb1/0xb8
>   [<ffffffff810c8fb0>] ? might_fault+0x68/0xb8
>   [<ffffffff814a6672>] ? move_addr_to_kernel+0x3f/0x56
>   [<ffffffff814a7458>] sys_sendto+0xe0/0x108
>   [<ffffffff810f9a76>] ? d_kill+0x6c/0x74
>   [<ffffffff810e99df>] ? fput+0x1ce/0x1dd
>   [<ffffffff81002c9b>] system_call_fastpath+0x16/0x1b

Hi Dimitris

=46ix is known and under its way.

http://kerneltrap.org/mailarchive/linux-kernel/2010/9/23/4623037

Thanks !



