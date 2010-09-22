From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux/netpoll.h:67 invoked rcu_dereference warning at boot
Date: Wed, 22 Sep 2010 15:30:06 +0200
Message-ID: <1285162206.2639.420.camel@edumazet-laptop>
References: <20100922132014.GA8853@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:45658 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365Ab0IVNaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 09:30:13 -0400
Received: by fxm3 with SMTP id 3so263291fxm.19
        for <netdev@vger.kernel.org>; Wed, 22 Sep 2010 06:30:12 -0700 (PDT)
In-Reply-To: <20100922132014.GA8853@basil.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 22 septembre 2010 =C3=A0 15:20 +0200, Andi Kleen a =C3=A9cr=
it :
> When booting a recent Linus tree with debugging enabled I get=20
> the following warning at boot.
>=20
> I haven't looked into it closely.
>=20
> -Andi
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
> [ INFO: suspicious rcu_dereference_check() usage. ]
> ---------------------------------------------------
> /home/lsrc/git/linux-work2/include/linux/netpoll.h:67 invoked rcu_der=
eferenceeck() without protection!
>=20
> other info that might help us debug this:
>=20
>=20
> rcu_scheduler_active =3D 1, debug_locks =3D 1
> 1 lock held by iceccd/2574:
>  #0:  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff81721bf9>] udp_sendmsg=
+0x289/00
>=20
> stack backtrace:
> Pid: 2574, comm: iceccd Not tainted 2.6.36-rc4-00228-g5647824 #1
> Call Trace:
>  [<ffffffff81090a24>] lockdep_rcu_dereference+0xa4/0xc0
>  [<ffffffff816d3475>] netif_rx+0x215/0x240
>  [<ffffffff81135fbf>] ? cache_alloc_debugcheck_after+0x5f/0x280
>  [<ffffffff8104cc61>] ? get_parent_ip+0x11/0x50
>  [<ffffffff816d36b3>] netif_rx_ni+0x23/0x80
>  [<ffffffff816fd3f3>] ip_dev_loopback_xmit+0x83/0xf0
>  [<ffffffff816fddfa>] ip_mc_output+0x18a/0x220
>  [<ffffffff816fd53d>] ip_local_out+0x2d/0x80
>  [<ffffffff816ff414>] ip_push_pending_frames+0x284/0x420
>  [<ffffffff81720586>] udp_push_pending_frames+0x146/0x3e0
>  [<ffffffff81721bf9>] ? udp_sendmsg+0x289/0x720
>  [<ffffffff81721de4>] udp_sendmsg+0x474/0x720
>  [<ffffffff8105ec82>] ? local_bh_enable_ip+0x82/0x100
>  [<ffffffff8172aee4>] inet_sendmsg+0xc4/0x160
>  [<ffffffff8172ae20>] ? inet_sendmsg+0x0/0x160
>  [<ffffffff816bddd0>] sock_sendmsg+0xc0/0xf0
>  [<ffffffff8110e03a>] ? might_fault+0x7a/0xd0
>  [<ffffffff8110e03a>] ? might_fault+0x7a/0xd0
>  [<ffffffff8110e083>] ? might_fault+0xc3/0xd0
>  [<ffffffff8110e03a>] ? might_fault+0x7a/0xd0
>  [<ffffffff816bfe80>] ? move_addr_to_kernel+0x50/0x60
>  [<ffffffff816c0ba5>] sys_sendto+0xf5/0x130
>  [<ffffffff8100311b>] system_call_fastpath+0x16/0x1b
>=20
>=20

Thanks Andi

I believe I sent a patch this morning

http://lkml.org/lkml/2010/9/22/35




