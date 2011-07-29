From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: BUG (NULL ptr dereference in ipv4_dst_check)
Date: Fri, 29 Jul 2011 15:33:41 +0200
Message-ID: <1311946421.2843.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4E32B33C.2020103@hippy.csoma.elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: synapse <synapse@hippy.csoma.elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45550 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751486Ab1G2Ndt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 09:33:49 -0400
Received: by wyg8 with SMTP id 8so172588wyg.19
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2011 06:33:48 -0700 (PDT)
In-Reply-To: <4E32B33C.2020103@hippy.csoma.elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 29 juillet 2011 =C3=A0 15:18 +0200, synapse a =C3=A9crit :
> Hello guys,
>=20
> I have a problem that I hope you can help me resolv. This is my first=
=20
> real bug report, so please be
> patient :)
>=20
> ### Description:
> 3.0.0-rc4 routinely locks up with BUG: unable to handle kernel NULL=20
> pointer dereference at 000000000000002c
> I have an intel sr2600 machine with a 10Gbit interface, it periodical=
ly=20
> locks up after a few days.
> It serves a lot of traffic. The trace is at the end of the mail.
> ###
>=20
> ### My efforts:
> I've traced the error back from atomic_dec_and_test() to:
>=20
> ipv4_dst_check()
> check_peer_redir()
> neigh_release()
> atomic_dec_and_test()
>=20
> The parameter to atomic_dec_and_test() is NULL (&neigh->refcnt in=20
> neigh_release), so atomic_dec_and_test()
> at /arch/x86/include/asm/atomic.h dies at offset 0xffffffff8140f56f.
>=20
> ffffffff8140f560:       48 8b 15 19 47 2f 00    mov   =20
> 0x2f4719(%rip),%rdx        # 0xffffffff81703c80
> ffffffff8140f567:       48 89 50 18             mov    %rdx,0x18(%rax=
)
> ffffffff8140f56b:       48 8b 7b 40             mov    0x40(%rbx),%rd=
i
> ffffffff8140f56f:       f0 ff 4f 2c             lock decl 0x2c(%rdi)
> ffffffff8140f573:       0f 94 c0                sete   %al
> ffffffff8140f576:       84 c0                   test   %al,%al
> ffffffff8140f578:       0f 85 ab 00 00 00       jne    0xffffffff8140=
f629
>=20
>  From what I've seen is that this code is responsible for pmtu relate=
d=20
> things. The refcount member of struct neighbour
> is NULL and the neigh pointer (struct neighbour *) in neigh_release()=
 is=20
> not. I have no clue how this might happen,
> though I suspect somebody releases the data structure somehow. Note t=
hat=20
> this code is invoked when redirect_learned.a4
> is set and is different from rt_gateway in ipv4_dst_check().
>=20
> Is it possible that two packets go to two different cores for process=
ing=20
> and one core invalidates the rt entry
> the other is currently working on (meaning the second will try to=20
> dereference a NULL ptr)?
> ###
>=20
>=20
> This is just my clumsy attempt at tracking this down, I'm not a kerne=
l=20
> expert unfortunately. I'm happy to provide
> further info on the matter. If I'm completely on the wrong track plea=
se=20
> let me know.
>=20
> Thank you for any help,
> Gergely Kalman
>=20

This bug was probably already fixed.

Please try current linux tree



